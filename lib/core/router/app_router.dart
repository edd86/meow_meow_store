import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/dashboard/presentation/pages/dashboard_page.dart';
import '../../features/inventory/presentation/pages/inventory_page.dart';
import '../../features/customers/presentation/pages/customers_page.dart';
import '../../features/pos/presentation/pages/pos_page.dart';
import '../../features/cash_register/presentation/pages/cash_register_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../../features/reports/presentation/pages/reports_page.dart';
import '../../features/reports/presentation/pages/sales_report_page.dart';
import '../../features/reports/presentation/pages/inventory_report_page.dart';
import '../../shared/widgets/shell_scaffold.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      ShellRoute(
        builder: (context, state, child) {
          return ShellScaffold(child: child);
        },
        routes: [
          GoRoute(
            path: '/',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: DashboardPage()),
          ),
          GoRoute(
            path: '/pos',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: POSPage()),
          ),
          GoRoute(
            path: '/inventory',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: InventoryPage()),
          ),
          GoRoute(
            path: '/customers',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: CustomersPage()),
          ),
          GoRoute(
            path: '/cash-register',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: CashRegisterPage()),
          ),
          GoRoute(
            path: '/settings',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: SettingsPage()),
          ),
          GoRoute(
            path: '/reports',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: ReportsPage()),
            routes: [
              GoRoute(
                path: 'sales',
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: SalesReportPage()),
              ),
              GoRoute(
                path: 'inventory',
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: InventoryReportPage()),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
