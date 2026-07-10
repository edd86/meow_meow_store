import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:meow_meow_store/core/exceptions/app_exception.dart';
import 'package:meow_meow_store/features/inventory/data/models/category_model.dart';
import 'abstract_category_repository.dart';

class CategoryRepository implements AbstractCategoryRepository {
  final SupabaseClient _client;

  CategoryRepository(this._client);

  @override
  Future<List<Category>> getCategories() async {
    try {
      final response = await _client.from('categories').select().order('name');

      return (response as List)
          .map((json) => Category.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw ServerException.fromSupabase(e);
    }
  }

  @override
  Future<Category> getCategory(String id) async {
    try {
      final response = await _client
          .from('categories')
          .select()
          .eq('id', id)
          .single();

      return Category.fromJson(response);
    } catch (e) {
      throw ServerException.fromSupabase(e);
    }
  }

  @override
  Future<Category> createCategory(Category category) async {
    try {
      final response = await _client
          .from('categories')
          .insert(category.toJson())
          .select()
          .single();

      return Category.fromJson(response);
    } catch (e) {
      throw ServerException.fromSupabase(e);
    }
  }

  @override
  Future<Category> updateCategory(Category category) async {
    try {
      final response = await _client
          .from('categories')
          .update(category.toJson())
          .eq('id', category.id)
          .select()
          .single();

      return Category.fromJson(response);
    } catch (e) {
      throw ServerException.fromSupabase(e);
    }
  }

  @override
  Future<void> deleteCategory(String id) async {
    try {
      await _client.from('categories').delete().eq('id', id);
    } catch (e) {
      throw ServerException.fromSupabase(e);
    }
  }
}
