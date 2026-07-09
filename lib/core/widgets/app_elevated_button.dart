import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class AppElevatedButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool fullWidth;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final bool _isOutline;
  final bool _isGhost;

  const AppElevatedButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.fullWidth = false,
    this.icon,
    this.backgroundColor,
    this.foregroundColor,
  }) : _isOutline = false,
       _isGhost = false;

  const AppElevatedButton.primary({
    super.key,
    required this.label,
    required this.onPressed,
    this.fullWidth = false,
    this.icon,
  }) : backgroundColor = null,
       foregroundColor = null,
       _isOutline = false,
       _isGhost = false;

  const AppElevatedButton.danger({
    super.key,
    required this.label,
    required this.onPressed,
    this.fullWidth = false,
  }) : icon = null,
       backgroundColor = AppColors.error,
       foregroundColor = AppColors.onError,
       _isOutline = false,
       _isGhost = false;

  const AppElevatedButton.outline({
    super.key,
    required this.label,
    required this.onPressed,
    this.fullWidth = false,
  }) : icon = null,
       backgroundColor = Colors.transparent,
       foregroundColor = AppColors.primary,
       _isOutline = true,
       _isGhost = false;

  const AppElevatedButton.ghost({
    super.key,
    required this.label,
    required this.onPressed,
    this.fullWidth = false,
  }) : icon = null,
       backgroundColor = Colors.transparent,
       foregroundColor = AppColors.primary,
       _isOutline = false,
       _isGhost = true;

  @override
  Widget build(BuildContext context) {
    final button = ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
        side: _isOutline ? BorderSide(color: AppColors.primary) : null,
        elevation: _isGhost ? 0 : null,
        shadowColor: _isGhost ? Colors.transparent : null,
        surfaceTintColor: _isGhost ? Colors.transparent : null,
      ),
      child: icon != null
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 18),
                const SizedBox(width: 8),
                Text(label),
              ],
            )
          : Text(label),
    );

    if (fullWidth) {
      return SizedBox(width: double.infinity, child: button);
    }
    return button;
  }
}
