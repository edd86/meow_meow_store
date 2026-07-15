import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:meow_meow_store/core/extensions/context_x.dart';
import 'package:meow_meow_store/core/providers/theme_provider.dart';
import 'package:meow_meow_store/core/theme/app_spacing.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final themeMode = ref.watch(themeModeProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Configuración')),
      body: ListView(
        padding: AppSpacing.pagePadding,
        children: [
          Text(
            'Apariencia',
            style: context.textTheme.titleMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Card(
            child: Column(
              children: [
                _SettingsTile(
                  icon: Icons.light_mode,
                  title: 'Tema',
                  subtitle: _themeModeLabel(themeMode),
                  onTap: () => _showThemeDialog(context, ref, themeMode),
                ),
                Divider(
                  height: 1,
                  color: colorScheme.outlineVariant,
                ),
                _SettingsTile(
                  icon: Icons.attach_money,
                  title: 'Moneda',
                  subtitle: 'Bs - Boliviano',
                  onTap: null,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Acerca de',
            style: context.textTheme.titleMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Card(
            child: Column(
              children: [
                _SettingsTile(
                  icon: Icons.store,
                  title: 'Meow Meow Store',
                  subtitle: 'v1.0.0 - CRM & POS System',
                  onTap: null,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _themeModeLabel(ThemeMode mode) {
    return switch (mode) {
      ThemeMode.light => 'Claro',
      ThemeMode.dark => 'Oscuro',
      ThemeMode.system => 'Sistema',
    };
  }

  void _showThemeDialog(
    BuildContext context,
    WidgetRef ref,
    ThemeMode current,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        final colorScheme = Theme.of(context).colorScheme;
        return AlertDialog(
          title: const Text('Seleccionar tema'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: ThemeMode.values.map((mode) {
              final isSelected = mode == current;
              return ListTile(
                title: Text(_themeModeLabel(mode)),
                leading: Icon(
                  isSelected
                      ? Icons.radio_button_checked
                      : Icons.radio_button_unchecked,
                  color: isSelected ? colorScheme.primary : null,
                ),
                onTap: () {
                  ref.read(themeModeProvider.notifier).state = mode;
                  Navigator.of(context).pop();
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return ListTile(
      leading: Icon(icon, color: colorScheme.primary),
      title: Text(title),
      subtitle: Text(
        subtitle,
        style: context.textTheme.bodySmall?.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
      ),
      trailing: onTap != null
          ? Icon(Icons.chevron_right, color: colorScheme.outline)
          : null,
      onTap: onTap,
    );
  }
}
