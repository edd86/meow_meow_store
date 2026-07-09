import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:meow_meow_store/core/extensions/context_x.dart';
import 'package:meow_meow_store/core/theme/app_colors.dart';
import 'package:meow_meow_store/core/theme/app_spacing.dart';
import '../providers/dashboard_provider.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(dashboardStatsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Meow Meow Store'),
      ),
      body: statsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (stats) => SingleChildScrollView(
          padding: AppSpacing.pagePadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Resumen del Dia',
                style: context.textTheme.headlineSmall,
              ),
              const SizedBox(height: AppSpacing.md),
              _StatsGrid(stats: stats),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'Acciones Rapidas',
                style: context.textTheme.headlineSmall,
              ),
              const SizedBox(height: AppSpacing.md),
              _QuickActions(),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatsGrid extends StatelessWidget {
  final DashboardStats stats;

  const _StatsGrid({required this.stats});

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'es_MX', symbol: '\$');

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: context.isMobile ? 2 : 4,
      crossAxisSpacing: AppSpacing.gutter,
      mainAxisSpacing: AppSpacing.gutter,
      childAspectRatio: 1.5,
      children: [
        _StatCard(
          title: 'Ventas Hoy',
          value: currencyFormat.format(stats.todaySales),
          icon: Icons.trending_up,
          color: AppColors.primary,
        ),
        _StatCard(
          title: 'Transacciones',
          value: stats.todayTransactions.toString(),
          icon: Icons.receipt_long,
          color: AppColors.secondary,
        ),
        _StatCard(
          title: 'Productos',
          value: stats.totalProducts.toString(),
          icon: Icons.inventory_2,
          color: AppColors.tertiary,
        ),
        _StatCard(
          title: 'Clientes',
          value: stats.totalCustomers.toString(),
          icon: Icons.people,
          color: AppColors.primary,
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: AppSpacing.pagePadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, color: color, size: 28),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: context.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  title,
                  style: context.textTheme.bodySmall?.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: context.isMobile ? 2 : 3,
      crossAxisSpacing: AppSpacing.gutter,
      mainAxisSpacing: AppSpacing.gutter,
      childAspectRatio: 2.5,
      children: [
        _ActionCard(
          title: 'Nueva Venta',
          icon: Icons.add_shopping_cart,
          onTap: () => Navigator.of(context).pushNamed('/pos'),
        ),
        _ActionCard(
          title: 'Inventario',
          icon: Icons.inventory_2,
          onTap: () => Navigator.of(context).pushNamed('/inventory'),
        ),
        _ActionCard(
          title: 'Clientes',
          icon: Icons.people,
          onTap: () => Navigator.of(context).pushNamed('/customers'),
        ),
      ],
    );
  }
}

class _ActionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const _ActionCard({
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: AppSpacing.horizontalPadding,
          child: Row(
            children: [
              Icon(icon, color: AppColors.primary),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  title,
                  style: context.textTheme.titleMedium,
                ),
              ),
              const Icon(
                Icons.chevron_right,
                color: AppColors.outline,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
