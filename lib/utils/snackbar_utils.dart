import 'package:flutter/material.dart';

void showSnackbar(BuildContext context, String message, {bool isError = false}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.all(16),
      backgroundColor: isError ? Colors.red : Colors.teal,
      duration: const Duration(seconds: 2),
    ),
  );
}
