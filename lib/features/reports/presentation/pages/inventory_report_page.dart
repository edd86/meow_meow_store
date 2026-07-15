import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:meow_meow_store/core/exceptions/app_exception.dart';
import 'package:meow_meow_store/core/extensions/context_x.dart';
import 'package:meow_meow_store/core/providers/repository_providers.dart';
import 'package:meow_meow_store/core/theme/app_spacing.dart';
import 'package:meow_meow_store/core/utils/currency_utils.dart';
import 'package:meow_meow_store/core/widgets/app_error_view.dart';
import 'package:meow_meow_store/core/widgets/app_loading_view.dart';
import 'package:meow_meow_store/features/inventory/data/models/category_model.dart';
import 'package:meow_meow_store/features/inventory/data/models/product_model.dart';

class InventoryReportPage extends ConsumerStatefulWidget {
  const InventoryReportPage({super.key});

  @override
  ConsumerState<InventoryReportPage> createState() =>
      _InventoryReportPageState();
}

class _InventoryReportPageState extends ConsumerState<InventoryReportPage> {
  String? _selectedCategoryId;
  String? _stockFilter;
  late Future<List<Product>> _productsFuture;
  late Future<List<Category>> _categoriesFuture;

  @override
  void initState() {
    super.initState();
    _productsFuture = _loadProducts();
    _categoriesFuture = ref.read(categoryRepositoryProvider).getCategories();
  }

  Future<List<Product>> _loadProducts() async {
    final productRepo = ref.read(productRepositoryProvider);
    return productRepo.getProducts();
  }

  void _applyFilters() {
    setState(() {
      _productsFuture = _loadProducts();
    });
  }

  List<Product> _filterProducts(List<Product> products) {
    var filtered = products;

    if (_selectedCategoryId != null) {
      filtered = filtered
          .where((p) => p.categoryId == _selectedCategoryId)
          .toList();
    }

    if (_stockFilter == 'low') {
      filtered = filtered.where((p) => p.isLowStock && p.stockQuantity > 0).toList();
    } else if (_stockFilter == 'out') {
      filtered = filtered.where((p) => p.stockQuantity == 0).toList();
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Reporte de Inventario')),
      body: Column(
        children: [
          Container(
            padding: AppSpacing.pagePadding,
            color: colorScheme.surfaceContainerLow,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Filtros',
                  style: context.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                FutureBuilder<List<Category>>(
                  future: _categoriesFuture,
                  builder: (context, snapshot) {
                    final categories = snapshot.data ?? [];
                    return DropdownButtonFormField<String?>(
                      initialValue: _selectedCategoryId,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'Categoría',
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                      items: [
                        const DropdownMenuItem(
                          value: null,
                          child: Text('Todas las categorías'),
                        ),
                        ...categories.map(
                          (c) => DropdownMenuItem(
                            value: c.id,
                            child: Text(c.name),
                          ),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() => _selectedCategoryId = value);
                        _applyFilters();
                      },
                    );
                  },
                ),
                const SizedBox(height: AppSpacing.sm),
                SegmentedButton<String?>(
                  segments: const [
                    ButtonSegment(value: null, label: Text('Todos')),
                    ButtonSegment(value: 'low', label: Text('Bajo stock')),
                    ButtonSegment(value: 'out', label: Text('Sin stock')),
                  ],
                  selected: {_stockFilter},
                  onSelectionChanged: (selection) {
                    setState(() => _stockFilter = selection.first);
                    _applyFilters();
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Product>>(
              future: _productsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const AppLoadingView();
                }
                if (snapshot.hasError) {
                  return AppErrorView(
                    message: snapshot.error is AppException
                        ? (snapshot.error as AppException).message
                        : 'Error al cargar productos.',
                  );
                }

                final allProducts = snapshot.data ?? [];
                final filtered = _filterProducts(allProducts);
                final totalValue = filtered.fold<double>(
                  0,
                  (sum, p) => sum + (p.sellingPrice * p.stockQuantity),
                );
                final lowStockCount = filtered
                    .where((p) => p.isLowStock && p.stockQuantity > 0)
                    .length;
                final outOfStockCount =
                    filtered.where((p) => p.stockQuantity == 0).length;

                return Column(
                  children: [
                    Container(
                      padding: AppSpacing.horizontalPadding,
                      child: Row(
                        children: [
                          _SummaryChip(
                            label: 'Productos',
                            value: filtered.length.toString(),
                            color: colorScheme.primary,
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          _SummaryChip(
                            label: 'Valor Total',
                            value: CurrencyUtils.format.format(totalValue),
                            color: colorScheme.tertiary,
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          _SummaryChip(
                            label: 'Bajo Stock',
                            value: lowStockCount.toString(),
                            color: Colors.orange,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    if (outOfStockCount > 0)
                      Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                        ),
                        padding: const EdgeInsets.all(AppSpacing.sm),
                        decoration: BoxDecoration(
                          color: colorScheme.error.withValues(alpha: 0.1),
                          borderRadius: AppRadius.mdAll,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.warning_amber,
                              color: colorScheme.error,
                              size: 20,
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Text(
                              '$outOfStockCount producto(s) sin stock',
                              style: context.textTheme.bodySmall?.copyWith(
                                color: colorScheme.error,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: AppSpacing.sm),
                    Expanded(
                      child: filtered.isEmpty
                          ? const Center(
                              child: Text('No hay productos con estos filtros.'),
                            )
                          : ListView.separated(
                              padding: AppSpacing.pagePadding,
                              itemCount: filtered.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: AppSpacing.xs),
                              itemBuilder: (context, index) {
                                final product = filtered[index];
                                return _ProductTile(product: product);
                              },
                            ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _SummaryChip({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xs,
          ),
          child: Column(
            children: [
              Text(
                value,
                style: context.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
              Text(
                label,
                style: context.textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProductTile extends StatelessWidget {
  final Product product;

  const _ProductTile({required this.product});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: product.isLowStock
              ? (product.stockQuantity == 0
                  ? colorScheme.error.withValues(alpha: 0.1)
                  : Colors.orange.withValues(alpha: 0.1))
              : colorScheme.primary.withValues(alpha: 0.1),
          child: Icon(
            product.stockQuantity == 0
                ? Icons.remove_shopping_cart
                : (product.isLowStock ? Icons.warning : Icons.check_circle),
            color: product.stockQuantity == 0
                ? colorScheme.error
                : (product.isLowStock ? Colors.orange : colorScheme.primary),
            size: 20,
          ),
        ),
        title: Text(
          product.name,
          style: context.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          '${CurrencyUtils.format.format(product.sellingPrice)} - Stock: ${product.stockQuantity}',
          style: context.textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        trailing: Text(
          CurrencyUtils.format.format(
            product.sellingPrice * product.stockQuantity,
          ),
          style: context.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
}
