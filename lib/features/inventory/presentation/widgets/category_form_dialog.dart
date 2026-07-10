import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:meow_meow_store/core/exceptions/app_exception.dart';
import 'package:meow_meow_store/core/extensions/context_x.dart';
import 'package:meow_meow_store/core/providers/repository_providers.dart';
import 'package:meow_meow_store/core/widgets/app_form_dialog_scaffold.dart';
import 'package:meow_meow_store/core/widgets/app_text_field.dart';
import 'package:meow_meow_store/features/inventory/data/models/category_model.dart';
import '../providers/inventory_provider.dart';

class CategoryFormDialog extends ConsumerStatefulWidget {
  const CategoryFormDialog({super.key});

  @override
  ConsumerState<CategoryFormDialog> createState() =>
      _CategoryFormDialogState();
}

class _CategoryFormDialogState extends ConsumerState<CategoryFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppFormDialogScaffold(
      title: 'Nueva Categoria',
      formKey: _formKey,
      onSave: _saveCategory,
      children: [
        AppTextField(
          label: 'Nombre de la categoria',
          controller: _nameController,
          validator: (value) {
            if (value == null || value.isEmpty) return 'El nombre es requerido';
            return null;
          },
        ),
        const SizedBox(height: 8),
        AppTextField(
          label: 'Descripcion (opcional)',
          controller: _descriptionController,
          maxLines: 2,
        ),
      ],
    );
  }

  Future<void> _saveCategory() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final repo = ref.read(categoryRepositoryProvider);
      final category = Category(
        id: '',
        name: _nameController.text,
        description: _descriptionController.text.isNotEmpty
            ? _descriptionController.text
            : null,
        createdAt: DateTime.now(),
      );

      await repo.createCategory(category);

      if (mounted) {
        ref.invalidate(categoriesProvider);
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        context.showAppSnackBar(
          e is AppException ? e.message : 'Error al guardar la categoría.',
          isError: true,
        );
      }
    }
  }
}
