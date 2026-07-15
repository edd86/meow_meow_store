import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/exceptions/app_exception.dart';
import '../../../../core/providers/repository_providers.dart';
import '../../data/models/product_model.dart';
import '../../data/models/category_model.dart';

class SelectedCategoryNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void set(String? value) => state = value;
}

class SearchQueryNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void set(String? value) => state = value;
}

final selectedCategoryProvider =
    NotifierProvider<SelectedCategoryNotifier, String?>(
  SelectedCategoryNotifier.new,
);

final searchQueryProvider =
    NotifierProvider<SearchQueryNotifier, String?>(SearchQueryNotifier.new);

final inventoryProductsProvider = FutureProvider<List<Product>>((ref) async {
  final categoryId = ref.watch(selectedCategoryProvider);
  final query = ref.watch(searchQueryProvider);
  final repo = ref.watch(productRepositoryProvider);

  try {
    if (query != null && query.isNotEmpty) {
      return repo.searchProducts(query);
    }

    return repo.getProducts(categoryId: categoryId);
  } catch (e) {
    throw ServerException.fromSupabase(e);
  }
});

final categoriesProvider = FutureProvider<List<Category>>((ref) async {
  final repo = ref.watch(categoryRepositoryProvider);

  try {
    return repo.getCategories();
  } catch (e) {
    throw ServerException.fromSupabase(e);
  }
});
