import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:meow_meow_store/core/exceptions/app_exception.dart';
import 'package:meow_meow_store/core/extensions/context_x.dart';
import 'package:meow_meow_store/core/providers/repository_providers.dart';
import 'package:meow_meow_store/core/theme/app_spacing.dart';
import 'package:meow_meow_store/core/utils/currency_utils.dart';
import 'package:meow_meow_store/core/widgets/app_error_view.dart';
import 'package:meow_meow_store/core/widgets/app_loading_view.dart';
import 'package:meow_meow_store/features/sales/data/models/sale_model.dart';

class SalesReportPage extends ConsumerStatefulWidget {
  const SalesReportPage({super.key});

  @override
  ConsumerState<SalesReportPage> createState() => _SalesReportPageState();
}

class _SalesReportPageState extends ConsumerState<SalesReportPage> {
  DateTime? _dateFrom;
  DateTime? _dateTo;
  String? _statusFilter;
  late Future<List<Sale>> _salesFuture;

  @override
  void initState() {
    super.initState();
    _salesFuture = _loadSales();
  }

  Future<List<Sale>> _loadSales() async {
    final saleRepo = ref.read(saleRepositoryProvider);
    return saleRepo.getSales(status: _statusFilter);
  }

  void _applyFilters() {
    setState(() {
      _salesFuture = _loadSales();
    });
  }

  List<Sale> _filterByDate(List<Sale> sales) {
    return sales.where((sale) {
      if (_dateFrom != null && sale.createdAt.isBefore(_dateFrom!)) {
        return false;
      }
      if (_dateTo != null) {
        final endOfDay = _dateTo!.add(const Duration(days: 1));
        if (sale.createdAt.isAfter(endOfDay)) return false;
      }
      return true;
    }).toList();
  }

  Future<void> _pickDate({required bool isFrom}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isFrom ? (_dateFrom ?? DateTime.now()) : (_dateTo ?? DateTime.now()),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        if (isFrom) {
          _dateFrom = picked;
        } else {
          _dateTo = picked;
        }
      });
      _applyFilters();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Scaffold(
      appBar: AppBar(title: const Text('Reporte de Ventas')),
      body: Column(
        children: [
          Container(
            padding: AppSpacing.pagePadding,
            color: colorScheme.surfaceContainerLow,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Filtros',
                  style: context.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _pickDate(isFrom: true),
                        icon: const Icon(Icons.calendar_today, size: 18),
                        label: Text(
                          _dateFrom != null
                              ? dateFormat.format(_dateFrom!)
                              : 'Desde',
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _pickDate(isFrom: false),
                        icon: const Icon(Icons.calendar_today, size: 18),
                        label: Text(
                          _dateTo != null
                              ? dateFormat.format(_dateTo!)
                              : 'Hasta',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                SegmentedButton<String?>(
                  segments: const [
                    ButtonSegment(value: null, label: Text('Todas')),
                    ButtonSegment(value: 'completed', label: Text('Completadas')),
                    ButtonSegment(value: 'pending', label: Text('Pendientes')),
                    ButtonSegment(value: 'cancelled', label: Text('Canceladas')),
                  ],
                  selected: {_statusFilter},
                  onSelectionChanged: (selection) {
                    setState(() => _statusFilter = selection.first);
                    _applyFilters();
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Sale>>(
              future: _salesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const AppLoadingView();
                }
                if (snapshot.hasError) {
                  return AppErrorView(
                    message: snapshot.error is AppException
                        ? (snapshot.error as AppException).message
                        : 'Error al cargar ventas.',
                  );
                }

                final allSales = snapshot.data ?? [];
                final filtered = _filterByDate(allSales);
                final completedSales =
                    filtered.where((s) => s.isCompleted).toList();
                final totalRevenue = completedSales.fold<double>(
                  0,
                  (sum, s) => sum + s.totalAmount,
                );
                final avgSale = completedSales.isNotEmpty
                    ? totalRevenue / completedSales.length
                    : 0.0;

                return Column(
                  children: [
                    Container(
                      padding: AppSpacing.horizontalPadding,
                      child: Row(
                        children: [
                          _SummaryChip(
                            label: 'Total',
                            value: CurrencyUtils.format.format(totalRevenue),
                            color: colorScheme.primary,
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          _SummaryChip(
                            label: 'Promedio',
                            value: CurrencyUtils.format.format(avgSale),
                            color: colorScheme.secondary,
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          _SummaryChip(
                            label: 'Ventas',
                            value: completedSales.length.toString(),
                            color: colorScheme.tertiary,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Expanded(
                      child: filtered.isEmpty
                          ? const Center(
                              child: Text('No hay ventas en este período.'),
                            )
                          : ListView.separated(
                              padding: AppSpacing.pagePadding,
                              itemCount: filtered.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: AppSpacing.xs),
                              itemBuilder: (context, index) {
                                final sale = filtered[index];
                                return _SaleTile(sale: sale);
                              },
                            ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _SummaryChip({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xs,
          ),
          child: Column(
            children: [
              Text(
                value,
                style: context.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
              Text(
                label,
                style: context.textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SaleTile extends StatelessWidget {
  final Sale sale;

  const _SaleTile({required this.sale});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _statusColor(sale.status, colorScheme).withValues(alpha: 0.1),
          child: Icon(
            _statusIcon(sale.status),
            color: _statusColor(sale.status, colorScheme),
            size: 20,
          ),
        ),
        title: Text(CurrencyUtils.format.format(sale.totalAmount)),
        subtitle: Text(dateFormat.format(sale.createdAt)),
        trailing: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xs,
          ),
          decoration: BoxDecoration(
            color: _statusColor(sale.status, colorScheme).withValues(alpha: 0.1),
            borderRadius: AppRadius.smAll,
          ),
          child: Text(
            _statusLabel(sale.status),
            style: context.textTheme.labelSmall?.copyWith(
              color: _statusColor(sale.status, colorScheme),
            ),
          ),
        ),
      ),
    );
  }

  Color _statusColor(String status, ColorScheme cs) {
    return switch (status) {
      'completed' => cs.primary,
      'pending' => Colors.orange,
      'cancelled' => cs.error,
      _ => cs.outline,
    };
  }

  IconData _statusIcon(String status) {
    return switch (status) {
      'completed' => Icons.check_circle,
      'pending' => Icons.schedule,
      'cancelled' => Icons.cancel,
      _ => Icons.help_outline,
    };
  }

  String _statusLabel(String status) {
    return switch (status) {
      'completed' => 'Completada',
      'pending' => 'Pendiente',
      'cancelled' => 'Cancelada',
      _ => status,
    };
  }
}
