// lib/ui/core/ui/secondary_button.dart

import 'package:flutter/material.dart';
import 'package:flutter_application_1/ui/core/themes/web_colors.dart'; 

class ThirdButton extends StatelessWidget { 
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool enabled;

  const ThirdButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.enabled = true,
  });

  bool get _isDisabled => !enabled || isLoading;

  @override 
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: _isDisabled ? null : onPressed,
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            return WebColors.blue50.withValues(alpha: 0.5);
          }
          return WebColors.blue50;
        }),
        foregroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            return WebColors.textMuted;
          }
          return WebColors.textPrimary; // Dark text
        }),
        padding: WidgetStateProperty.all(
          const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
        side: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.pressed) || states.contains(WidgetState.hovered)) {
            return BorderSide(color: WebColors.blue300, width: 1);
          }
          return BorderSide(color: WebColors.blue200, width: 1);
        }),
      ),
      child: isLoading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                color: WebColors.textPrimary, 
                strokeWidth: 2,
              ),
            )
          : Text(text, style: const TextStyle(fontSize: 16)),
    );
  }
}