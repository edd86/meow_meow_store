import 'package:flutter/material.dart';

enum SnackBarType { success, error, info }

class AppSnackBar {
  static void show(
    BuildContext context,
    String message, {
    SnackBarType type = SnackBarType.success,
    Duration? duration,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    final Color backgroundColor;
    final Color foregroundColor;
    final IconData icon;

    switch (type) {
      case SnackBarType.success:
        backgroundColor = colorScheme.primary;
        foregroundColor = colorScheme.onPrimary;
        icon = Icons.check_circle_outline;
      case SnackBarType.error:
        backgroundColor = colorScheme.error;
        foregroundColor = colorScheme.onError;
        icon = Icons.error_outline;
      case SnackBarType.info:
        backgroundColor = colorScheme.secondary;
        foregroundColor = colorScheme.onSecondary;
        icon = Icons.info_outline;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: foregroundColor, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(message, style: TextStyle(color: foregroundColor)),
            ),
          ],
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: const StadiumBorder(),
        duration: duration ?? const Duration(seconds: 3),
      ),
    );
  }
}
