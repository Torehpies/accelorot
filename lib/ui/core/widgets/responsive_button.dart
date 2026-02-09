import 'package:flutter/material.dart';
import 'package:flutter_application_1/ui/core/themes/app_theme.dart';

class ResponsiveButton extends StatelessWidget {
  final bool isTablet;
  final String tooltipMessage;
  final Icon icon;
  final VoidCallback onPressed;
  final Widget? label;
  final ButtonStyle? iconButtonStyle;
  final ButtonStyle? elevatedButtonStyle;

  const ResponsiveButton({
    super.key,
    required this.tooltipMessage,
    required this.icon,
    required this.onPressed,
    required this.isTablet,
    this.label,
    this.iconButtonStyle,
    this.elevatedButtonStyle,
  });

  @override
  Widget build(BuildContext context) {
    final child = isTablet
        ? IconButton(
            tooltip: tooltipMessage,
            onPressed: onPressed,
            icon: icon,
            style:
                iconButtonStyle ??
                ButtonStyle(
                  backgroundColor: const WidgetStatePropertyAll(
                    AppColors.green100,
                  ),
                  foregroundColor: const WidgetStatePropertyAll(Colors.white),
                  shape: WidgetStatePropertyAll(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
          )
        : ElevatedButton.icon(
            onPressed: onPressed,
            icon: icon,
            label: label ?? const SizedBox.shrink(),
            style: elevatedButtonStyle,
          );
    return isTablet ? child : Tooltip(message: tooltipMessage, child: child);
  }
}
