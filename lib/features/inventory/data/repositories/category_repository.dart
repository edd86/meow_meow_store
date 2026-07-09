import 'package:meow_meow_store/core/network/supabase_client.dart';
import 'package:meow_meow_store/features/inventory/data/models/category_model.dart';

class CategoryRepository {
  final _client = SupabaseClientProvider.instance;

  Future<List<Category>> getCategories() async {
    final response = await _client
        .from('categories')
        .select()
        .order('name');

    return (response as List)
        .map((json) => Category.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<Category> getCategory(String id) async {
    final response = await _client
        .from('categories')
        .select()
        .eq('id', id)
        .single();

    return Category.fromJson(response);
  }

  Future<Category> createCategory(Category category) async {
    final response = await _client
        .from('categories')
        .insert(category.toJson())
        .select()
        .single();

    return Category.fromJson(response);
  }

  Future<Category> updateCategory(Category category) async {
    final response = await _client
        .from('categories')
        .update(category.toJson())
        .eq('id', category.id)
        .select()
        .single();

    return Category.fromJson(response);
  }

  Future<void> deleteCategory(String id) async {
    await _client.from('categories').delete().eq('id', id);
  }
}
