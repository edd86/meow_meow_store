-- Enable UUID extension
create extension if not exists "uuid-ossp";

-- 1. CATALOG TABLES
create table categories (
id uuid primary key default gen_random_uuid(),
name varchar(100) not null,
description text,
created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

create table products (
id uuid primary key default gen_random_uuid(),
category_id uuid references categories(id) on delete set null,
name varchar(150) not null,
barcode_qr varchar(100) unique,
description text,
buying_price decimal(10, 2) not null check (buying_price >= 0),
selling_price decimal(10, 2) not null check (selling_price >= 0),
stock_quantity int default 0 check (stock_quantity >= 0),
created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- 2. CRM / CUSTOMER TABLES
create table customers (
id uuid primary key default gen_random_uuid(),
first_name varchar(100) not null,
last_name varchar(100),
email varchar(150) unique,
phone varchar(30),
created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- 3. CASH REGISTER & SESSION TABLES (Enhanced)
create table cash_registers (
id uuid primary key default gen_random_uuid(),
name varchar(100) default 'Main Cash Register' not null,
current_balance decimal(12, 2) default 0.00 check (current_balance >= 0),
updated_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Table to manage open/close sessions (Shifts)
create table cash_register_sessions (
id uuid primary key default gen_random_uuid(),
cash_register_id uuid references cash_registers(id) on delete restrict not null,
opened_at timestamp with time zone default timezone('utc'::text, now()) not null,
closed_at timestamp with time zone,
opening_amount decimal(12, 2) not null check (opening_amount >= 0),
closing_amount decimal(12, 2) check (closing_amount >= 0), -- Actual physical cash counted at checkout
status varchar(20) default 'open' check (status in ('open', 'closed')),
opened_by uuid references auth.users(id) on delete set null, -- Supabase Auth tracking
closed_by uuid references auth.users(id) on delete set null
);

-- Insert the default master cash register structure
insert into cash_registers (name, current_balance)
values ('General Cash Box', 0.00);

-- 4. SALES MANAGEMENT
create table sales (
id uuid primary key default gen_random_uuid(),
customer_id uuid references customers(id) on delete set null,
user_id uuid references auth.users(id) on delete set null,
total_amount decimal(12, 2) default 0.00 check (total_amount >= 0),
status varchar(20) default 'pending' check (status in ('pending', 'completed', 'cancelled')),
created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

create table sale_items (
id uuid primary key default gen_random_uuid(),
sale_id uuid references sales(id) on delete cascade not null,
product_id uuid references products(id) on delete restrict not null,
quantity int not null check (quantity > 0),
unit_price decimal(10, 2) not null check (unit_price >= 0),
total_price decimal(12, 2) generated always as (quantity \* unit_price) stored
);

-- 5. PURCHASES MANAGEMENT
create table purchases (
id uuid primary key default gen_random_uuid(),
supplier_name varchar(150),
total_amount decimal(12, 2) default 0.00 check (total_amount >= 0),
status varchar(20) default 'pending' check (status in ('pending', 'completed', 'cancelled')),
created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

create table purchase_items (
id uuid primary key default gen_random_uuid(),
purchase_id uuid references purchases(id) on delete cascade not null,
product_id uuid references products(id) on delete restrict not null,
quantity int not null check (quantity > 0),
unit_price decimal(10, 2) not null check (unit_price >= 0),
total_price decimal(12, 2) generated always as (quantity \* unit_price) stored
);

-- 6. CASH TRANSACTIONS DETAILED LOG (Linked to Session)
create table cash_transactions (
id uuid primary key default gen_random_uuid(),
session_id uuid references cash_register_sessions(id) on delete restrict not null, -- Linked to the specific shift
transaction_type varchar(20) not null check (transaction_type in ('income', 'expense')),
amount decimal(12, 2) not null check (amount > 0),
description text not null, -- Detailed reason
sale_id uuid references sales(id) on delete set null,
purchase_id uuid references purchases(id) on delete set null,
created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- 7. AUTOMATION & INTEGRITY TRIGGERS

-- A. Update Inventory Stock on Sale Items
create or replace function update_stock_on_sale()
returns trigger as $$
begin
update products
set stock_quantity = stock_quantity - new.quantity
where id = new.product_id;
return new;
end;

$$
language plpgsql;

create trigger tr_update_stock_on_sale
after insert on sale_items
for each row execute function update_stock_on_sale();

-- B. Update Inventory Stock on Purchase Items
create or replace function update_stock_on_purchase()
returns trigger as
$$

begin
update products
set stock_quantity = stock_quantity + new.quantity
where id = new.product_id;
return new;
end;

$$
language plpgsql;

create trigger tr_update_stock_on_purchase
after insert on purchase_items
for each row execute function update_stock_on_purchase();


-- C. Automatic Cash Flow Trigger for Sales (Enforces Open Session)
create or replace function process_sale_cash_flow()
returns trigger as
$$

declare
v_session_id uuid;
begin
-- Look for the currently active/open session
select id into v_session_id
from cash_register_sessions
where status = 'open'
limit 1;

    -- Strict check: block transaction if the cash register is closed
    if v_session_id is null then
        raise exception 'Transaction aborted: No active cash register session is currently open. Please open the cash register first.';
    end if;

    if (tg_op = 'INSERT' and new.status = 'completed') or
       (tg_op = 'UPDATE' and old.status != 'completed' and new.status = 'completed') then

        insert into cash_transactions (session_id, transaction_type, amount, description, sale_id)
        values (
            v_session_id,
            'income',
            new.total_amount,
            'Automatic cash inflow from Sale ID: ' || new.id || '. Reason: Souvenir retail sale.',
            new.id
        );
    end if;
    return new;

end;

$$
language plpgsql;

create trigger tr_process_sale_cash_flow
after insert or update on sales
for each row execute function process_sale_cash_flow();


-- D. Automatic Cash Flow Trigger for Purchases (Enforces Open Session)
create or replace function process_purchase_cash_flow()
returns trigger as
$$

declare
v_session_id uuid;
begin
select id into v_session_id
from cash_register_sessions
where status = 'open'
limit 1;

    if v_session_id is null then
        raise exception 'Transaction aborted: No active cash register session is currently open. Please open the cash register first.';
    end if;

    if (tg_op = 'INSERT' and new.status = 'completed') or
       (tg_op = 'UPDATE' and old.status != 'completed' and new.status = 'completed') then

        insert into cash_transactions (session_id, transaction_type, amount, description, purchase_id)
        values (
            v_session_id,
            'expense',
            new.total_amount,
            'Automatic cash outflow for Purchase ID: ' || new.id || '. Reason: Inventory restocking.',
            new.id
        );
    end if;
    return new;

end;

$$
language plpgsql;

create trigger tr_process_purchase_cash_flow
after insert or update on purchases
for each row execute function process_purchase_cash_flow();


-- E. Update Master Cash Register Balance based on Session Transactions
create or replace function update_cash_register_balance()
returns trigger as
$$

declare
v_register_id uuid;
begin
-- Find the cash register associated with this session
select cash_register_id into v_register_id
from cash_register_sessions
where id = new.session_id;

    if new.transaction_type = 'income' then
        update cash_registers
        set current_balance = current_balance + new.amount,
            updated_at = timezone('utc'::text, now())
        where id = v_register_id;
    elsif new.transaction_type = 'expense' then
        update cash_registers
        set current_balance = current_balance - new.amount,
            updated_at = timezone('utc'::text, now())
        where id = v_register_id;
    end if;
    return new;

end;

$$
language plpgsql;

create trigger tr_update_cash_register_balance
after insert on cash_transactions
for each row execute function update_cash_register_balance();


-- 8. PERFORMANCE INDEXES
create index idx_products_category on products(category_id);
create index idx_sale_items_sale on sale_items(sale_id);
create index idx_purchase_items_purchase on purchase_items(purchase_id);
create index idx_cash_sessions_register on cash_register_sessions(cash_register_id);
create index idx_cash_transactions_session on cash_transactions(session_id);
$$
