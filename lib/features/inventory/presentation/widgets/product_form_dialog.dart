import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:meow_meow_store/core/providers/repository_providers.dart';
import 'package:meow_meow_store/core/theme/app_spacing.dart';
import 'package:meow_meow_store/core/utils/price_utils.dart';
import 'package:meow_meow_store/core/widgets/app_dropdown.dart';
import 'package:meow_meow_store/core/widgets/app_elevated_button.dart';
import 'package:meow_meow_store/core/widgets/app_text_field.dart';
import 'package:meow_meow_store/features/inventory/data/models/product_model.dart';
import '../pages/scanner_page.dart';
import '../providers/inventory_provider.dart';

class ProductFormDialog extends ConsumerStatefulWidget {
  final Product? product;

  const ProductFormDialog({super.key, this.product});

  @override
  ConsumerState<ProductFormDialog> createState() => _ProductFormDialogState();
}

class _ProductFormDialogState extends ConsumerState<ProductFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _barcodeController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _buyingPriceController;
  late final TextEditingController _sellingPriceController;
  late final TextEditingController _stockController;
  String? _selectedCategoryId;
  Timer? _priceTimer;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product?.name ?? '');
    _barcodeController = TextEditingController(
      text: widget.product?.barcodeQr ?? '',
    );
    _descriptionController = TextEditingController(
      text: widget.product?.description ?? '',
    );
    _buyingPriceController = TextEditingController(
      text: widget.product?.buyingPrice.toString() ?? '',
    );
    _sellingPriceController = TextEditingController(
      text: widget.product?.sellingPrice.toString() ?? '',
    );
    _stockController = TextEditingController(
      text: widget.product?.stockQuantity.toString() ?? '0',
    );
    _selectedCategoryId = widget.product?.categoryId;
  }

  @override
  void dispose() {
    _priceTimer?.cancel();
    _nameController.dispose();
    _barcodeController.dispose();
    _descriptionController.dispose();
    _buyingPriceController.dispose();
    _sellingPriceController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  void _scheduleSuggestedSellingPrice() {
    _priceTimer?.cancel();
    _priceTimer = Timer(const Duration(seconds: 1), () {
      final buyingPrice = double.tryParse(_buyingPriceController.text);
      if (buyingPrice == null || buyingPrice <= 0) {
        return;
      }

      final sellingPrice = PriceUtils.calculateSellingPrice(buyingPrice);
      _sellingPriceController.text = sellingPrice.toStringAsFixed(0);
    });
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesProvider);

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        padding: AppSpacing.pagePadding,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.product == null ? 'Nuevo Producto' : 'Editar Producto',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                label: 'Nombre del producto',
                controller: _nameController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'El nombre es requerido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: AppTextField(
                      label: 'Codigo de barras / QR',
                      controller: _barcodeController,
                    ),
                  ),
                  IconButton(
                    onPressed: () async {
                      final result = await Navigator.of(context).push<String>(
                        MaterialPageRoute(builder: (_) => const ScannerPage()),
                      );
                      if (result != null && result.isNotEmpty) {
                        _barcodeController.text = result;
                      }
                    },
                    icon: const Icon(Icons.qr_code_scanner),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              AppTextField(
                label: 'Descripcion',
                controller: _descriptionController,
                maxLines: 2,
              ),
              const SizedBox(height: AppSpacing.sm),
              categoriesAsync.when(
                loading: () => const LinearProgressIndicator(),
                error: (e, _) => Text('Error: $e'),
                data: (categories) => AppDropdown<String>(
                  label: 'Categoria',
                  value: _selectedCategoryId,
                  items: categories
                      .map(
                        (cat) => DropdownMenuItem(
                          value: cat.id,
                          child: Text(cat.name),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    setState(() => _selectedCategoryId = value);
                  },
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Expanded(
                    child: AppTextField(
                      label: 'Precio de compra',
                      controller: _buyingPriceController,
                      prefixText: '\$',
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Requerido';
                        if (double.tryParse(value) == null) {
                          return 'Numero invalido';
                        }
                        return null;
                      },
                      onChanged: (value) {
                        _scheduleSuggestedSellingPrice();
                      },
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: AppTextField(
                      label: 'Precio de venta',
                      controller: _sellingPriceController,
                      prefixText: '\$',
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Requerido';
                        if (double.tryParse(value) == null) {
                          return 'Numero invalido';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              AppTextField(
                label: 'Cantidad en stock',
                controller: _stockController,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: AppSpacing.lg),
              AppElevatedButton.primary(
                label: 'Guardar',
                onPressed: _saveProduct,
                fullWidth: true,
              ),
              const SizedBox(height: AppSpacing.md),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;

    final repo = ref.read(productRepositoryProvider);
    final product = Product(
      id: widget.product?.id ?? '',
      name: _nameController.text,
      barcodeQr: _barcodeController.text.isNotEmpty
          ? _barcodeController.text
          : null,
      description: _descriptionController.text.isNotEmpty
          ? _descriptionController.text
          : null,
      categoryId: _selectedCategoryId,
      buyingPrice: double.parse(_buyingPriceController.text),
      sellingPrice: double.parse(_sellingPriceController.text),
      stockQuantity: int.parse(_stockController.text),
      createdAt: widget.product?.createdAt ?? DateTime.now(),
    );

    if (widget.product == null) {
      await repo.createProduct(product);
    } else {
      await repo.updateProduct(product);
    }

    if (mounted) {
      ref.invalidate(inventoryProductsProvider);
      Navigator.of(context).pop();
    }
  }
}
