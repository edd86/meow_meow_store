import 'package:flutter/material.dart';

import '../widgets/app_snackbar.dart';

extension ContextX on BuildContext {
  ThemeData get theme => Theme.of(this);
  TextTheme get textTheme => theme.textTheme;
  ColorScheme get colorScheme => theme.colorScheme;

  void showAppSnackBar(String message, {bool isError = false}) {
    AppSnackBar.show(
      this,
      message,
      type: isError ? SnackBarType.error : SnackBarType.success,
    );
  }
}
