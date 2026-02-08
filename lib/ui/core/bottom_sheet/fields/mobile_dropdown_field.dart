// lib/ui/core/bottom_sheet/fields/mobile_dropdown_field.dart

import 'package:flutter/material.dart';
import '../../themes/web_colors.dart';
import '../../themes/web_text_styles.dart';
export '../../fields/dropdown_field.dart' show MobileDropdownField, DropdownItem;

/// A generic item model for the dropdown.
class MobileDropdownItem<T> {
  final T value;
  final String label;

  const MobileDropdownItem({required this.value, required this.label});
}

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

  void _showDropdownMenu(BuildContext context) async {
    if (!enabled) return;

    final RenderBox button = context.findRenderObject() as RenderBox;
    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;

    final RelativeRect position = RelativeRect.fromRect(
      Rect.fromPoints(
        button.localToGlobal(Offset.zero, ancestor: overlay),
        button.localToGlobal(
          button.size.bottomRight(Offset.zero),
          ancestor: overlay,
        ),
      ),
      Offset.zero & overlay.size,
    );

    final List<PopupMenuEntry<T>> menuItems = [];

    // Add all options with checkmarks
    for (final item in items) {
      menuItems.add(_buildMenuItem(item));
    }

    final T? selected = await showMenu<T>(
      context: context,
      position: position,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 8,
      color: WebColors.cardBackground,
      constraints: const BoxConstraints(maxHeight: 300),
      items: menuItems,
    );

    if (selected != null && onChanged != null) {
      onChanged!(selected);
    }
  }

  PopupMenuItem<T> _buildMenuItem(MobileDropdownItem<T> item) {
    final isSelected = value == item.value;

    return PopupMenuItem<T>(
      value: item.value,
      height: 48,
      child: Row(
        children: [
          SizedBox(
            width: 24,
            child: isSelected
                ? const Icon(Icons.check, size: 18, color: WebColors.success)
                : null,
          ),
          const SizedBox(width: 8),
          Text(
            item.label,
            style: WebTextStyles.body,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Find the selected item's label
    final selectedItem = items.firstWhere(
      (item) => item.value == value,
      orElse: () => items.first,
    );
    final displayText = value != null ? selectedItem.label : hintText ?? '';

    return InkWell(
      onTap: enabled ? () => _showDropdownMenu(context) : null,
      borderRadius: BorderRadius.circular(4),
      child: InputDecorator(
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
          errorText: errorText,
          helperText: helperText,
          helperStyle: WebTextStyles.caption.copyWith(
            color: WebColors.textLabel,
          ),
          filled: !enabled,
          fillColor: enabled ? null : WebColors.inputBackground,
          suffixIcon: Icon(
            Icons.arrow_drop_down,
            color: enabled ? WebColors.textLabel : WebColors.iconDisabled,
          ),
        ),
        child: Text(
          displayText,
          style: value != null
              ? WebTextStyles.body
              : WebTextStyles.bodyMediumGray,
        ),
      ),
    );
  }
}