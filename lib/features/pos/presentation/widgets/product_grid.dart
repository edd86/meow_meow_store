import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:meow_meow_store/core/utils/currency_utils.dart';

import 'package:meow_meow_store/core/extensions/context_x.dart';
import 'package:meow_meow_store/core/theme/app_spacing.dart';
import 'package:meow_meow_store/core/widgets/app_snackbar.dart';
import 'package:meow_meow_store/features/inventory/data/models/product_model.dart';
import '../providers/pos_provider.dart';

class ProductGrid extends ConsumerWidget {
  final List<Product> products;

  const ProductGrid({super.key, required this.products});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currencyFormat = CurrencyUtils.format;

    return GridView.builder(
      padding: AppSpacing.pagePadding,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: _getCrossAxisCount(context),
        crossAxisSpacing: AppSpacing.gutter,
        mainAxisSpacing: AppSpacing.gutter,
        childAspectRatio: 0.85,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return _ProductCard(
          product: product,
          priceFormat: currencyFormat,
          onTap: () {
            ref.read(posProvider.notifier).addItem(product);
            AppSnackBar.show(
              context,
              '${product.name} agregado al carrito',
              duration: const Duration(seconds: 1),
            );
          },
        );
      },
    );
  }

  int _getCrossAxisCount(BuildContext context) => 2;
}

class _ProductCard extends StatelessWidget {
  final Product product;
  final NumberFormat priceFormat;
  final VoidCallback onTap;

  const _ProductCard({
    required this.product,
    required this.priceFormat,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                color: colorScheme.surfaceContainerHigh,
                child: Icon(
                  Icons.inventory_2,
                  size: 48,
                  color: colorScheme.outline,
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      product.name,
                      style: context.textTheme.labelLarge!.copyWith(
                        fontWeight: FontWeight.w700,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          priceFormat.format(product.sellingPrice),
                          style: context.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: colorScheme.primary,
                          ),
                        ),
                        if (product.isLowStock)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: colorScheme.errorContainer,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'Stock: ${product.stockQuantity}',
                              style: context.textTheme.labelSmall?.copyWith(
                                color: colorScheme.onErrorContainer,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
