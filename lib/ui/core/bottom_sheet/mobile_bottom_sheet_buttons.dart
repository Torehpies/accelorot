// lib/ui/core/bottom_sheet/mobile_bottom_sheet_buttons.dart

import 'package:flutter/material.dart';
import '../themes/web_colors.dart';
import '../themes/web_text_styles.dart';

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

  factory BottomSheetAction.secondary({
    required String label,
    required VoidCallback? onPressed,
  }) =>
      BottomSheetAction(label: label, onPressed: onPressed);

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

class MobileBottomSheetButtons extends StatelessWidget {
  final List<BottomSheetAction> actions;

  const MobileBottomSheetButtons({
    super.key,
    required this.actions,
  });

  @override
  Widget build(BuildContext context) {
    if (actions.isEmpty) return const SizedBox.shrink();

    // Single button: Full width
    if (actions.length == 1) {
      return _buildButton(actions[0], isFullWidth: true);
    }

    // Two buttons: Equal 50/50 split
    if (actions.length == 2) {
      return Row(
        children: [
          Expanded(child: _buildButton(actions[0])),
          const SizedBox(width: 12),
          Expanded(child: _buildButton(actions[1])),
        ],
      );
    }

    // Three+ buttons: Equal width with smaller gaps
    return Row(
      children: [
        for (int i = 0; i < actions.length; i++) ...[
          Expanded(child: _buildButton(actions[i])),
          if (i < actions.length - 1) const SizedBox(width: 8),
        ],
      ],
    );
  }

  Widget _buildButton(BottomSheetAction action, {bool isFullWidth = false}) {
    // Secondary (text button)
    if (!action.isPrimary && !action.isDestructive) {
      return TextButton(
        onPressed: action.onPressed,
        style: TextButton.styleFrom(
          foregroundColor: WebColors.buttonSecondary,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          minimumSize: const Size(0, 48),
        ),
        child: Text(
          action.label,
          style: WebTextStyles.bodyMedium,
        ),
      );
    }

    // Primary / Destructive (filled button)
    final bg = action.isDestructive ? WebColors.error : WebColors.success;

    return ElevatedButton(
      onPressed: action.isLoading ? null : action.onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: bg,
        foregroundColor: Colors.white,
        disabledBackgroundColor: bg.withValues(alpha: 0.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        minimumSize: const Size(0, 48),
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
    );
  }
}