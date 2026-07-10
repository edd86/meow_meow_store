-- Enable UUID extension
create extension if not exists "uuid-ossp";

-- 1. CATALOG TABLES
CREATE TABLE public.categories (
id uuid NOT NULL DEFAULT gen_random_uuid(),
name character varying NOT NULL,
description text,
created_at timestamp with time zone NOT NULL DEFAULT timezone('utc'::text, now()),
CONSTRAINT categories_pkey PRIMARY KEY (id)
);

CREATE TABLE public.products (
id uuid NOT NULL DEFAULT gen_random_uuid(),
category_id uuid,
name character varying NOT NULL,
barcode_qr character varying UNIQUE,
description text,
buying_price numeric NOT NULL CHECK (buying_price >= 0::numeric),
selling_price numeric NOT NULL CHECK (selling_price >= 0::numeric),
stock_quantity integer DEFAULT 0 CHECK (stock_quantity >= 0),
created_at timestamp with time zone NOT NULL DEFAULT timezone('utc'::text, now()),
CONSTRAINT products_pkey PRIMARY KEY (id),
CONSTRAINT products_category_id_fkey FOREIGN KEY (category_id) REFERENCES public.categories(id)
);

-- 2. CRM / CUSTOMER TABLES
CREATE TABLE public.customers (
id uuid NOT NULL DEFAULT gen_random_uuid(),
first_name character varying NOT NULL,
last_name character varying,
email character varying UNIQUE,
phone character varying,
created_at timestamp with time zone NOT NULL DEFAULT timezone('utc'::text, now()),
CONSTRAINT customers_pkey PRIMARY KEY (id)
);

-- 3. CASH REGISTER & SESSION TABLES (Enhanced)
CREATE TABLE public.cash_registers (
id uuid NOT NULL DEFAULT gen_random_uuid(),
name character varying NOT NULL DEFAULT 'Main Cash Register'::character varying,
current_balance numeric DEFAULT 0.00 CHECK (current_balance >= 0::numeric),
updated_at timestamp with time zone NOT NULL DEFAULT timezone('utc'::text, now()),
CONSTRAINT cash_registers_pkey PRIMARY KEY (id)
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
);

-- Insert the default master cash register structure
insert into cash_registers (name, current_balance)
values ('General Cash Box', 0.00);

-- 4. SALES MANAGEMENT
CREATE TABLE public.sales (
id uuid NOT NULL DEFAULT gen_random_uuid(),
customer_id uuid,
total_amount numeric DEFAULT 0.00 CHECK (total_amount >= 0::numeric),
status character varying DEFAULT 'pending'::character varying CHECK (status::text = ANY (ARRAY['pending'::character varying, 'completed'::character varying, 'cancelled'::character varying]::text[])),
created_at timestamp with time zone NOT NULL DEFAULT timezone('utc'::text, now()),
CONSTRAINT sales_pkey PRIMARY KEY (id),
CONSTRAINT sales_customer_id_fkey FOREIGN KEY (customer_id) REFERENCES public.customers(id)
);

CREATE TABLE public.sale_items (
id uuid NOT NULL DEFAULT gen_random_uuid(),
sale_id uuid NOT NULL,
product_id uuid NOT NULL,
quantity integer NOT NULL CHECK (quantity > 0),
unit_price numeric NOT NULL CHECK (unit_price >= 0::numeric),
total_price numeric DEFAULT ((quantity)::numeric \* unit_price),
CONSTRAINT sale_items_pkey PRIMARY KEY (id),
CONSTRAINT sale_items_sale_id_fkey FOREIGN KEY (sale_id) REFERENCES public.sales(id),
CONSTRAINT sale_items_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(id)
);

-- 5. PURCHASES MANAGEMENT
CREATE TABLE public.purchases (
id uuid NOT NULL DEFAULT gen_random_uuid(),
supplier_name character varying,
total_amount numeric DEFAULT 0.00 CHECK (total_amount >= 0::numeric),
status character varying DEFAULT 'pending'::character varying CHECK (status::text = ANY (ARRAY['pending'::character varying, 'completed'::character varying, 'cancelled'::character varying]::text[])),
created_at timestamp with time zone NOT NULL DEFAULT timezone('utc'::text, now()),
CONSTRAINT purchases_pkey PRIMARY KEY (id)
);

CREATE TABLE public.purchase_items (
id uuid NOT NULL DEFAULT gen_random_uuid(),
purchase_id uuid NOT NULL,
product_id uuid NOT NULL,
quantity integer NOT NULL CHECK (quantity > 0),
unit_price numeric NOT NULL CHECK (unit_price >= 0::numeric),
total_price numeric DEFAULT ((quantity)::numeric \* unit_price),
CONSTRAINT purchase_items_pkey PRIMARY KEY (id),
CONSTRAINT purchase_items_purchase_id_fkey FOREIGN KEY (purchase_id) REFERENCES public.purchases(id),
CONSTRAINT purchase_items_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(id)
);

-- 6. CASH TRANSACTIONS DETAILED LOG (Linked to Session)
CREATE TABLE public.cash_transactions (
id uuid NOT NULL DEFAULT gen_random_uuid(),
session_id uuid NOT NULL,
transaction_type character varying NOT NULL CHECK (transaction_type::text = ANY (ARRAY['income'::character varying, 'expense'::character varying]::text[])),
amount numeric NOT NULL CHECK (amount > 0::numeric),
description text NOT NULL,
sale_id uuid,
purchase_id uuid,
created_at timestamp with time zone NOT NULL DEFAULT timezone('utc'::text, now()),
CONSTRAINT cash_transactions_pkey PRIMARY KEY (id),
CONSTRAINT cash_transactions_session_id_fkey FOREIGN KEY (session_id) REFERENCES public.cash_register_sessions(id),
CONSTRAINT cash_transactions_sale_id_fkey FOREIGN KEY (sale_id) REFERENCES public.sales(id),
CONSTRAINT cash_transactions_purchase_id_fkey FOREIGN KEY (purchase_id) REFERENCES public.purchases(id)
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


-- C. Automatic Cash Flow Trigger for Sales (Enforces Open Session on Complete Only)
create or replace function process_sale_cash_flow()
returns trigger as
$$

declare
v_session_id uuid;
begin
if (tg_op = 'INSERT' and new.status = 'completed') or
(tg_op = 'UPDATE' and old.status != 'completed' and new.status = 'completed') then

        select id into v_session_id
        from cash_register_sessions
        where status = 'open'
        limit 1;

        if v_session_id is null then
            raise exception 'No active cash register session is currently open. Please open the cash register first.';
        end if;

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


-- D. Automatic Cash Flow Trigger for Purchases (Enforces Open Session on Complete Only)
create or replace function process_purchase_cash_flow()
returns trigger as
$$

declare
v_session_id uuid;
begin
if (tg_op = 'INSERT' and new.status = 'completed') or
(tg_op = 'UPDATE' and old.status != 'completed' and new.status = 'completed') then

        select id into v_session_id
        from cash_register_sessions
        where status = 'open'
        limit 1;

        if v_session_id is null then
            raise exception 'No active cash register session is currently open. Please open the cash register first.';
        end if;

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
