import 'package:flutter/material.dart';

abstract final class AppSpacing {
  static const double unit = 4;
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double edgeMargin = 16;
  static const double gutter = 12;

  static const EdgeInsets pagePadding = EdgeInsets.all(md);
  static const EdgeInsets horizontalPadding = EdgeInsets.symmetric(
    horizontal: md,
  );
  static const EdgeInsets verticalPadding = EdgeInsets.symmetric(vertical: md);
}

abstract final class AppRadius {
  static const double sm = 4;
  static const double md = 8;
  static const double lg = 12;
  static const double xl = 16;
  static const double full = 9999;

  static BorderRadius get smAll => BorderRadius.circular(sm);
  static BorderRadius get mdAll => BorderRadius.circular(md);
  static BorderRadius get lgAll => BorderRadius.circular(lg);
  static BorderRadius get xlAll => BorderRadius.circular(xl);
  static BorderRadius get fullAll => BorderRadius.circular(full);

  static BorderRadius get topLg =>
      const BorderRadius.vertical(top: Radius.circular(lg));
  static BorderRadius get topXl =>
      const BorderRadius.vertical(top: Radius.circular(xl));
}

abstract final class AppElevation {
  static const double level0 = 0;
  static const double level1 = 1;
  static const double level2 = 2;
  static const double level3 = 4;
}
