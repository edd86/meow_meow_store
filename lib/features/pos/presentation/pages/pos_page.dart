import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:meow_meow_store/core/extensions/context_x.dart';
import 'package:meow_meow_store/core/theme/app_colors.dart';
import 'package:meow_meow_store/core/theme/app_spacing.dart';
import '../providers/pos_provider.dart';
import '../widgets/product_grid.dart';
import '../widgets/cart_panel.dart';

class POSPage extends ConsumerStatefulWidget {
  const POSPage({super.key});

  @override
  ConsumerState<POSPage> createState() => _POSPageState();
}

class _POSPageState extends ConsumerState<POSPage> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final posState = ref.watch(posProvider);
    final productsAsync = ref.watch(posProductsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Punto de Venta'),
        actions: [
          if (posState.items.isNotEmpty)
            IconButton(
              icon: Badge(
                label: Text('${posState.items.length}'),
                child: const Icon(Icons.shopping_cart),
              ),
              onPressed: () {},
            ),
        ],
      ),
      body: Row(
        children: [
          Expanded(
            flex: 3,
            child: Column(
              children: [
                Padding(
                  padding: AppSpacing.pagePadding,
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      hintText: 'Buscar productos...',
                      prefixIcon: Icon(Icons.search),
                    ),
                    onChanged: (value) {
                      ref.read(posSearchProvider.notifier).state = value;
                    },
                  ),
                ),
                Expanded(
                  child: productsAsync.when(
                    loading: () => const Center(
                      child: CircularProgressIndicator(),
                    ),
                    error: (e, _) => Center(child: Text('Error: $e')),
                    data: (products) {
                      if (products.isEmpty) {
                        return const Center(
                          child: Text('No hay productos disponibles'),
                        );
                      }
                      return ProductGrid(products: products);
                    },
                  ),
                ),
              ],
            ),
          ),
          if (context.isDesktop || context.isTablet)
            SizedBox(
              width: 360,
              child: CartPanel(
                onCheckout: () => _showCheckoutDialog(context, ref),
              ),
            ),
        ],
      ),
      floatingActionButton: posState.items.isNotEmpty && context.isMobile
          ? FloatingActionButton.extended(
              onPressed: () => _showCheckoutDialog(context, ref),
              icon: const Icon(Icons.shopping_cart_checkout),
              label: Text(
                '\$${posState.totalAmount.toStringAsFixed(2)}',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            )
          : null,
    );
  }

  void _showCheckoutDialog(BuildContext context, WidgetRef ref) {
    final posState = ref.read(posProvider);
    final currencyFormat = NumberFormat.currency(
      locale: 'es_MX',
      symbol: '\$',
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return SingleChildScrollView(
            controller: scrollController,
            padding: AppSpacing.pagePadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.outlineVariant,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Resumen de Venta',
                  style: context.textTheme.headlineSmall,
                ),
                const SizedBox(height: AppSpacing.md),
                ...posState.items.map(
                  (item) => ListTile(
                    title: Text(item.product.name),
                    subtitle: Text(
                      '${item.quantity} x ${currencyFormat.format(item.product.sellingPrice)}',
                    ),
                    trailing: Text(
                      currencyFormat.format(item.totalPrice),
                      style: context.textTheme.titleMedium,
                    ),
                  ),
                ),
                const Divider(),
                ListTile(
                  title: const Text('Total'),
                  trailing: Text(
                    currencyFormat.format(posState.totalAmount),
                    style: context.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      await ref.read(posProvider.notifier).completeSale();
                      if (context.mounted) {
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Venta completada exitosamente'),
                            backgroundColor: AppColors.primary,
                          ),
                        );
                      }
                    },
                    child: const Text('Completar Venta'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
