// lib/ui/core/widgets/dialog/web_confirmation_dialog.dart

import 'package:flutter/material.dart';
import '../../themes/web_colors.dart';
import '../../themes/web_text_styles.dart';
import 'mobile_confirmation_dialog.dart' show ConfirmResult;

export 'mobile_confirmation_dialog.dart' show ConfirmResult;

class WebConfirmationDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmLabel;
  final String cancelLabel;
  final bool confirmIsDestructive;

  const WebConfirmationDialog({
    super.key,
    this.title = 'Unsaved Changes',
    this.message =
        'You have unsaved changes. Are you sure you want to discard them?',
    this.confirmLabel = 'Discard',
    this.cancelLabel = 'Keep Editing',
    this.confirmIsDestructive = true,
  });

  static Future<ConfirmResult> show(
    BuildContext context, {
    String title = 'Unsaved Changes',
    String message =
        'You have unsaved changes. Are you sure you want to discard them?',
    String confirmLabel = 'Discard',
    String cancelLabel = 'Keep Editing',
    bool confirmIsDestructive = true,
  }) async {
    final result = await showDialog<ConfirmResult>(
      context: context,
      barrierDismissible: false,
      barrierColor: WebColors.dialogBarrier,
      builder: (_) => WebConfirmationDialog(
        title: title,
        message: message,
        confirmLabel: confirmLabel,
        cancelLabel: cancelLabel,
        confirmIsDestructive: confirmIsDestructive,
      ),
    );
    return result ?? ConfirmResult.cancelled;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Container(
          decoration: BoxDecoration(
            color: WebColors.cardBackground,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Icon + title + message ───────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(32, 32, 32, 24),
                child: Column(
                  children: [
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
                      style: WebTextStyles.bodyMediumGray,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              // ── Divider ──────────────────────────────────────────────
              const Divider(height: 1, color: WebColors.cardBorder),

              // ── Buttons — styled to match DialogFooter._buildButton ──
              Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Cancel — matches DialogFooter secondary (OutlinedButton)
                    OutlinedButton(
                      onPressed: () =>
                          Navigator.of(context).pop(ConfirmResult.cancelled),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: WebColors.textPrimary,
                        side: const BorderSide(
                          color: WebColors.cardBorder,
                          width: 1.5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 14,
                        ),
                        minimumSize: const Size(0, 48),
                        overlayColor:
                            WebColors.textPrimary.withValues(alpha: 0.05),
                      ),
                      child: Text(
                        cancelLabel,
                        style: WebTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Confirm — matches DialogFooter primary/destructive (ElevatedButton)
                    ElevatedButton(
                      onPressed: () =>
                          Navigator.of(context).pop(ConfirmResult.confirmed),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: confirmIsDestructive
                            ? WebColors.error
                            : WebColors.success,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: (confirmIsDestructive
                                ? WebColors.error
                                : WebColors.success)
                            .withValues(alpha: 0.6),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 14,
                        ),
                        minimumSize: const Size(0, 48),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
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
      ),
    );
  }
}