import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meow_meow_store/core/utils/currency_utils.dart';

import 'package:meow_meow_store/core/exceptions/app_exception.dart';
import 'package:meow_meow_store/core/extensions/context_x.dart';
import 'package:meow_meow_store/core/theme/app_spacing.dart';
import 'package:meow_meow_store/core/providers/repository_providers.dart';
import 'package:meow_meow_store/core/utils/barcode_utils.dart';
import 'package:meow_meow_store/features/inventory/data/models/product_model.dart';
import 'package:meow_meow_store/features/customers/data/models/customer_model.dart';
import 'package:meow_meow_store/core/widgets/app_elevated_button.dart';
import 'package:meow_meow_store/core/widgets/app_loading_view.dart';
import 'package:meow_meow_store/core/widgets/app_text_field.dart';
import 'package:meow_meow_store/features/cash_register/presentation/providers/cash_register_provider.dart';
import 'package:meow_meow_store/features/inventory/presentation/pages/scanner_page.dart';
import '../providers/pos_provider.dart';
import '../widgets/product_grid.dart';
import '../widgets/cart_panel.dart';
import '../widgets/customer_picker_field.dart';

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
              loading: () => const AppLoadingView(),
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
          ? ElevatedButton.icon(
              onPressed: () => _showCheckoutDialog(context, ref),
              icon: const Icon(Icons.shopping_cart_checkout),
              label: Text(
                'Cobrar ${CurrencyUtils.format.format(posState.totalAmount)}',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                foregroundColor: Theme.of(
                  context,
                ).colorScheme.onPrimaryContainer,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 4,
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
      Product? product;

      try {
        final decoded = BarcodeUtils.decode(result);
        final productId = decoded['id'] as String;
        product = await productRepo.getProduct(productId);
      } catch (_) {
        product = await productRepo.getProductByCodebar(result);
      }

      if (product != null) {
        ref.read(posProvider.notifier).addItem(product);
        if (context.mounted) {
          context.showAppSnackBar('${product.name} agregado al carrito');
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
    final currencyFormat = CurrencyUtils.format;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final colorScheme = Theme.of(context).colorScheme;
            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom + 16,
              ),
              child: SingleChildScrollView(
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
                    CustomerPickerField(
                      selectedCustomer: ref.read(posProvider).selectedCustomer,
                      onCustomerSelected: (customer) {
                        ref.read(posProvider.notifier).setCustomer(customer);
                        setDialogState(() {});
                      },
                      onCreateNew: () {
                        Navigator.of(context).pop();
                        _showInlineCustomerCreation(context, ref);
                      },
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    AppElevatedButton.primary(
                      label: 'Completar Venta',
                      onPressed: () async {
                        try {
                          await ref.read(posProvider.notifier).completeSale();
                          ref.invalidate(sessionTransactionsProvider);
                          if (context.mounted) {
                            Navigator.of(context).pop();
                            context.showAppSnackBar(
                              'Venta completada exitosamente',
                            );
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
              ),
            );
          },
        );
      },
    );
  }

  void _showInlineCustomerCreation(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final colorScheme = Theme.of(context).colorScheme;
            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom + 16,
              ),
              child: SingleChildScrollView(
                child: Form(
                  key: formKey,
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
                        'Nuevo Cliente',
                        style: context.textTheme.headlineSmall!.copyWith(
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      AppTextField(
                        label: 'Nombre',
                        controller: nameController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'El nombre es requerido';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      AppTextField(
                        label: 'Teléfono',
                        controller: phoneController,
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      SizedBox(
                        width: double.infinity,
                        child: AppElevatedButton.primary(
                          label: 'Guardar y seleccionar',
                          onPressed: () async {
                            if (!formKey.currentState!.validate()) return;
                            try {
                              final repo = ref.read(customerRepositoryProvider);
                              final customer = Customer(
                                id: '',
                                firstName: nameController.text,
                                phone: phoneController.text.isNotEmpty
                                    ? phoneController.text
                                    : null,
                                createdAt: DateTime.now(),
                              );
                              final created = await repo.createCustomer(
                                customer,
                              );
                              ref
                                  .read(posProvider.notifier)
                                  .setCustomer(created);
                              if (context.mounted) {
                                Navigator.of(context).pop();
                                context.showAppSnackBar(
                                  '${created.fullName} agregado como cliente',
                                );
                              }
                            } catch (e) {
                              if (context.mounted) {
                                context.showAppSnackBar(
                                  e is AppException
                                      ? e.message
                                      : 'Error al crear el cliente.',
                                  isError: true,
                                );
                              }
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
