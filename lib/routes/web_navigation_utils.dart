// lib/routes/web_navigation_utils.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/ui/core/widgets/dialog/web_confirmation_dialog.dart';

/// Web-only logout handler using [WebConfirmationDialog].
/// Keeps [handleLogout] in navigation_utils.dart untouched for mobile.
Future<void> handleWebLogout(
  BuildContext context, {
  required String roleName,
}) async {
  final result = await WebConfirmationDialog.show(
    context,
    title: 'Confirm Logout',
    message: 'Are you sure you want to log out of the $roleName Portal?',
    confirmLabel: 'Logout',
    cancelLabel: 'Cancel',
    confirmIsDestructive: true,
  );

  if (result == ConfirmResult.confirmed && context.mounted) {
    await FirebaseAuth.instance.signOut();
  }
}