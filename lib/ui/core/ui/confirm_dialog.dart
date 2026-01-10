import 'package:flutter/material.dart';
import 'package:flutter_application_1/ui/core/ui/outline_app_button.dart';
import 'package:flutter_application_1/ui/core/ui/primary_button.dart';

Future<bool?> showConfirmDialog({
  required BuildContext context,
  required String title,
  required String message,
  String confirmText = 'Confirm',
  String cancelText = 'Cancel',
}) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        OutlineAppButton(
          text: cancelText,
          onPressed: () => Navigator.of(context).pop(false),
        ),
        PrimaryButton(
          onPressed: () => Navigator.of(context).pop(true),
          text: confirmText,
        ),
      ],
    ),
  );
}
