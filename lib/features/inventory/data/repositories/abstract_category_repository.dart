import 'package:meow_meow_store/features/inventory/data/models/category_model.dart';

abstract class AbstractCategoryRepository {
  Future<List<Category>> getCategories();
  Future<Category> getCategory(String id);
  Future<Category> createCategory(Category category);
  Future<Category> updateCategory(Category category);
  Future<void> deleteCategory(String id);
}
