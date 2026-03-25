// lib/ui/core/widgets/header_button.dart
import 'package:flutter/material.dart';
import '../../../ui/core/themes/web_colors.dart'; // Adjust path to your colors file

enum HeaderButtonType { outline, filled }

class HeaderButton extends StatefulWidget {
  final String text;
  final HeaderButtonType type;
  final VoidCallback onPressed;
  final double? width;
  final double height;
  final double fontSize;

  const HeaderButton({
    super.key,
    required this.text,
    required this.type,
    required this.onPressed,
    this.width,
    this.height = 36,
    this.fontSize = 14,
  });

  @override
  State<HeaderButton> createState() => _HeaderButtonState();
}

class _HeaderButtonState extends State<HeaderButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isOutline = widget.type == HeaderButtonType.outline;
    
    // Colors based on type and hover state
    final backgroundColor = isOutline
        ? (_isHovered ? WebColors.buttonsPrimary : Colors.transparent)
        : WebColors.buttonsPrimary;
    
    final foregroundColor = isOutline
        ? (_isHovered ? Colors.white : WebColors.buttonsPrimary)
        : Colors.white;
    
    final borderColor = isOutline ? WebColors.buttonsPrimary : Colors.transparent;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: backgroundColor,
          border: Border.all(color: borderColor, width: 1.5),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: widget.onPressed,
            child: Center(
              child: Text(
                widget.text,
                style: TextStyle(
                  color: foregroundColor,
                  fontSize: widget.fontSize,
                  fontWeight: FontWeight.w600,
                  height: 1,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}