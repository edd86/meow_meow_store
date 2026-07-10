import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/exceptions/app_exception.dart';
import '../../../../core/providers/repository_providers.dart';

class DashboardStats {
  final double todaySales;
  final int todayTransactions;
  final int totalProducts;
  final int totalCustomers;

  const DashboardStats({
    required this.todaySales,
    required this.todayTransactions,
    required this.totalProducts,
    required this.totalCustomers,
  });
}

final dashboardStatsProvider = FutureProvider<DashboardStats>((ref) async {
  final saleRepo = ref.watch(saleRepositoryProvider);
  final productRepo = ref.watch(productRepositoryProvider);
  final customerRepo = ref.watch(customerRepositoryProvider);

  try {
    final results = await Future.wait([
      saleRepo.getSales(),
      productRepo.getProducts(),
      customerRepo.getCustomers(),
    ]);

    final sales = results[0] as List;
    final products = results[1] as List;
    final customers = results[2] as List;

    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);

    final todaySalesList = sales.where((sale) {
      return sale.createdAt.isAfter(todayStart) && sale.status == 'completed';
    }).toList();

    final todaySalesTotal = todaySalesList.fold<double>(
      0,
      (sum, sale) => sum + sale.totalAmount,
    );

    return DashboardStats(
      todaySales: todaySalesTotal,
      todayTransactions: todaySalesList.length,
      totalProducts: products.length,
      totalCustomers: customers.length,
    );
  } catch (e) {
    throw ServerException.fromSupabase(e);
  }
});
