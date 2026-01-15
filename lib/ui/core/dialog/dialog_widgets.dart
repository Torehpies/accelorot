// lib/ui/core/dialog/dialog_widgets.dart

import 'package:flutter/material.dart';
import 'dialog_action.dart';
import '../themes/web_text_styles.dart';
import '../themes/web_colors.dart';

// ==================== HEADER ====================

/// Reusable dialog header with title, subtitle, and close button
class DialogHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool canClose;

  const DialogHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.canClose = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: WebColors.cardBorder),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: WebTextStyles.sectionTitle,
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: WebTextStyles.bodyMediumGray,
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: canClose ? () => Navigator.of(context).pop() : null,
            color: WebColors.textSecondary,
            iconSize: 20,
          ),
        ],
      ),
    );
  }
}

// ==================== CONTENT ====================

/// Scrollable content wrapper for dialogs
class DialogContent extends StatelessWidget {
  final Widget child;

  const DialogContent({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: child,
    );
  }
}

// ==================== FOOTER ====================

/// Reusable dialog footer with action buttons
class DialogFooter extends StatelessWidget {
  final List<DialogAction> actions;

  const DialogFooter({
    super.key,
    required this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: WebColors.cardBorder),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: actions.map((action) => _buildButton(context, action)).toList(),
      ),
    );
  }

  Widget _buildButton(BuildContext context, DialogAction action) {
    // Secondary/Cancel button
    if (!action.isPrimary && !action.isDestructive) {
      return Padding(
        padding: const EdgeInsets.only(right: 12),
        child: TextButton(
          onPressed: action.onPressed,
          style: TextButton.styleFrom(
            foregroundColor: WebColors.buttonSecondary,
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 12,
            ),
          ),
          child: Text(
            action.label,
            style: WebTextStyles.bodyMedium,
          ),
        ),
      );
    }

    // Primary or Destructive button
    final backgroundColor = action.isDestructive
        ? WebColors.error
        : WebColors.success;

    return ElevatedButton(
      onPressed: action.isLoading ? null : action.onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: Colors.white,
        disabledBackgroundColor: backgroundColor.withValues(alpha: 0.6),
        padding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 12,
        ),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: action.isLoading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : Text(
              action.label,
              style: WebTextStyles.bodyMedium.copyWith(
                color: Colors.white,
              ),
            ),
    );
  }
}