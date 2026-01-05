// lib/ui/core/dialog/dialog_action.dart

import 'package:flutter/material.dart';

/// Model for dialog action buttons
class DialogAction {
  final String label;
  final VoidCallback? onPressed;
  final bool isPrimary;
  final bool isLoading;
  final bool isDestructive;

  const DialogAction({
    required this.label,
    required this.onPressed,
    this.isPrimary = false,
    this.isLoading = false,
    this.isDestructive = false,
  });

  /// Create a primary action button (e.g., Save, Submit, Add)
  factory DialogAction.primary({
    required String label,
    required VoidCallback? onPressed,
    bool isLoading = false,
  }) {
    return DialogAction(
      label: label,
      onPressed: onPressed,
      isPrimary: true,
      isLoading: isLoading,
    );
  }

  /// Create a secondary action button (e.g., Close, Cancel)
  factory DialogAction.secondary({
    required String label,
    required VoidCallback? onPressed,
  }) {
    return DialogAction(
      label: label,
      onPressed: onPressed,
      isPrimary: false,
    );
  }

  /// Create a destructive action button (e.g., Delete, Remove)
  factory DialogAction.destructive({
    required String label,
    required VoidCallback? onPressed,
    bool isLoading = false,
  }) {
    return DialogAction(
      label: label,
      onPressed: onPressed,
      isDestructive: true,
      isLoading: isLoading,
    );
  }
}