import 'package:flutter/material.dart';
import 'package:flutter_application_1/routing/app_router.dart';

void showSnackbar(String message, {bool isError = false}) {
  rootScaffoldMessengerKey.currentState?.showSnackBar(
    SnackBar(
      content: Text(message),
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.all(16),
      backgroundColor: isError ? Colors.red : Colors.teal,
      duration: const Duration(seconds: 2),
    ),
  );
}
