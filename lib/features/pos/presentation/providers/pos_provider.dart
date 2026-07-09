import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:meow_meow_store/features/inventory/data/models/product_model.dart';
import 'package:meow_meow_store/features/inventory/data/repositories/product_repository.dart';
import 'package:meow_meow_store/features/sales/data/repositories/sale_repository.dart';
import 'package:meow_meow_store/features/sales/data/models/sale_model.dart';

class CartItem {
  final Product product;
  final int quantity;

  const CartItem({
    required this.product,
    required this.quantity,
  });

  double get totalPrice => product.sellingPrice * quantity;

  CartItem copyWith({
    Product? product,
    int? quantity,
  }) {
    return CartItem(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
    );
  }
}

class POSState {
  final List<CartItem> items;

  const POSState({this.items = const []});

  double get totalAmount => items.fold<double>(
        0,
        (sum, item) => sum + item.totalPrice,
      );

  POSState copyWith({List<CartItem>? items}) {
    return POSState(items: items ?? this.items);
  }
}

class POSNotifier extends StateNotifier<POSState> {
  POSNotifier() : super(const POSState());

  void addItem(Product product) {
    final existingIndex = state.items.indexWhere(
      (item) => item.product.id == product.id,
    );

    if (existingIndex >= 0) {
      final updatedItems = List<CartItem>.from(state.items);
      updatedItems[existingIndex] = updatedItems[existingIndex].copyWith(
        quantity: updatedItems[existingIndex].quantity + 1,
      );
      state = state.copyWith(items: updatedItems);
    } else {
      state = state.copyWith(
        items: [...state.items, CartItem(product: product, quantity: 1)],
      );
    }
  }

  void removeItem(String productId) {
    state = state.copyWith(
      items: state.items.where((item) => item.product.id != productId).toList(),
    );
  }

  void updateQuantity(String productId, int quantity) {
    if (quantity <= 0) {
      removeItem(productId);
      return;
    }

    final updatedItems = state.items.map((item) {
      if (item.product.id == productId) {
        return item.copyWith(quantity: quantity);
      }
      return item;
    }).toList();

    state = state.copyWith(items: updatedItems);
  }

  void clear() {
    state = const POSState();
  }

  Future<void> completeSale() async {
    final saleRepo = SaleRepository();
    final items = state.items
        .map(
          (item) => SaleItem(
            id: '',
            saleId: '',
            productId: item.product.id,
            quantity: item.quantity,
            unitPrice: item.product.sellingPrice,
            totalPrice: item.totalPrice,
          ),
        )
        .toList();

    final sale = await saleRepo.createSale(items: items);
    await saleRepo.completeSale(sale.id);
    clear();
  }
}

final posProvider = StateNotifierProvider<POSNotifier, POSState>((ref) {
  return POSNotifier();
});

final posSearchProvider = StateProvider<String>((ref) => '');

final posProductsProvider = FutureProvider<List<Product>>((ref) async {
  final search = ref.watch(posSearchProvider);
  final repo = ProductRepository();

  if (search.isEmpty) {
    return repo.getProducts();
  }
  return repo.searchProducts(search);
});
