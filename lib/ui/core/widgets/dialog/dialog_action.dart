// lib/ui/core/dialog/dialog_action.dart

import 'package:flutter/material.dart';

class DialogAction {
  final String label;
  final VoidCallback? onPressed;
  final bool isPrimary;
  final bool isDestructive;
  final bool isLoading;
  final bool isDisabled;

  const DialogAction({
    required this.label,
    this.onPressed,
    this.isPrimary = false,
    this.isDestructive = false,
    this.isLoading = false,
    this.isDisabled = false,
  });

  factory DialogAction.primary({
    required String label,
    VoidCallback? onPressed,
    bool isLoading = false,
    bool isDisabled = false,
  }) =>
      DialogAction(
        label: label,
        onPressed: onPressed,
        isPrimary: true,
        isLoading: isLoading,
        isDisabled: isDisabled,
      );

  factory DialogAction.secondary({
    required String label,
    VoidCallback? onPressed,
  }) =>
      DialogAction(label: label, onPressed: onPressed);

  factory DialogAction.destructive({
    required String label,
    VoidCallback? onPressed,
    bool isLoading = false,
    bool isDisabled = false,
  }) =>
      DialogAction(
        label: label,
        onPressed: onPressed,
        isDestructive: true,
        isLoading: isLoading,
        isDisabled: isDisabled,
      );
}