
import 'package:flutter/material.dart';
import 'package:flutter_application_1/ui/core/themes/app_theme.dart';

class HeaderButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool enabled;

  const HeaderButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.enabled = true,
  });

  @override
  State<HeaderButton> createState() => _HeaderButtonState();
}

class _HeaderButtonState extends State<HeaderButton> {
  bool _isHovered = false;

  bool get _isDisabled => !widget.enabled || widget.isLoading;

  @override
  Widget build(BuildContext context) {
    // Only show shadow when hovered AND not disabled
    final bool showShadow = _isHovered && !_isDisabled;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Container(
        decoration: showShadow
            ? BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFE0F2FE),
                    offset: const Offset(0, 2),
                    blurRadius: 4,
                    spreadRadius: 0,
                  ),
                ],
              )
            : null,
        child: ElevatedButton(
          onPressed: _isDisabled ? null : widget.onPressed,
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.disabled)) {
                return Colors.transparent;
              }
              if (_isHovered) {
                return AppColors.green100;
              }
              return Colors.transparent;
            }),
            foregroundColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.disabled)) {
                return AppColors.green100.withValues(alpha: 0.5);
              }
              if (_isHovered) {
                return Colors.white;
              }
              return AppColors.green100; //text color
            }),
            padding: WidgetStateProperty.all(
              const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            shape: WidgetStateProperty.all(
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            animationDuration: kThemeChangeDuration,
            elevation: WidgetStateProperty.all(0),
            // Disable default hover effect since we manage it manually
            overlayColor: WidgetStateProperty.resolveWith((states) => Colors.transparent),
          ),
          child: widget.isLoading
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: _isHovered ? Colors.white : AppColors.green100,
                    strokeWidth: 2,
                  ),
                )
              : Text(widget.text, style: const TextStyle(fontSize: 16)),
        ),
      ),
    );
  }
}