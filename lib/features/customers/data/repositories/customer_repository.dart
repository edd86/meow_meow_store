import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:meow_meow_store/features/customers/data/models/customer_model.dart';
import 'abstract_customer_repository.dart';

class CustomerRepository implements AbstractCustomerRepository {
  final SupabaseClient _client;

  CustomerRepository(this._client);

  @override
  Future<List<Customer>> getCustomers({String? search}) async {
    var query = _client.from('customers').select();

    if (search != null && search.isNotEmpty) {
      query = query.or(
        'first_name.ilike.%$search%,last_name.ilike.%$search%,email.ilike.%$search%,phone.ilike.%$search%',
      );
    }

    final response = await query.order('first_name');

    return (response as List)
        .map((json) => Customer.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<Customer> getCustomer(String id) async {
    final response = await _client
        .from('customers')
        .select()
        .eq('id', id)
        .single();

    return Customer.fromJson(response);
  }

  @override
  Future<Customer> createCustomer(Customer customer) async {
    final response = await _client
        .from('customers')
        .insert(customer.toJson())
        .select()
        .single();

    return Customer.fromJson(response);
  }

  @override
  Future<Customer> updateCustomer(Customer customer) async {
    final response = await _client
        .from('customers')
        .update(customer.toJson())
        .eq('id', customer.id)
        .select()
        .single();

    return Customer.fromJson(response);
  }

  @override
  Future<void> deleteCustomer(String id) async {
    await _client.from('customers').delete().eq('id', id);
  }
}
