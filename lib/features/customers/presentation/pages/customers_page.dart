import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:meow_meow_store/core/exceptions/app_exception.dart';
import 'package:meow_meow_store/core/extensions/context_x.dart';
import 'package:meow_meow_store/core/theme/app_colors.dart';
import 'package:meow_meow_store/core/theme/app_spacing.dart';
import 'package:meow_meow_store/core/widgets/app_error_view.dart';
import 'package:meow_meow_store/core/widgets/app_text_field.dart';
import '../providers/customers_provider.dart';
import '../widgets/customer_form_dialog.dart';

class CustomersPage extends ConsumerStatefulWidget {
  const CustomersPage({super.key});

  @override
  ConsumerState<CustomersPage> createState() => _CustomersPageState();
}

class _CustomersPageState extends ConsumerState<CustomersPage> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final customersAsync = ref.watch(customersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Clientes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_outlined),
            onPressed: () => _showCustomerDialog(context),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: AppSpacing.pagePadding,
            child: AppTextField(
              label: 'Buscar clientes...',
              controller: _searchController,
              onChanged: (value) {
                ref.read(customerSearchProvider.notifier).state = value;
              },
            ),
          ),
          Expanded(
            child: customersAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => AppErrorView(message: e is AppException ? e.message : 'Error al cargar clientes.'),
              data: (customers) {
                if (customers.isEmpty) {
                  return const Center(
                    child: Text('No hay clientes registrados'),
                  );
                }
                return _CustomerList(
                  customers: customers,
                  onEdit: (customer) =>
                      _showCustomerDialog(context, customer: customer),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showCustomerDialog(BuildContext context, {dynamic customer}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => CustomerFormDialog(customer: customer),
    );
  }
}

class _CustomerList extends StatelessWidget {
  final List customers;
  final dynamic Function(dynamic) onEdit;

  const _CustomerList({required this.customers, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: AppSpacing.pagePadding,
      itemCount: customers.length,
      separatorBuilder: (_, _) => const Divider(),
      itemBuilder: (context, index) {
        final customer = customers[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: AppColors.primaryContainer,
            child: Text(
              customer.firstName.substring(0, 1).toUpperCase(),
              style: const TextStyle(color: AppColors.onPrimaryContainer),
            ),
          ),
          title: Text(customer.fullName),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (customer.email != null)
                Text(customer.email!, style: context.textTheme.bodySmall),
              if (customer.phone != null)
                Text(customer.phone!, style: context.textTheme.bodySmall),
            ],
          ),
          trailing: IconButton(
            icon: const Icon(Icons.edit_outlined, size: 20),
            onPressed: () => onEdit(customer),
          ),
        );
      },
    );
  }
}
