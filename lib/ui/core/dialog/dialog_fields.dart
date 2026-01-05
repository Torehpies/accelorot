// lib/ui/core/dialog/dialog_fields.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../themes/web_text_styles.dart';
import '../themes/web_colors.dart';

// ==================== READ ONLY ====================

/// Single read-only field displaying label-value pair (side-by-side)
class ReadOnlyField extends StatelessWidget {
  final String label;
  final String value;

  const ReadOnlyField({
    super.key,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label (left-aligned)
          Flexible(
            flex: 2,
            child: Text(
              label,
              style: WebTextStyles.bodyMediumGray,
            ),
          ),
          const SizedBox(width: 16),
          // Value (right-aligned)
          Flexible(
            flex: 3,
            child: Text(
              value,
              style: WebTextStyles.body.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}

/// Read-only field with label on top and value below (for long text like descriptions)
class ReadOnlyMultilineField extends StatelessWidget {
  final String label;
  final String value;
  final bool showGrayBackground;

  const ReadOnlyMultilineField({
    super.key,
    required this.label,
    required this.value,
    this.showGrayBackground = false,
  });

  @override
  Widget build(BuildContext context) {
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        Text(
          label,
          style: WebTextStyles.bodyMediumGray,
        ),
        const SizedBox(height: 8),
        // Value
        Text(
          value,
          style: WebTextStyles.body.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );

    if (showGrayBackground) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
        ),
        child: content,
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: content,
    );
  }
}

/// Gray container section for displaying multiple read-only fields
/// Use this ONLY for mixed layouts (read-only + input fields)
class ReadOnlySection extends StatelessWidget {
  final List<Widget> fields;

  const ReadOnlySection({
    super.key,
    required this.fields,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: fields,
      ),
    );
  }
}

// ==================== INPUT FIELDS ====================

/// Reusable input field for dialogs
class InputField extends StatelessWidget {
  final String label;
  final TextEditingController? controller;
  final String? hintText;
  final String? errorText;
  final bool enabled;
  final int maxLines;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final Widget? prefixIcon;
  final ValueChanged<String>? onChanged;

  const InputField({
    super.key,
    required this.label,
    this.controller,
    this.hintText,
    this.errorText,
    this.enabled = true,
    this.maxLines = 1,
    this.keyboardType,
    this.inputFormatters,
    this.prefixIcon,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        Text(
          label,
          style: WebTextStyles.label.copyWith(
            color: WebColors.textLabel,
          ),
        ),
        const SizedBox(height: 8),

        // Input field
        TextField(
          controller: controller,
          enabled: enabled,
          maxLines: maxLines,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          onChanged: onChanged,
          style: WebTextStyles.body,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: WebTextStyles.bodyMediumGray,
            errorText: errorText,
            prefixIcon: prefixIcon,
            filled: true,
            fillColor: enabled ? WebColors.inputBackground : Colors.grey[200],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: WebColors.cardBorder),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: WebColors.cardBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                color: WebColors.tealAccent,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: WebColors.error),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                color: WebColors.error,
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }
}