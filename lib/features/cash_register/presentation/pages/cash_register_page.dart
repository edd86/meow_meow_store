import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:meow_meow_store/core/exceptions/app_exception.dart';
import 'package:meow_meow_store/core/extensions/context_x.dart';
import 'package:meow_meow_store/core/theme/app_spacing.dart';
import 'package:meow_meow_store/core/widgets/app_error_view.dart';
import 'package:meow_meow_store/core/widgets/app_elevated_button.dart';
import 'package:meow_meow_store/core/widgets/app_text_field.dart';
import '../providers/cash_register_provider.dart';

class CashRegisterPage extends ConsumerWidget {
  const CashRegisterPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionAsync = ref.watch(cashRegisterProvider);
    final transactionsAsync = ref.watch(sessionTransactionsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Caja')),
      body: sessionAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => AppErrorView(message: e is AppException ? e.message : 'Error al cargar sesión de caja.'),
        data: (session) {
          if (session == null) {
            return _ClosedState(onOpen: () => _showOpenDialog(context, ref));
          }
          return _OpenState(
            session: session,
            transactionsAsync: transactionsAsync,
            onClose: () => _showCloseDialog(context, ref),
          );
        },
      ),
    );
  }

  void _showOpenDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController(text: '0');
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Abrir Caja'),
        content: AppTextField(
          label: 'Monto de apertura',
          controller: controller,
          keyboardType: TextInputType.number,
          prefixText: '\$',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          AppElevatedButton.primary(
            label: 'Abrir',
            onPressed: () async {
              final amount = double.tryParse(controller.text) ?? 0;
              await ref.read(cashRegisterProvider.notifier).openSession(amount);
              if (context.mounted) Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  void _showCloseDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cerrar Caja'),
        content: AppTextField(
          label: 'Monto fisico contado',
          controller: controller,
          keyboardType: TextInputType.number,
          prefixText: '\$',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          AppElevatedButton.primary(
            label: 'Cerrar',
            onPressed: () async {
              final amount = double.tryParse(controller.text) ?? 0;
              await ref
                  .read(cashRegisterProvider.notifier)
                  .closeSession(amount);
              if (context.mounted) Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }
}

class _ClosedState extends StatelessWidget {
  final VoidCallback onOpen;

  const _ClosedState({required this.onOpen});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.lock_outline, size: 64, color: colorScheme.outline),
          const SizedBox(height: AppSpacing.md),
          Text('Caja Cerrada', style: context.textTheme.headlineMedium),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Abre la caja para comenzar a operar',
            style: context.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          AppElevatedButton.primary(
            label: 'Abrir Caja',
            onPressed: onOpen,
            icon: Icons.lock_open,
          ),
        ],
      ),
    );
  }
}

class _OpenState extends ConsumerWidget {
  final dynamic session;
  final AsyncValue<List> transactionsAsync;
  final VoidCallback onClose;

  const _OpenState({
    required this.session,
    required this.transactionsAsync,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final currencyFormat = NumberFormat.currency(locale: 'es_MX', symbol: '\$');

    return Column(
      children: [
        Container(
          padding: AppSpacing.pagePadding,
          color: colorScheme.primaryContainer,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Sesion Abierta',
                    style: context.textTheme.titleMedium?.copyWith(
                      color: colorScheme.onPrimaryContainer,
                    ),
                  ),
                  Text(
                    'Monto de apertura: ${currencyFormat.format(session.openingAmount)}',
                    style: context.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onPrimaryContainer,
                    ),
                  ),
                ],
              ),
              AppElevatedButton.danger(
                label: 'Cerrar Caja',
                onPressed: onClose,
              ),
            ],
          ),
        ),
        Expanded(
          child: transactionsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => AppErrorView(message: e is AppException ? e.message : 'Error al cargar transacciones.'),
            data: (transactions) {
              if (transactions.isEmpty) {
                return const Center(
                  child: Text('No hay transacciones en esta sesion'),
                );
              }
              return ListView.separated(
                padding: AppSpacing.pagePadding,
                itemCount: transactions.length,
                separatorBuilder: (_, _) => const Divider(),
                itemBuilder: (context, index) {
                  final tx = transactions[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: tx.isIncome
                          ? colorScheme.primaryContainer
                          : colorScheme.errorContainer,
                      child: Icon(
                        tx.isIncome ? Icons.arrow_downward : Icons.arrow_upward,
                        color: tx.isIncome
                            ? colorScheme.onPrimaryContainer
                            : colorScheme.onErrorContainer,
                        size: 20,
                      ),
                    ),
                    title: Text(tx.description),
                    subtitle: Text(
                      DateFormat('dd/MM/yyyy HH:mm').format(tx.createdAt),
                    ),
                    trailing: Text(
                      '${tx.isIncome ? '+' : '-'}${currencyFormat.format(tx.amount)}',
                      style: context.textTheme.titleMedium?.copyWith(
                        color: tx.isIncome
                            ? colorScheme.primary
                            : colorScheme.error,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
