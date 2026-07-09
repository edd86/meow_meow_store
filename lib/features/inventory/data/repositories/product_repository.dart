import 'package:meow_meow_store/core/network/supabase_client.dart';
import 'package:meow_meow_store/features/inventory/data/models/product_model.dart';

class ProductRepository {
  final _client = SupabaseClientProvider.instance;

  Future<List<Product>> getProducts({String? categoryId}) async {
    var query = _client.from('products').select();

    if (categoryId != null) {
      query = query.eq('category_id', categoryId);
    }

    final response = await query.order('name');

    return (response as List)
        .map((json) => Product.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<Product> getProduct(String id) async {
    final response = await _client
        .from('products')
        .select()
        .eq('id', id)
        .single();

    return Product.fromJson(response);
  }

  Future<Product> createProduct(Product product) async {
    final response = await _client
        .from('products')
        .insert(product.toJson())
        .select()
        .single();

    return Product.fromJson(response);
  }

  Future<Product> updateProduct(Product product) async {
    final response = await _client
        .from('products')
        .update(product.toJson())
        .eq('id', product.id)
        .select()
        .single();

    return Product.fromJson(response);
  }

  Future<void> deleteProduct(String id) async {
    await _client.from('products').delete().eq('id', id);
  }

  Future<List<Product>> searchProducts(String query) async {
    final response = await _client
        .from('products')
        .select()
        .or('name.ilike.%$query%,barcode_qr.ilike.%$query%')
        .order('name');

    return (response as List)
        .map((json) => Product.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}
