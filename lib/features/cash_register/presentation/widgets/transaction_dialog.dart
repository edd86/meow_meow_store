import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:meow_meow_store/core/exceptions/app_exception.dart';
import 'package:meow_meow_store/core/extensions/context_x.dart';
import 'package:meow_meow_store/core/theme/app_spacing.dart';
import 'package:meow_meow_store/core/widgets/app_elevated_button.dart';
import 'package:meow_meow_store/core/widgets/app_text_field.dart';
import '../../data/models/transaction_category.dart';
import '../providers/cash_register_provider.dart';

class TransactionDialog extends ConsumerStatefulWidget {
  const TransactionDialog({super.key});

  @override
  ConsumerState<TransactionDialog> createState() => _TransactionDialogState();
}

class _TransactionDialogState extends ConsumerState<TransactionDialog> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  bool _isIncome = false;

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Form(
        key: _formKey,
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
              'Nueva Transaccion',
              style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            SegmentedButton<bool>(
              segments: const [
                ButtonSegment(
                  value: false,
                  label: Text('Egreso'),
                  icon: Icon(Icons.arrow_upward),
                ),
                ButtonSegment(
                  value: true,
                  label: Text('Ingreso'),
                  icon: Icon(Icons.arrow_downward),
                ),
              ],
              selected: {_isIncome},
              onSelectionChanged: (selected) {
                setState(() => _isIncome = selected.first);
              },
            ),
            const SizedBox(height: AppSpacing.lg),
            Autocomplete<TransactionCategory>(
              displayStringForOption: (option) => option.label,
              optionsBuilder: (textEditingValue) {
                if (textEditingValue.text.isEmpty) {
                  return TransactionCategory.values;
                }
                return TransactionCategory.values.where(
                  (c) => c.label.toLowerCase().contains(
                    textEditingValue.text.toLowerCase(),
                  ),
                );
              },
              onSelected: (category) {
                _descriptionController.text = category.label;
              },
              fieldViewBuilder: (context, controller, focusNode, onSubmitted) {
                return TextFormField(
                  controller: controller,
                  focusNode: focusNode,
                  style: TextStyle(color: colorScheme.onSurface),
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(labelText: 'Descripcion'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'La descripcion es requerida';
                    }
                    return null;
                  },
                  onFieldSubmitted: (_) => onSubmitted(),
                );
              },
            ),
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              label: 'Monto',
              controller: _amountController,
              keyboardType: TextInputType.number,
              prefixText: 'Bs',
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'El monto es requerido';
                }
                final amount = double.tryParse(value);
                if (amount == null || amount <= 0) {
                  return 'Ingrese un monto valido';
                }
                return null;
              },
            ),
            const SizedBox(height: AppSpacing.lg),
            SizedBox(
              width: double.infinity,
              child: AppElevatedButton.primary(
                label: 'Registrar Transaccion',
                onPressed: _saveTransaction,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
          ],
        ),
      ),
    );
  }

  Future<void> _saveTransaction() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final amount = double.parse(_amountController.text);
      await ref
          .read(cashRegisterProvider.notifier)
          .addTransaction(
            type: _isIncome ? 'income' : 'expense',
            amount: amount,
            description: _descriptionController.text,
          );

      ref.invalidate(sessionTransactionsProvider);

      if (mounted) {
        Navigator.of(context).pop();
        context.showAppSnackBar('Transaccion registrada exitosamente');
      }
    } catch (e) {
      if (mounted) {
        context.showAppSnackBar(
          e is AppException ? e.message : 'Error al registrar la transaccion.',
          isError: true,
        );
      }
    }
  }
}
