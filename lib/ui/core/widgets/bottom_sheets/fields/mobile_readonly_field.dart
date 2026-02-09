// lib/ui/core/bottom_sheet/fields/mobile_readonly_field.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../ui/app_snackbar.dart';
import '../../../themes/web_colors.dart';
import '../../../themes/web_text_styles.dart';

/// Read-only field for mobile bottom sheets
class MobileReadOnlyField extends StatefulWidget {
  final String label;
  final String value;
  final String emptyText;

  const MobileReadOnlyField({
    super.key,
    required this.label,
    required this.value,
    this.emptyText = '—',
  });

  @override
  State<MobileReadOnlyField> createState() => _MobileReadOnlyFieldState();
}

class _MobileReadOnlyFieldState extends State<MobileReadOnlyField> {
  bool _isHovered = false;
  bool _showCopyIcon = false;

  void _onHoverEnter() {
    setState(() => _isHovered = true);
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted && _isHovered) {
        setState(() => _showCopyIcon = true);
      }
    });
  }

  void _onHoverExit() {
    setState(() {
      _isHovered = false;
      _showCopyIcon = false;
    });
  }

  void _copy() {
    if (widget.value.isEmpty) return;
    Clipboard.setData(ClipboardData(text: widget.value));
    AppSnackbar.success(context, 'Copied!');
  }
  
  @override
  Widget build(BuildContext context) {
    final isEmpty = widget.value.isEmpty;
    final displayValue = isEmpty ? widget.emptyText : widget.value;

    return MouseRegion(
      onEnter: (_) => _onHoverEnter(),
      onExit: (_) => _onHoverExit(),
      child: GestureDetector(
        onLongPress: isEmpty ? null : _copy,
        onTap: (_isHovered && !isEmpty) ? _copy : null,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
          decoration: BoxDecoration(
            color: _isHovered ? WebColors.badgeBackground : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Label
              Flexible(
                flex: 2,
                child: Text(
                  widget.label,
                  style: WebTextStyles.bodyMediumGray,
                ),
              ),
              const SizedBox(width: 12),
              // Value + optional copy icon
              Flexible(
                flex: 3,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Text(
                        displayValue,
                        textAlign: TextAlign.right,
                        style: WebTextStyles.body.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isEmpty
                              ? WebColors.textMuted
                              : WebColors.textPrimary,
                        ),
                      ),
                    ),
                    if (_showCopyIcon && !isEmpty) ...[
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.content_copy,
                        size: 15,
                        color: WebColors.textLabel,
                      ),
                    ],
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