import 'package:meow_meow_store/features/inventory/data/models/product_model.dart';

abstract class AbstractProductRepository {
  Future<List<Product>> getProducts({String? categoryId});
  Future<Product> getProduct(String id);
  Future<Product> createProduct(Product product);
  Future<Product> updateProduct(Product product);
  Future<void> deleteProduct(String id);
  Future<List<Product>> searchProducts(String query);
}
