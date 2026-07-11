import 'package:meow_meow_store/features/customers/data/models/customer_model.dart';

abstract class AbstractCustomerRepository {
  Future<List<Customer>> getCustomers({String? search});
  Future<List<Customer>> searchCustomers(String query, {int limit = 20});
  Future<Customer> getCustomer(String id);
  Future<Customer> createCustomer(Customer customer);
  Future<Customer> updateCustomer(Customer customer);
  Future<void> deleteCustomer(String id);
}
