import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:meow_meow_store/features/customers/data/models/customer_model.dart';
import 'package:meow_meow_store/features/customers/data/repositories/customer_repository.dart';

final customerSearchProvider = StateProvider<String>((ref) => '');

final customersProvider = FutureProvider<List<Customer>>((ref) async {
  final search = ref.watch(customerSearchProvider);
  final repo = CustomerRepository();
  return repo.getCustomers(search: search.isEmpty ? null : search);
});
