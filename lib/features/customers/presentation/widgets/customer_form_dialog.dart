import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:meow_meow_store/core/providers/repository_providers.dart';
import 'package:meow_meow_store/core/widgets/app_form_dialog_scaffold.dart';
import 'package:meow_meow_store/core/widgets/app_text_field.dart';
import 'package:meow_meow_store/features/customers/data/models/customer_model.dart';
import '../providers/customers_provider.dart';

class CustomerFormDialog extends ConsumerStatefulWidget {
  final Customer? customer;

  const CustomerFormDialog({super.key, this.customer});

  @override
  ConsumerState<CustomerFormDialog> createState() =>
      _CustomerFormDialogState();
}

class _CustomerFormDialogState extends ConsumerState<CustomerFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    _firstNameController =
        TextEditingController(text: widget.customer?.firstName ?? '');
    _lastNameController =
        TextEditingController(text: widget.customer?.lastName ?? '');
    _emailController =
        TextEditingController(text: widget.customer?.email ?? '');
    _phoneController =
        TextEditingController(text: widget.customer?.phone ?? '');
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppFormDialogScaffold(
      title:
          widget.customer == null ? 'Nuevo Cliente' : 'Editar Cliente',
      formKey: _formKey,
      onSave: _saveCustomer,
      children: [
        AppTextField(
          label: 'Nombre',
          controller: _firstNameController,
          validator: (value) {
            if (value == null || value.isEmpty) return 'El nombre es requerido';
            return null;
          },
        ),
        const SizedBox(height: 8),
        AppTextField(
          label: 'Apellido',
          controller: _lastNameController,
        ),
        const SizedBox(height: 8),
        AppTextField(
          label: 'Email',
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 8),
        AppTextField(
          label: 'Telefono',
          controller: _phoneController,
          keyboardType: TextInputType.phone,
        ),
      ],
    );
  }

  Future<void> _saveCustomer() async {
    if (!_formKey.currentState!.validate()) return;

    final repo = ref.read(customerRepositoryProvider);
    final customer = Customer(
      id: widget.customer?.id ?? '',
      firstName: _firstNameController.text,
      lastName:
          _lastNameController.text.isNotEmpty ? _lastNameController.text : null,
      email: _emailController.text.isNotEmpty ? _emailController.text : null,
      phone: _phoneController.text.isNotEmpty ? _phoneController.text : null,
      createdAt: widget.customer?.createdAt ?? DateTime.now(),
    );

    if (widget.customer == null) {
      await repo.createCustomer(customer);
    } else {
      await repo.updateCustomer(customer);
    }

    if (mounted) {
      ref.invalidate(customersProvider);
      Navigator.of(context).pop();
    }
  }
}
