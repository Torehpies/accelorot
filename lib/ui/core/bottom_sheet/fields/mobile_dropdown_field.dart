// lib/ui/core/bottom_sheet/fields/mobile_dropdown_field.dart

import 'package:flutter/material.dart';
import '../../themes/web_colors.dart';
import '../../themes/web_text_styles.dart';

/// A generic item model for the dropdown.
class MobileDropdownItem<T> {
  final T value;
  final String label;

  const MobileDropdownItem({required this.value, required this.label});
}

/// Dropdown field for mobile bottom sheets.
///
/// Uses [DropdownButtonFormField] so it automatically inherits the
/// rounded border + green focus colour from [appTheme.inputDecorationTheme].
class MobileDropdownField<T> extends StatelessWidget {
  final String label;
  final T? value;
  final List<MobileDropdownItem<T>> items;
  final String? hintText;
  final String? errorText;
  final String? helperText;
  final bool enabled;
  final bool required;
  final ValueChanged<T?>? onChanged;

  const MobileDropdownField({
    super.key,
    required this.label,
    required this.items,
    this.value,
    this.hintText,
    this.errorText,
    this.helperText,
    this.enabled = true,
    this.required = false,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      initialValue: value,
      onChanged: enabled ? onChanged : null,
      isExpanded: true,
      style: WebTextStyles.body,
      decoration: InputDecoration(
        // Floating label with optional required star
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
        errorText: errorText,
        helperText: helperText,
        helperStyle: WebTextStyles.caption.copyWith(
          color: WebColors.textLabel,
        ),
        filled: !enabled,
        fillColor: enabled ? null : WebColors.inputBackground,
      ),
      hint: hintText != null
          ? Text(
              hintText!,
              style: WebTextStyles.bodyMediumGray,
            )
          : null,
      items: items.map((item) {
        return DropdownMenuItem<T>(
          value: item.value,
          child: Text(
            item.label,
            style: WebTextStyles.body,
          ),
        );
      }).toList(),
      icon: Icon(
        Icons.arrow_drop_down,
        color: enabled ? WebColors.textLabel : WebColors.iconDisabled,
      ),
      dropdownColor: WebColors.cardBackground,
    );
  }
}