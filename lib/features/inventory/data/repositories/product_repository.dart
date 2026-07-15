import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:meow_meow_store/core/exceptions/app_exception.dart';
import 'package:meow_meow_store/features/inventory/data/models/product_model.dart';
import 'abstract_product_repository.dart';

class ProductRepository implements AbstractProductRepository {
  final SupabaseClient _client;

  ProductRepository(this._client);

  @override
  Future<List<Product>> getProducts({String? categoryId}) async {
    try {
      var query = _client.from('products').select();

      if (categoryId != null) {
        query = query.eq('category_id', categoryId);
      }

      final response = await query.order('name');

      return (response as List)
          .map((json) => Product.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw ServerException.fromSupabase(e);
    }
  }

  @override
  Future<Product> getProduct(String id) async {
    try {
      final response = await _client
          .from('products')
          .select()
          .eq('id', id)
          .single();

      return Product.fromJson(response);
    } catch (e) {
      throw ServerException.fromSupabase(e);
    }
  }

  @override
  Future<Product> createProduct(Product product) async {
    try {
      final response = await _client
          .from('products')
          .insert(product.toJson())
          .select()
          .single();

      return Product.fromJson(response);
    } catch (e) {
      throw ServerException.fromSupabase(e);
    }
  }

  @override
  Future<Product> updateProduct(Product product) async {
    try {
      final response = await _client
          .from('products')
          .update(product.toJson())
          .eq('id', product.id)
          .select()
          .single();

      return Product.fromJson(response);
    } catch (e) {
      throw ServerException.fromSupabase(e);
    }
  }

  @override
  Future<void> deleteProduct(String id) async {
    try {
      await _client.from('products').delete().eq('id', id);
    } catch (e) {
      throw ServerException.fromSupabase(e);
    }
  }

  @override
  Future<Product?> getProductByCodebar(String codebar) async {
    try {
      final response = await _client
          .from('products')
          .select()
          .eq('barcode_qr', codebar)
          .maybeSingle();

      return response != null ? Product.fromJson(response) : null;
    } catch (e) {
      throw ServerException.fromSupabase(e);
    }
  }

  @override
  Future<List<Product>> searchProducts(String query) async {
    try {
      final response = await _client
          .from('products')
          .select()
          .or('name.ilike.%$query%,barcode_qr.ilike.%$query%')
          .order('name');

      return (response as List)
          .map((json) => Product.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw ServerException.fromSupabase(e);
    }
  }
}
