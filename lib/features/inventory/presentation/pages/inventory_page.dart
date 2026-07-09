import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:meow_meow_store/core/theme/app_colors.dart';
import 'package:meow_meow_store/core/theme/app_spacing.dart';
import '../providers/inventory_provider.dart';
import '../widgets/product_form_dialog.dart';
import '../widgets/category_form_dialog.dart';

class InventoryPage extends ConsumerStatefulWidget {
  const InventoryPage({super.key});

  @override
  ConsumerState<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends ConsumerState<InventoryPage> {
  String? _selectedCategoryId;

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(inventoryProductsProvider);
    final categoriesAsync = ref.watch(categoriesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventario'),
        actions: [
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
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
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
                        ref.read(selectedCategoryProvider.notifier).state =
                            null;
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
                          ref.read(selectedCategoryProvider.notifier).state =
                              cat.id;
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: productsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (products) {
                if (products.isEmpty) {
                  return const Center(
                    child: Text('No hay productos en el inventario'),
                  );
                }
                return _ProductList(products: products);
              },
            ),
          ),
        ],
      ),
    );
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

  const _ProductList({required this.products});

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'es_MX', symbol: '\$');

    return ListView.separated(
      padding: AppSpacing.pagePadding,
      itemCount: products.length,
      separatorBuilder: (_, _) => const Divider(),
      itemBuilder: (context, index) {
        final product = products[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: AppColors.primaryContainer,
            child: Text(
              product.name.substring(0, 1).toUpperCase(),
              style: const TextStyle(color: AppColors.onPrimaryContainer),
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
                const Icon(Icons.warning, color: AppColors.error, size: 20),
              IconButton(
                icon: const Icon(Icons.edit_outlined, size: 20),
                onPressed: () {},
              ),
            ],
          ),
        );
      },
    );
  }
}
