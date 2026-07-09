import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/repository_providers.dart';
import '../../data/models/customer_model.dart';

final customerSearchProvider = StateProvider<String>((ref) => '');

final customersProvider = FutureProvider<List<Customer>>((ref) async {
  final search = ref.watch(customerSearchProvider);
  final repo = ref.watch(customerRepositoryProvider);
  return repo.getCustomers(search: search.isEmpty ? null : search);
});
