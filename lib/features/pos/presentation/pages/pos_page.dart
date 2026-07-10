import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:meow_meow_store/core/exceptions/app_exception.dart';
import 'package:meow_meow_store/core/extensions/context_x.dart';
import 'package:meow_meow_store/core/theme/app_spacing.dart';
import 'package:meow_meow_store/core/providers/repository_providers.dart';
import 'package:meow_meow_store/core/utils/barcode_utils.dart';
import 'package:meow_meow_store/core/widgets/app_elevated_button.dart';
import 'package:meow_meow_store/core/widgets/app_text_field.dart';
import 'package:meow_meow_store/features/inventory/presentation/pages/scanner_page.dart';
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
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => Scaffold(
                      appBar: AppBar(title: const Text('Carrito')),
                      body: CartPanel(
                        onCheckout: () {
                          Navigator.of(context).pop();
                          _showCheckoutDialog(context, ref);
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: AppSpacing.pagePadding,
            child: Row(
              children: [
                Expanded(
                  child: AppTextField(
                    label: 'Buscar productos...',
                    controller: _searchController,
                    onChanged: (value) {
                      ref.read(posSearchProvider.notifier).state = value;
                    },
                  ),
                ),
                IconButton(
                  onPressed: () => _scanAndAddToCart(context, ref),
                  icon: Icon(Icons.qr_code_scanner),
                ),
              ],
            ),
          ),
          Expanded(
            child: productsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(
                child: Text(
                  e is AppException ? e.message : 'Error al cargar productos.',
                ),
              ),
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
      floatingActionButton: posState.items.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: () => _showCheckoutDialog(context, ref),
              icon: const Icon(Icons.shopping_cart_checkout),
              label: Text(
                'Cobrar \$${posState.totalAmount.toStringAsFixed(2)}',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Future<void> _scanAndAddToCart(BuildContext context, WidgetRef ref) async {
    final result = await Navigator.of(
      context,
    ).push<String>(MaterialPageRoute(builder: (_) => const ScannerPage()));
    if (result == null || result.isEmpty) return;

    try {
      final productRepo = ref.read(productRepositoryProvider);

      try {
        final decoded = BarcodeUtils.decode(result);
        final productId = decoded['id'] as String;
        final product = await productRepo.getProduct(productId);
        ref.read(posProvider.notifier).addItem(product);
        if (context.mounted) {
          context.showAppSnackBar('${product.name} agregado al carrito');
        }
        return;
      } catch (_) {}

      final products = await productRepo.searchProducts(result);
      if (products.isNotEmpty) {
        ref.read(posProvider.notifier).addItem(products.first);
        if (context.mounted) {
          context.showAppSnackBar('${products.first.name} agregado al carrito');
        }
      } else {
        if (context.mounted) {
          context.showAppSnackBar('Producto no encontrado', isError: true);
        }
      }
    } catch (e) {
      if (context.mounted) {
        context.showAppSnackBar(
          e is AppException ? e.message : 'Error al buscar producto.',
          isError: true,
        );
      }
    }
  }

  void _showCheckoutDialog(BuildContext context, WidgetRef ref) {
    final posState = ref.read(posProvider);
    final currencyFormat = NumberFormat.currency(locale: 'es_BO', symbol: '\$');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        final colorScheme = Theme.of(context).colorScheme;
        return Padding(
          padding: AppSpacing.pagePadding,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Confirmar Venta',
                style: context.textTheme.headlineSmall!.copyWith(
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total a cobrar',
                    style: context.textTheme.titleLarge!.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    currencyFormat.format(posState.totalAmount),
                    style: context.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: colorScheme.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              AppElevatedButton.primary(
                label: 'Completar Venta',
                onPressed: () async {
                  try {
                    await ref.read(posProvider.notifier).completeSale();
                    if (context.mounted) {
                      Navigator.of(context).pop();
                      context.showAppSnackBar('Venta completada exitosamente');
                    }
                  } catch (e) {
                    if (context.mounted) {
                      context.showAppSnackBar(
                        e is AppException
                            ? e.message
                            : 'Error al completar la venta.',
                        isError: true,
                      );
                    }
                  }
                },
                fullWidth: true,
              ),
            ],
          ),
        );
      },
    );
  }
}
