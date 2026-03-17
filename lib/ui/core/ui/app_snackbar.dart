import 'package:flutter/material.dart';
import 'package:flutter_application_1/ui/core/themes/app_theme.dart';

enum SnackbarType { success, error, info }

class AppSnackbar {
  static const double _defaultBottomSpacing = 24;
  static void show(
    BuildContext context, {
    required String message,
    SnackbarType type = SnackbarType.info,
    Duration duration = const Duration(seconds: 3),
    SnackBarAction? action,
  }) {
    final viewInsets = MediaQuery.of(context).viewInsets;
    final viewPadding = MediaQuery.of(context).viewPadding;
    final snackBar = SnackBar(
      content: Row(
        children: [
          Icon(_icon(type), color: Colors.white),
          const SizedBox(width: 12),
          Expanded(
            child: Text(message, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
      backgroundColor: _backgroundColor(type),
      duration: duration,
      behavior: SnackBarBehavior.floating,
      margin: EdgeInsets.fromLTRB(
        16,
        0,
        16,
        viewPadding.bottom + viewInsets.bottom + _defaultBottomSpacing,
      ),
      width: MediaQuery.of(context).size.width > 600
          ? 600 // max width on wide screens
          : null,
    );

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(snackBar);
  }

  static void success(BuildContext context, String message) {
    show(context, message: message, type: SnackbarType.success);
  }

  static void error(BuildContext context, String message) {
    show(context, message: message, type: SnackbarType.error);
  }

  static void info(BuildContext context, String message) {
    show(context, message: message, type: SnackbarType.info);
  }

  static Color _backgroundColor(SnackbarType type) {
    switch (type) {
      case SnackbarType.success:
        return AppColors.green100;
      case SnackbarType.error:
        return AppColors.error;
      case SnackbarType.info:
        return AppColors.blueForeground;
    }
  }

  static IconData _icon(SnackbarType type) {
    switch (type) {
      case SnackbarType.success:
        return Icons.check_circle;
      case SnackbarType.error:
        return Icons.error;
      case SnackbarType.info:
        return Icons.info;
    }
  }
}
