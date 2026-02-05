// lib/ui/core/bottom_sheet/mobile_bottom_sheet_base.dart

import 'package:flutter/material.dart';
import '../themes/web_colors.dart';
import '../themes/web_text_styles.dart';

/// Base layout for mobile bottom sheets, with header, scrollable body and sticky footer.
/// 
/// Supports two header patterns:
/// 1. Legacy: Single title only
/// 2. New: Title (data) + subtitle (context) - matches web dialog pattern
class BottomSheetAction {
  final String label;
  final VoidCallback? onPressed;
  final bool isPrimary;
  final bool isDestructive;
  final bool isLoading;

  const BottomSheetAction({
    required this.label,
    required this.onPressed,
    this.isPrimary = false,
    this.isDestructive = false,
    this.isLoading = false,
  });

  /// Green filled button (Save, Update …)
  factory BottomSheetAction.primary({
    required String label,
    required VoidCallback? onPressed,
    bool isLoading = false,
  }) =>
      BottomSheetAction(
        label: label,
        onPressed: onPressed,
        isPrimary: true,
        isLoading: isLoading,
      );

  /// Text-only button (Cancel, Close …)
  factory BottomSheetAction.secondary({
    required String label,
    required VoidCallback? onPressed,
  }) =>
      BottomSheetAction(label: label, onPressed: onPressed);

  /// Red filled button (Delete, Discard …)
  factory BottomSheetAction.destructive({
    required String label,
    required VoidCallback? onPressed,
    bool isLoading = false,
  }) =>
      BottomSheetAction(
        label: label,
        onPressed: onPressed,
        isDestructive: true,
        isLoading: isLoading,
      );
}

class MobileBottomSheetBase extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget body;
  final List<BottomSheetAction> actions;
  final bool showCloseButton;
  final VoidCallback? onClose;

  const MobileBottomSheetBase({
    super.key,
    required this.title,
    this.subtitle,
    required this.body,
    required this.actions,
    this.showCloseButton = true,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.90,
      ),
      decoration: const BoxDecoration(
        color: WebColors.cardBackground,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Drag handle ──────────────────────────────────────────────────
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.center,
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: WebColors.cardBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 4),

          // ── Header ───────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title (actual data or legacy label)
                      Text(
                        title.isEmpty ? '—' : title,
                        style: WebTextStyles.sectionTitle.copyWith(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: title.isEmpty
                              ? WebColors.textMuted
                              : WebColors.textPrimary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      // Subtitle (context label)
                      if (subtitle != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          subtitle!,
                          style: WebTextStyles.bodyMediumGray.copyWith(
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (showCloseButton)
                  IconButton(
                    iconSize: 20,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: const Icon(Icons.close, color: WebColors.textSecondary),
                    onPressed: onClose ?? () => Navigator.of(context).pop(),
                  ),
              ],
            ),
          ),

          // ── Thin divider ─────────────────────────────────────────────────
          const Divider(height: 1, color: WebColors.cardBorder),

          // ── Scrollable body ──────────────────────────────────────────────
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: body,
            ),
          ),

          // ── Footer divider ───────────────────────────────────────────────
          const Divider(height: 1, color: WebColors.cardBorder),

          // ── Sticky footer with action buttons ────────────────────────────
          Padding(
            padding: EdgeInsets.fromLTRB(
              20,
              16,
              20,
              16 + MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: actions.map((a) => _buildButton(a)).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButton(BottomSheetAction action) {
    // ── Secondary (text) ───────────────────────────────────────────────────
    if (!action.isPrimary && !action.isDestructive) {
      return Padding(
        padding: const EdgeInsets.only(right: 8),
        child: TextButton(
          onPressed: action.onPressed,
          style: TextButton.styleFrom(
            foregroundColor: WebColors.buttonSecondary,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          ),
          child: Text(
            action.label,
            style: WebTextStyles.bodyMedium,
          ),
        ),
      );
    }

    // ── Primary / Destructive (filled) ─────────────────────────────────────
    final bg = action.isDestructive ? WebColors.error : WebColors.success;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ElevatedButton(
        onPressed: action.isLoading ? null : action.onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: bg,
          foregroundColor: Colors.white,
          disabledBackgroundColor: bg.withValues(alpha: 0.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
          elevation: 0,
        ),
        child: action.isLoading
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2.2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                action.label,
                style: WebTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }
}