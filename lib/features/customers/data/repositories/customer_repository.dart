import 'package:meow_meow_store/core/network/supabase_client.dart';
import 'package:meow_meow_store/features/customers/data/models/customer_model.dart';

class CustomerRepository {
  final _client = SupabaseClientProvider.instance;

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

  Future<Customer> getCustomer(String id) async {
    final response = await _client
        .from('customers')
        .select()
        .eq('id', id)
        .single();

    return Customer.fromJson(response);
  }

  Future<Customer> createCustomer(Customer customer) async {
    final response = await _client
        .from('customers')
        .insert(customer.toJson())
        .select()
        .single();

    return Customer.fromJson(response);
  }

  Future<Customer> updateCustomer(Customer customer) async {
    final response = await _client
        .from('customers')
        .update(customer.toJson())
        .eq('id', customer.id)
        .select()
        .single();

    return Customer.fromJson(response);
  }

  Future<void> deleteCustomer(String id) async {
    await _client.from('customers').delete().eq('id', id);
  }
}
