import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:meow_meow_store/core/theme/app_spacing.dart';
import 'package:meow_meow_store/features/inventory/data/models/product_model.dart';
import 'package:meow_meow_store/features/inventory/data/repositories/product_repository.dart';
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

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product?.name ?? '');
    _barcodeController =
        TextEditingController(text: widget.product?.barcodeQr ?? '');
    _descriptionController =
        TextEditingController(text: widget.product?.description ?? '');
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
    _nameController.dispose();
    _barcodeController.dispose();
    _descriptionController.dispose();
    _buyingPriceController.dispose();
    _sellingPriceController.dispose();
    _stockController.dispose();
    super.dispose();
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
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre del producto',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'El nombre es requerido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.sm),
              TextFormField(
                controller: _barcodeController,
                decoration: const InputDecoration(
                  labelText: 'Codigo de barras / QR',
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Descripcion',
                ),
                maxLines: 2,
              ),
              const SizedBox(height: AppSpacing.sm),
              categoriesAsync.when(
                loading: () => const LinearProgressIndicator(),
                error: (e, _) => Text('Error: $e'),
                data: (categories) => DropdownButtonFormField<String>(
                  initialValue: _selectedCategoryId,
                  decoration: const InputDecoration(
                    labelText: 'Categoria',
                  ),
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
                    child: TextFormField(
                      controller: _buyingPriceController,
                      decoration: const InputDecoration(
                        labelText: 'Precio de compra',
                        prefixText: '\$',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Requerido';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Numero invalido';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: TextFormField(
                      controller: _sellingPriceController,
                      decoration: const InputDecoration(
                        labelText: 'Precio de venta',
                        prefixText: '\$',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Requerido';
                        }
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
              TextFormField(
                controller: _stockController,
                decoration: const InputDecoration(
                  labelText: 'Cantidad en stock',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: AppSpacing.lg),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveProduct,
                  child: const Text('Guardar'),
                ),
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

    final repo = ProductRepository();
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
