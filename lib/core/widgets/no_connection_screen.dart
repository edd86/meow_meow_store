import 'package:flutter/material.dart';
import 'package:meow_meow_store/core/extensions/context_x.dart';
import 'package:meow_meow_store/core/theme/app_spacing.dart';
import 'package:meow_meow_store/core/widgets/app_loading_view.dart';

class NoConnectionScreen extends StatelessWidget {
  const NoConnectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Center(
        child: Padding(
          padding: AppSpacing.pagePadding,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.wifi_off_rounded, size: 80, color: colorScheme.error),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'Sin conexión a internet',
                style: context.textTheme.headlineMedium?.copyWith(
                  color: colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Por favor, verifica tu conexión para continuar usando la aplicación.',
                style: context.textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xl),
              const AppLoadingView(size: 48),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Esperando conexión...',
                style: context.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
