import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meow_meow_store/core/utils/currency_utils.dart';

import 'package:meow_meow_store/core/exceptions/app_exception.dart';
import 'package:meow_meow_store/core/extensions/context_x.dart';
import 'package:meow_meow_store/core/providers/repository_providers.dart';
import 'package:meow_meow_store/core/theme/app_spacing.dart';
import 'package:meow_meow_store/core/widgets/app_error_view.dart';
import 'package:meow_meow_store/core/widgets/app_loading_view.dart';
import 'package:meow_meow_store/core/widgets/app_text_field.dart';
import '../providers/inventory_provider.dart';
import '../widgets/product_form_dialog.dart';
import '../widgets/product_qr_dialog.dart';
import '../widgets/category_form_dialog.dart';
import 'scanner_page.dart';

class InventoryPage extends ConsumerStatefulWidget {
  const InventoryPage({super.key});

  @override
  ConsumerState<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends ConsumerState<InventoryPage> {
  String? _selectedCategoryId;
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(inventoryProductsProvider);
    final categoriesAsync = ref.watch(categoriesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventario'),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            onPressed: () async {
              final result = await Navigator.of(context).push<String>(
                MaterialPageRoute(builder: (_) => const ScannerPage()),
              );
              if (result != null && result.isNotEmpty) {
                _searchController.text = result;
                ref.read(searchQueryProvider.notifier).set(result);
              }
            },
            tooltip: 'Escanear codigo',
          ),
          IconButton(
            icon: const Icon(Icons.category_outlined),
            onPressed: () => _showCategoryDialog(context),
            tooltip: 'Gestionar categorias',
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showProductDialog(context),
          ),
        ],
      ),
      body: Column(
        children: [
          SizedBox(
            height: 50,
            child: categoriesAsync.when(
              loading: () => const AppLoadingView(size: 40),
              error: (e, _) => AppErrorView(
                message: e is AppException
                    ? e.message
                    : 'Error al cargar categorías.',
              ),
              data: (categories) => ListView(
                scrollDirection: Axis.horizontal,
                padding: AppSpacing.horizontalPadding,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: FilterChip(
                      label: const Text('Todos'),
                      selected: _selectedCategoryId == null,
                      onSelected: (_) {
                        setState(() => _selectedCategoryId = null);
                        ref.read(selectedCategoryProvider.notifier).set(null);
                      },
                    ),
                  ),
                  ...categories.map(
                    (cat) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: FilterChip(
                        label: Text(cat.name),
                        selected: _selectedCategoryId == cat.id,
                        onSelected: (_) {
                          setState(() => _selectedCategoryId = cat.id);
                          ref.read(selectedCategoryProvider.notifier).set(cat.id);
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: AppSpacing.sm),
          Padding(
            padding: AppSpacing.horizontalPadding,
            child: AppTextField.search(
              hintText: 'Buscar por nombre o codigo',
              controller: _searchController,
              onChanged: (value) {
                ref.read(searchQueryProvider.notifier).set(
                      value.isEmpty ? null : value,
                    );
              },
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Expanded(
            child: productsAsync.when(
              loading: () => const AppLoadingView(),
              error: (e, _) => AppErrorView(
                message: e is AppException
                    ? e.message
                    : 'Error al cargar productos.',
              ),
              data: (products) {
                if (products.isEmpty) {
                  return const Center(
                    child: Text('No hay productos en el inventario'),
                  );
                }
                return _ProductList(
                  products: products,
                  onEdit: (product) =>
                      _showProductDialog(context, product: product),
                  onDelete: (product) => _deleteProduct(context, ref, product),
                  onShowQr: (product) => _showQrDialog(context, product),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteProduct(
    BuildContext context,
    WidgetRef ref,
    dynamic product,
  ) async {
    try {
      final repo = ref.read(productRepositoryProvider);
      await repo.deleteProduct(product.id as String);
      ref.invalidate(inventoryProductsProvider);
      if (context.mounted) {
        context.showAppSnackBar('${product.name} eliminado del inventario');
      }
    } catch (e) {
      if (context.mounted) {
        context.showAppSnackBar(
          e is AppException ? e.message : 'Error al eliminar el producto.',
          isError: true,
        );
      }
    }
  }

  void _showProductDialog(BuildContext context, {dynamic product}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => ProductFormDialog(product: product),
    );
  }

  void _showQrDialog(BuildContext context, dynamic product) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => ProductQrDialog(
        productName: product.name,
        qrValue: product.barcodeQr ?? '',
      ),
    );
  }

  void _showCategoryDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => const CategoryFormDialog(),
    );
  }
}

class _ProductList extends StatelessWidget {
  final List products;
  final void Function(dynamic) onEdit;
  final void Function(dynamic) onDelete;
  final void Function(dynamic) onShowQr;

  const _ProductList({
    required this.products,
    required this.onEdit,
    required this.onDelete,
    required this.onShowQr,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormat = CurrencyUtils.format;

    return ListView.separated(
      padding: AppSpacing.pagePadding,
      itemCount: products.length,
      separatorBuilder: (_, _) => const Divider(),
      itemBuilder: (context, index) {
        final colorScheme = Theme.of(context).colorScheme;
        final product = products[index];
        return Dismissible(
          key: ValueKey(product.id),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            color: colorScheme.error,
            child: Icon(Icons.delete_outline, color: colorScheme.onError),
          ),
          confirmDismiss: (_) async {
            final confirmed = await showDialog<bool>(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text('Eliminar producto'),
                content: Text('¿Estás seguro de eliminar "${product.name}"?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(false),
                    child: const Text('Cancelar'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(true),
                    style: TextButton.styleFrom(
                      foregroundColor: colorScheme.error,
                    ),
                    child: const Text('Eliminar'),
                  ),
                ],
              ),
            );
            return confirmed ?? false;
          },
          onDismissed: (_) => onDelete(product),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: colorScheme.primaryContainer,
              child: Text(
                product.name.substring(0, 1).toUpperCase(),
                style: TextStyle(color: colorScheme.onPrimaryContainer),
              ),
            ),
            title: Text(product.name),
            subtitle: Text(
              'Stock: ${product.stockQuantity} | '
              '${currencyFormat.format(product.sellingPrice)}',
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (product.isLowStock)
                  Icon(Icons.warning, color: colorScheme.error, size: 20),
                IconButton(
                  icon: const Icon(Icons.qr_code, size: 20),
                  onPressed: () => onShowQr(product),
                ),
                IconButton(
                  icon: const Icon(Icons.edit_outlined, size: 20),
                  onPressed: () => onEdit(product),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
