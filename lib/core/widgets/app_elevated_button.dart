import 'package:flutter/material.dart';

class AppElevatedButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool fullWidth;
  final IconData? icon;
  final bool _isOutline;
  final bool _isGhost;
  final bool _isDanger;

  const AppElevatedButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.fullWidth = false,
    this.icon,
  }) : _isOutline = false,
       _isGhost = false,
       _isDanger = false;

  const AppElevatedButton.primary({
    super.key,
    required this.label,
    required this.onPressed,
    this.fullWidth = false,
    this.icon,
  }) : _isOutline = false,
       _isGhost = false,
       _isDanger = false;

  const AppElevatedButton.danger({
    super.key,
    required this.label,
    required this.onPressed,
    this.fullWidth = false,
  }) : icon = null,
       _isOutline = false,
       _isGhost = false,
       _isDanger = true;

  const AppElevatedButton.outline({
    super.key,
    required this.label,
    required this.onPressed,
    this.fullWidth = false,
  }) : icon = null,
       _isOutline = true,
       _isGhost = false,
       _isDanger = false;

  const AppElevatedButton.ghost({
    super.key,
    required this.label,
    required this.onPressed,
    this.fullWidth = false,
  }) : icon = null,
       _isOutline = false,
       _isGhost = true,
       _isDanger = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    Color? bgColor;
    Color? fgColor;
    Color? sideColor;

    if (_isDanger) {
      bgColor = colorScheme.error;
      fgColor = colorScheme.onError;
    } else if (_isOutline) {
      bgColor = Colors.transparent;
      fgColor = colorScheme.primary;
      sideColor = colorScheme.primary;
    } else if (_isGhost) {
      bgColor = Colors.transparent;
      fgColor = colorScheme.primary;
    }

    final button = ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: bgColor,
        foregroundColor: fgColor,
        side: sideColor != null ? BorderSide(color: sideColor) : null,
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
