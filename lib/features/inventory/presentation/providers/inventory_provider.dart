import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/repository_providers.dart';
import '../../data/models/product_model.dart';
import '../../data/models/category_model.dart';

final selectedCategoryProvider = StateProvider<String?>((ref) => null);

final inventoryProductsProvider = FutureProvider<List<Product>>((ref) async {
  final categoryId = ref.watch(selectedCategoryProvider);
  final repo = ref.watch(productRepositoryProvider);
  return repo.getProducts(categoryId: categoryId);
});

final categoriesProvider = FutureProvider<List<Category>>((ref) async {
  final repo = ref.watch(categoryRepositoryProvider);
  return repo.getCategories();
});
