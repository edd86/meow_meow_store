import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:meow_meow_store/features/inventory/data/models/product_model.dart';
import 'package:meow_meow_store/features/inventory/data/models/category_model.dart';
import 'package:meow_meow_store/features/inventory/data/repositories/product_repository.dart';
import 'package:meow_meow_store/features/inventory/data/repositories/category_repository.dart';

final selectedCategoryProvider = StateProvider<String?>((ref) => null);

final inventoryProductsProvider = FutureProvider<List<Product>>((ref) async {
  final categoryId = ref.watch(selectedCategoryProvider);
  final repo = ProductRepository();
  return repo.getProducts(categoryId: categoryId);
});

final categoriesProvider = FutureProvider<List<Category>>((ref) async {
  final repo = CategoryRepository();
  return repo.getCategories();
});
