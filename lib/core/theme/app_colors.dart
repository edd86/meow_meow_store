import 'package:flutter/material.dart';

abstract final class AppColors {
  static const Color seed = Color(0xFFFCC6C6);

  static final ColorScheme lightScheme = ColorScheme.fromSeed(
    seedColor: seed,
    brightness: Brightness.light,
  );

  static final ColorScheme darkScheme = ColorScheme.fromSeed(
    seedColor: seed,
    brightness: Brightness.dark,
  );

  // Light scheme shorthands
  static Color get primary => lightScheme.primary;
  static Color get onPrimary => lightScheme.onPrimary;
  static Color get primaryContainer => lightScheme.primaryContainer;
  static Color get onPrimaryContainer => lightScheme.onPrimaryContainer;
  static Color get secondary => lightScheme.secondary;
  static Color get onSecondary => lightScheme.onSecondary;
  static Color get secondaryContainer => lightScheme.secondaryContainer;
  static Color get onSecondaryContainer => lightScheme.onSecondaryContainer;
  static Color get tertiary => lightScheme.tertiary;
  static Color get onTertiary => lightScheme.onTertiary;
  static Color get tertiaryContainer => lightScheme.tertiaryContainer;
  static Color get onTertiaryContainer => lightScheme.onTertiaryContainer;
  static Color get error => lightScheme.error;
  static Color get onError => lightScheme.onError;
  static Color get errorContainer => lightScheme.errorContainer;
  static Color get onErrorContainer => lightScheme.onErrorContainer;
  static Color get surface => lightScheme.surface;
  static Color get onSurface => lightScheme.onSurface;
  static Color get onSurfaceVariant => lightScheme.onSurfaceVariant;
  static Color get outline => lightScheme.outline;
  static Color get outlineVariant => lightScheme.outlineVariant;
  static Color get inverseSurface => lightScheme.inverseSurface;
  static Color get inverseOnSurface => lightScheme.onInverseSurface;
  static Color get inversePrimary => lightScheme.inversePrimary;
  static Color get surfaceTint => lightScheme.surfaceTint;
  static Color get surfaceContainerLowest => lightScheme.surfaceContainerLowest;
  static Color get surfaceContainerLow => lightScheme.surfaceContainerLow;
  static Color get surfaceContainer => lightScheme.surfaceContainer;
  static Color get surfaceContainerHigh => lightScheme.surfaceContainerHigh;
  static Color get surfaceContainerHighest =>
      lightScheme.surfaceContainerHighest;
  static Color get surfaceDim => lightScheme.surfaceDim;
  static Color get surfaceBright => lightScheme.surfaceBright;
  static Color get background => surface;
  static Color get onBackground => onSurface;
  static Color get surfaceVariant => surfaceContainerHighest;
}
