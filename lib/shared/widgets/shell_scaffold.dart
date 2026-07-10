import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ShellScaffold extends StatelessWidget {
  final Widget child;

  const ShellScaffold({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
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
        destinations: [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(
              Icons.dashboard,
              color: colorScheme.onPrimaryContainer,
            ),
            label: 'Inicio',
          ),
          NavigationDestination(
            icon: Icon(Icons.point_of_sale_outlined),
            selectedIcon: Icon(
              Icons.point_of_sale,
              color: colorScheme.onPrimaryContainer,
            ),
            label: 'POS',
          ),
          NavigationDestination(
            icon: Icon(Icons.inventory_2_outlined),
            selectedIcon: Icon(
              Icons.inventory_2,
              color: colorScheme.onPrimaryContainer,
            ),
            label: 'Inventario',
          ),
          NavigationDestination(
            icon: Icon(Icons.people_outline),
            selectedIcon: Icon(
              Icons.people,
              color: colorScheme.onPrimaryContainer,
            ),
            label: 'Clientes',
          ),
          NavigationDestination(
            icon: Icon(Icons.payments_outlined),
            selectedIcon: Icon(
              Icons.payments,
              color: colorScheme.onPrimaryContainer,
            ),
            label: 'Caja',
          ),
        ],
      ),
    );
  }
}
