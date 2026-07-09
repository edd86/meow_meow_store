import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:meow_meow_store/core/theme/app_colors.dart';

class ShellScaffold extends StatelessWidget {
  final Widget child;

  const ShellScaffold({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;

    int selectedIndex = 0;
    if (location.startsWith('/pos')) {
      selectedIndex = 1;
    } else if (location.startsWith('/inventory')) {
      selectedIndex = 2;
    } else if (location.startsWith('/customers')) {
      selectedIndex = 3;
    } else if (location.startsWith('/cash-register')) {
      selectedIndex = 4;
    }

    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) {
          switch (index) {
            case 0:
              context.go('/');
            case 1:
              context.go('/pos');
            case 2:
              context.go('/inventory');
            case 3:
              context.go('/customers');
            case 4:
              context.go('/cash-register');
          }
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard, color: AppColors.onPrimaryContainer),
            label: 'Inicio',
          ),
          NavigationDestination(
            icon: Icon(Icons.point_of_sale_outlined),
            selectedIcon: Icon(Icons.point_of_sale, color: AppColors.onPrimaryContainer),
            label: 'POS',
          ),
          NavigationDestination(
            icon: Icon(Icons.inventory_2_outlined),
            selectedIcon: Icon(Icons.inventory_2, color: AppColors.onPrimaryContainer),
            label: 'Inventario',
          ),
          NavigationDestination(
            icon: Icon(Icons.people_outline),
            selectedIcon: Icon(Icons.people, color: AppColors.onPrimaryContainer),
            label: 'Clientes',
          ),
          NavigationDestination(
            icon: Icon(Icons.payments_outlined),
            selectedIcon: Icon(Icons.payments, color: AppColors.onPrimaryContainer),
            label: 'Caja',
          ),
        ],
      ),
    );
  }
}
