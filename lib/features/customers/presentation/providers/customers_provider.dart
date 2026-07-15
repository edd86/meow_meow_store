import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/exceptions/app_exception.dart';
import '../../../../core/providers/repository_providers.dart';
import '../../data/models/customer_model.dart';

class CustomerSearchNotifier extends Notifier<String> {
  @override
  String build() => '';

  void set(String value) => state = value;
}

final customerSearchProvider =
    NotifierProvider<CustomerSearchNotifier, String>(CustomerSearchNotifier.new);

final customersProvider = FutureProvider<List<Customer>>((ref) async {
  final search = ref.watch(customerSearchProvider);
  final repo = ref.watch(customerRepositoryProvider);

  try {
    return repo.getCustomers(search: search.isEmpty ? null : search);
  } catch (e) {
    throw ServerException.fromSupabase(e);
  }
});
