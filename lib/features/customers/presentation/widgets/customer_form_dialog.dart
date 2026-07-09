import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:meow_meow_store/core/theme/app_spacing.dart';
import 'package:meow_meow_store/features/customers/data/models/customer_model.dart';
import 'package:meow_meow_store/features/customers/data/repositories/customer_repository.dart';
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
                widget.customer == null ? 'Nuevo Cliente' : 'Editar Cliente',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: AppSpacing.md),
              TextFormField(
                controller: _firstNameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre',
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
                controller: _lastNameController,
                decoration: const InputDecoration(
                  labelText: 'Apellido',
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: AppSpacing.sm),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Telefono',
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: AppSpacing.lg),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveCustomer,
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

  Future<void> _saveCustomer() async {
    if (!_formKey.currentState!.validate()) return;

    final repo = CustomerRepository();
    final customer = Customer(
      id: widget.customer?.id ?? '',
      firstName: _firstNameController.text,
      lastName: _lastNameController.text.isNotEmpty
          ? _lastNameController.text
          : null,
      email:
          _emailController.text.isNotEmpty ? _emailController.text : null,
      phone:
          _phoneController.text.isNotEmpty ? _phoneController.text : null,
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
