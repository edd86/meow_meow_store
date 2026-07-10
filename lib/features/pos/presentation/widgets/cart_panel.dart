import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:meow_meow_store/core/extensions/context_x.dart';
import 'package:meow_meow_store/core/theme/app_colors.dart';
import 'package:meow_meow_store/core/theme/app_spacing.dart';
import 'package:meow_meow_store/core/widgets/app_elevated_button.dart';
import '../providers/pos_provider.dart';

class CartPanel extends ConsumerWidget {
  final VoidCallback onCheckout;

  const CartPanel({super.key, required this.onCheckout});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final posState = ref.watch(posProvider);
    final currencyFormat = NumberFormat.currency(locale: 'es_BO', symbol: '\$');

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        border: Border(left: BorderSide(color: AppColors.surfaceVariant)),
      ),
      child: Column(
        children: [
          Container(
            padding: AppSpacing.pagePadding,
            decoration: const BoxDecoration(
              color: AppColors.surfaceContainerLow,
              border: Border(
                bottom: BorderSide(color: AppColors.surfaceVariant),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Carrito', style: context.textTheme.headlineSmall),
                if (posState.items.isNotEmpty)
                  TextButton.icon(
                    onPressed: () {
                      ref.read(posProvider.notifier).clear();
                    },
                    icon: const Icon(Icons.delete_outline, size: 18),
                    label: const Text('Vaciar'),
                  ),
              ],
            ),
          ),
          Expanded(
            child: posState.items.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.shopping_cart_outlined,
                          size: 64,
                          color: AppColors.outlineVariant,
                        ),
                        SizedBox(height: AppSpacing.sm),
                        Text(
                          'Carrito vacio',
                          style: TextStyle(color: AppColors.outline),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: AppSpacing.pagePadding,
                    itemCount: posState.items.length,
                    separatorBuilder: (_, _) => const Divider(),
                    itemBuilder: (context, index) {
                      final item = posState.items[index];
                      return Dismissible(
                        key: ValueKey(item.product.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          color: AppColors.error,
                          child: const Icon(
                            Icons.delete_outline,
                            color: AppColors.onError,
                          ),
                        ),
                        onDismissed: (_) {
                          ref
                              .read(posProvider.notifier)
                              .removeItem(item.product.id);
                        },
                        child: _CartItemTile(
                          item: item,
                          currencyFormat: currencyFormat,
                          onQuantityChanged: (quantity) {
                            ref
                                .read(posProvider.notifier)
                                .updateQuantity(item.product.id, quantity);
                          },
                          onRemove: () {
                            ref
                                .read(posProvider.notifier)
                                .removeItem(item.product.id);
                          },
                        ),
                      );
                    },
                  ),
          ),
          Container(
            padding: AppSpacing.pagePadding,
            decoration: const BoxDecoration(
              color: AppColors.surfaceContainerLow,
              border: Border(top: BorderSide(color: AppColors.surfaceVariant)),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Total', style: context.textTheme.titleLarge),
                    Text(
                      currencyFormat.format(posState.totalAmount),
                      style: context.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                AppElevatedButton.primary(
                  label: 'Cobrar',
                  onPressed: posState.items.isEmpty ? null : onCheckout,
                  fullWidth: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CartItemTile extends StatelessWidget {
  final CartItem item;
  final NumberFormat currencyFormat;
  final ValueChanged<int> onQuantityChanged;
  final VoidCallback onRemove;

  const _CartItemTile({
    required this.item,
    required this.currencyFormat,
    required this.onQuantityChanged,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.product.name,
                style: context.textTheme.labelLarge,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                currencyFormat.format(item.product.sellingPrice),
                style: context.textTheme.bodySmall?.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.remove_circle_outline, size: 20),
              onPressed: () => onQuantityChanged(item.quantity - 1),
            ),
            Text('${item.quantity}', style: context.textTheme.titleMedium),
            IconButton(
              icon: const Icon(Icons.add_circle_outline, size: 20),
              onPressed: () => onQuantityChanged(item.quantity + 1),
            ),
          ],
        ),
        Text(
          currencyFormat.format(item.totalPrice),
          style: context.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.close, size: 18, color: AppColors.error),
          onPressed: onRemove,
        ),
      ],
    );
  }
}
