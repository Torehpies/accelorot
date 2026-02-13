// lib/ui/core/bottom_sheet/fields/mobile_input_field.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../themes/web_colors.dart';
import '../../../themes/web_text_styles.dart';

class MobileInputField extends StatelessWidget {
  final String label;
  final TextEditingController? controller;
  final String? hintText;
  final String? errorText;
  final String? helperText;
  final bool enabled;
  final bool required;
  final int maxLines;
  final int? maxLength;
  final bool showCounter;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final ValueChanged<String>? onChanged;
  final Widget? prefixIcon;
  final String? suffix;
  final Widget? suffixIcon;

  const MobileInputField({
    super.key,
    required this.label,
    this.controller,
    this.hintText,
    this.errorText,
    this.helperText,
    this.enabled = true,
    this.required = false,
    this.maxLines = 1,
    this.maxLength,
    this.showCounter = false,
    this.keyboardType,
    this.inputFormatters,
    this.onChanged,
    this.prefixIcon,
    this.suffix,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      maxLines: maxLines,
      maxLength: maxLength,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      onChanged: onChanged,
      style: WebTextStyles.body,
      decoration: InputDecoration(
        label: RichText(
          text: TextSpan(
            text: label,
            style: WebTextStyles.label.copyWith(color: WebColors.textLabel),
            children: [
              if (required)
                const TextSpan(
                  text: ' *',
                  style: TextStyle(color: WebColors.error),
                ),
            ],
          ),
        ),
        hintText: hintText,
        hintStyle: WebTextStyles.bodyMediumGray,
        errorText: errorText,
        helperText: helperText,
        helperStyle: WebTextStyles.caption.copyWith(
          color: WebColors.textLabel,
        ),
        prefixIcon: prefixIcon,
        suffixText: suffix,
        suffixStyle: WebTextStyles.body.copyWith(
          color: WebColors.textLabel,
        ),
        suffixIcon: suffixIcon,
        
        filled: !enabled,
        fillColor: enabled ? null : WebColors.inputBackground,
        
        // Counter text
        counterText: (maxLength != null && showCounter) ? null : '',
        counterStyle: WebTextStyles.caption.copyWith(
          color: WebColors.textMuted,
        ),
      ),
    );
  }
}