import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../network/supabase_provider.dart';

import '../../features/inventory/data/repositories/abstract_category_repository.dart';
import '../../features/inventory/data/repositories/abstract_product_repository.dart';
import '../../features/inventory/data/repositories/category_repository.dart';
import '../../features/inventory/data/repositories/product_repository.dart';

import '../../features/customers/data/repositories/abstract_customer_repository.dart';
import '../../features/customers/data/repositories/customer_repository.dart';

import '../../features/sales/data/repositories/abstract_sale_repository.dart';
import '../../features/sales/data/repositories/sale_repository.dart';

import '../../features/purchases/data/repositories/abstract_purchase_repository.dart';
import '../../features/purchases/data/repositories/purchase_repository.dart';

import '../../features/cash_register/data/repositories/abstract_cash_register_repository.dart';
import '../../features/cash_register/data/repositories/cash_register_repository.dart';

final categoryRepositoryProvider = Provider<AbstractCategoryRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return CategoryRepository(client);
});

final productRepositoryProvider = Provider<AbstractProductRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return ProductRepository(client);
});

final customerRepositoryProvider = Provider<AbstractCustomerRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return CustomerRepository(client);
});

final saleRepositoryProvider = Provider<AbstractSaleRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return SaleRepository(client);
});

final purchaseRepositoryProvider = Provider<AbstractPurchaseRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return PurchaseRepository(client);
});

final cashRegisterRepositoryProvider =
    Provider<AbstractCashRegisterRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return CashRegisterRepository(client);
});
