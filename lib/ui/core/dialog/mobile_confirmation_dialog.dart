// lib/ui/core/dialogs/mobile_confirmation_dialog.dart

import 'package:flutter/material.dart';
import '../themes/web_colors.dart';
import '../themes/web_text_styles.dart';

/// Result returned by [MobileConfirmationDialog.show].
enum ConfirmResult { confirmed, cancelled }

class MobileConfirmationDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmLabel;
  final String cancelLabel;
  final bool confirmIsDestructive;

  const MobileConfirmationDialog({
    super.key,
    this.title = 'Unsaved Changes',
    this.message = 'You have unsaved changes. Are you sure you want to discard them?',
    this.confirmLabel = 'Discard',
    this.cancelLabel = 'Keep Editing',
    this.confirmIsDestructive = true,
  });

  /// Convenience static helper – shows the dialog and returns the result.
  static Future<ConfirmResult> show(
    BuildContext context, {
    String title = 'Unsaved Changes',
    String message = 'You have unsaved changes. Are you sure you want to discard them?',
    String confirmLabel = 'Discard',
    String cancelLabel = 'Keep Editing',
  }) async {
    final result = await showDialog<ConfirmResult>(
      context: context,
      barrierDismissible: false,
      builder: (_) => MobileConfirmationDialog(
        title: title,
        message: message,
        confirmLabel: confirmLabel,
        cancelLabel: cancelLabel,
      ),
    );
    return result ?? ConfirmResult.cancelled;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        decoration: BoxDecoration(
          color: WebColors.cardBackground,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Icon + title + message ─────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 8),
              child: Column(
                children: [
                  // Warning icon
                  Container(
                    width: 48,
                    height: 48,
                    decoration: const BoxDecoration(
                      color: WebColors.alertsBackground,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.warning_amber_rounded,
                      color: WebColors.alertsIcon,
                      size: 26,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    title,
                    style: WebTextStyles.sectionTitle,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    message,
                    style: WebTextStyles.body,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            // ── Divider ────────────────────────────────────────────────
            const Divider(height: 1, color: WebColors.cardBorder),

            // ── Buttons ────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Cancel / Keep Editing
                  TextButton(
                    onPressed: () =>
                        Navigator.of(context).pop(ConfirmResult.cancelled),
                    style: TextButton.styleFrom(
                      foregroundColor: WebColors.buttonSecondary,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    ),
                    child: Text(
                      cancelLabel,
                      style: WebTextStyles.bodyMedium,
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Discard (destructive)
                  ElevatedButton(
                    onPressed: () =>
                        Navigator.of(context).pop(ConfirmResult.confirmed),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: WebColors.error,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      elevation: 0,
                    ),
                    child: Text(
                      confirmLabel,
                      style: WebTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}