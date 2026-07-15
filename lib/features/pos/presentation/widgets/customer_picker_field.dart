import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:meow_meow_store/core/providers/repository_providers.dart';
import 'package:meow_meow_store/features/customers/data/models/customer_model.dart';

class CustomerPickerField extends ConsumerStatefulWidget {
  final Customer? selectedCustomer;
  final ValueChanged<Customer?> onCustomerSelected;
  final VoidCallback? onCreateNew;

  const CustomerPickerField({
    super.key,
    this.selectedCustomer,
    required this.onCustomerSelected,
    this.onCreateNew,
  });

  @override
  ConsumerState<CustomerPickerField> createState() =>
      _CustomerPickerFieldState();
}

class _CustomerPickerFieldState extends ConsumerState<CustomerPickerField> {
  final _searchController = TextEditingController();
  final _focusNode = FocusNode();
  List<Customer> _results = [];
  bool _isLoading = false;
  Timer? _debounce;
  bool _showDropdown = false;

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _debounce?.cancel();
    if (query.isEmpty) {
      setState(() {
        _results = [];
        _showDropdown = false;
      });
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 300), () {
      _searchCustomers(query);
    });
  }

  Future<void> _searchCustomers(String query) async {
    if (query.isEmpty) return;
    setState(() => _isLoading = true);
    try {
      final repo = ref.read(customerRepositoryProvider);
      final results = await repo.searchCustomers(query);
      if (mounted) {
        setState(() {
          _results = results;
          _showDropdown = true;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _results = [];
          _showDropdown = true;
        });
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _results = [];
      _showDropdown = false;
    });
    _focusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (widget.selectedCustomer != null) {
      return InputChip(
        avatar: CircleAvatar(
          backgroundColor: colorScheme.primaryContainer,
          child: Text(
            widget.selectedCustomer!.firstName.substring(0, 1).toUpperCase(),
            style: TextStyle(
              color: colorScheme.onPrimaryContainer,
              fontSize: 12,
            ),
          ),
        ),
        label: Text(widget.selectedCustomer!.fullName),
        deleteIcon: const Icon(Icons.close, size: 18),
        onDeleted: () {
          widget.onCustomerSelected(null);
        },
        backgroundColor: colorScheme.primaryContainer.withValues(alpha: 0.3),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
          controller: _searchController,
          focusNode: _focusNode,
          onChanged: _onSearchChanged,
          decoration: InputDecoration(
            labelText: 'Buscar cliente (opcional)',
            prefixIcon: _isLoading
                ? const Padding(
                    padding: EdgeInsets.all(12),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : const Icon(Icons.person_search),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: _clearSearch,
                  )
                : null,
          ),
        ),
        if (_showDropdown) ...[
          const SizedBox(height: 8),
          Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              constraints: const BoxConstraints(maxHeight: 240),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 4),
                shrinkWrap: true,
                children: [
                  ListTile(
                    dense: true,
                    leading: const Icon(Icons.person_off_outlined),
                    title: const Text('Sin cliente'),
                    onTap: () {
                      widget.onCustomerSelected(null);
                      _clearSearch();
                    },
                  ),
                  if (widget.onCreateNew != null) ...[
                    const Divider(height: 1),
                    ListTile(
                      dense: true,
                      leading: Icon(
                        Icons.person_add,
                        color: colorScheme.primary,
                      ),
                      title: Text(
                        'Nuevo cliente',
                        style: TextStyle(color: colorScheme.primary),
                      ),
                      onTap: () {
                        _clearSearch();
                        widget.onCreateNew!.call();
                      },
                    ),
                  ],
                  if (_results.isNotEmpty) const Divider(height: 1),
                  ..._results.map(
                    (customer) => ListTile(
                      dense: true,
                      leading: CircleAvatar(
                        backgroundColor: colorScheme.primaryContainer,
                        child: Text(
                          customer.firstName.substring(0, 1).toUpperCase(),
                          style: TextStyle(
                            color: colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ),
                      title: Text(customer.fullName),
                      subtitle: Text(
                        customer.phone ?? customer.email ?? '',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      onTap: () {
                        widget.onCustomerSelected(customer);
                        _clearSearch();
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}
