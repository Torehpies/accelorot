// lib/ui/core/fields/dropdown_field.dart

import 'package:flutter/material.dart';
import '../../themes/web_colors.dart';
import '../../themes/web_text_styles.dart';

/// Generic item model for dropdowns
class DropdownItem<T> {
  final T value;
  final String label;

  const DropdownItem({required this.value, required this.label});
}

/// Web dropdown field with custom popup menu (matching mobile design)
class WebDropdownField<T> extends StatelessWidget {
  final String label;
  final T? value;
  final List<DropdownItem<T>> items;
  final String? hintText;
  final String? errorText;
  final String? helperText;
  final bool enabled;
  final bool required;
  final ValueChanged<T?>? onChanged;

  const WebDropdownField({
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
    if (!enabled || items.isEmpty) return;

    final RenderBox button = context.findRenderObject() as RenderBox;
    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;
    
    // Capture the button width for menu sizing
    final buttonWidth = button.size.width;

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
      // Match the dropdown field width exactly
      constraints: BoxConstraints(
        minWidth: buttonWidth,
        maxWidth: buttonWidth,
        maxHeight: 300,
      ),
      items: menuItems,
    );

    if (selected != null && onChanged != null) {
      onChanged!(selected);
    }
  }

  PopupMenuItem<T> _buildMenuItem(DropdownItem<T> item) {
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
          Expanded(
            child: Text(
              item.label,
              style: WebTextStyles.body,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Safety: Handle both empty items and value not in items
    String displayText = hintText ?? '';
    
    if (items.isNotEmpty && value != null) {
      try {
        final selectedItem = items.firstWhere(
          (item) => item.value == value,
        );
        displayText = selectedItem.label;
      } catch (e) {
        // Value not found in items, use hint
        displayText = hintText ?? '';
      }
    }

    return InkWell(
      onTap: enabled ? () => _showDropdownMenu(context) : null,
      borderRadius: BorderRadius.circular(12),
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
          hintText: hintText,
          hintStyle: WebTextStyles.bodyMediumGray,
          errorText: errorText,
          helperText: helperText,
          helperStyle: WebTextStyles.caption.copyWith(
            color: WebColors.textLabel,
          ),
          filled: !enabled,
          fillColor: enabled ? null : WebColors.inputBackground,
          suffixIcon: Icon(
            Icons.keyboard_arrow_down,
            color: enabled ? WebColors.textLabel : WebColors.iconDisabled,
          ),
          // Rounded borders (matching mobile design)
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: WebColors.cardBorder),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: WebColors.cardBorder),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: WebColors.greens, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: WebColors.error),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: WebColors.error, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
        ),
        child: Text(
          displayText,
          style: value != null && items.any((item) => item.value == value)
              ? WebTextStyles.body
              : WebTextStyles.bodyMediumGray,
        ),
      ),
    );
  }
}

/// Mobile dropdown field with custom popup menu
class MobileDropdownField<T> extends StatelessWidget {
  final String label;
  final T? value;
  final List<DropdownItem<T>> items;
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
    if (!enabled || items.isEmpty) return;

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

  PopupMenuItem<T> _buildMenuItem(DropdownItem<T> item) {
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
    // Safety: Handle both empty items and value not in items
    String displayText = hintText ?? '';
    
    if (items.isNotEmpty && value != null) {
      try {
        final selectedItem = items.firstWhere(
          (item) => item.value == value,
        );
        displayText = selectedItem.label;
      } catch (e) {
        // Value not found in items, use hint
        displayText = hintText ?? '';
      }
    }

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
          style: value != null && items.any((item) => item.value == value)
              ? WebTextStyles.body
              : WebTextStyles.bodyMediumGray,
        ),
      ),
    );
  }
}