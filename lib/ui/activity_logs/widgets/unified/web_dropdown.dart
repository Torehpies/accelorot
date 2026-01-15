// lib/ui/activity_logs/widgets/unified/web_dropdown.dart

import 'package:flutter/material.dart';
import '../../../core/themes/web_text_styles.dart';
import '../../../core/themes/web_colors.dart';
import 'web_table_container.dart';

/// Reusable web-optimized dropdown that uses showMenu for a premium feel
/// Supports both full and icon-only display modes for responsive layouts
class WebDropdown<T> extends StatelessWidget {
  final T? value;
  final String label;
  final String hintText;
  final List<PopupMenuItem<T>> items;
  final ValueChanged<T?> onChanged;
  final IconData icon;
  final bool isLoading;
  final String? disabledHint;
  final String? displayText;
  final DropdownDisplayMode displayMode;

  const WebDropdown({
    super.key,
    required this.value,
    required this.label,
    required this.hintText,
    required this.items,
    required this.onChanged,
    required this.icon,
    this.displayText,
    this.isLoading = false,
    this.disabledHint,
    this.displayMode = DropdownDisplayMode.full,
  });

  void _showMenu(BuildContext context) async {
    if (isLoading || items.isEmpty) return;

    final RenderBox button = context.findRenderObject() as RenderBox;
    final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    
    final RelativeRect position = RelativeRect.fromRect(
      Rect.fromPoints(
        button.localToGlobal(Offset.zero, ancestor: overlay),
        button.localToGlobal(button.size.bottomRight(Offset.zero), ancestor: overlay),
      ),
      Offset.zero & overlay.size,
    );

    final T? selected = await showMenu<T>(
      context: context,
      position: position,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      elevation: 8,
      color: WebColors.cardBackground,
      constraints: const BoxConstraints(
        maxHeight: 300,
      ),
      items: items,
    );

    if (selected != null) {
      onChanged(selected);
    }
  }

  void _clearValue() {
    onChanged(null);
  }

  @override
  Widget build(BuildContext context) {
    final bool hasValue = value != null;
    final bool isIconOnly = displayMode == DropdownDisplayMode.iconOnly;

    return Tooltip(
      message: isIconOnly ? '$label: ${displayText ?? hintText}' : '',
      waitDuration: const Duration(milliseconds: 500),
      child: MouseRegion(
        cursor: (isLoading || items.isEmpty) ? SystemMouseCursors.basic : SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () => _showMenu(context),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: isIconOnly ? 8 : 10,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: WebColors.inputBackground,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: WebColors.cardBorder),
            ),
            child: isIconOnly ? _buildIconOnlyMode(hasValue) : _buildFullMode(hasValue),
          ),
        ),
      ),
    );
  }

  /// Icon-only mode: just icon + clear button (when selected)
  Widget _buildIconOnlyMode(bool hasValue) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 18,
          color: hasValue ? WebColors.tealAccent : WebColors.textLabel,
        ),
        if (hasValue) ...[
          const SizedBox(width: 6),
          GestureDetector(
            onTap: _clearValue,
            child: Icon(
              Icons.clear,
              size: 16,
              color: WebColors.textLabel,
            ),
          ),
        ],
      ],
    );
  }

  /// Full mode: icon + text + dropdown arrow + clear button
  Widget _buildFullMode(bool hasValue) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 16,
          color: hasValue ? WebColors.tealAccent : WebColors.textLabel,
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            isLoading 
                ? 'Loading...' 
                : (items.isEmpty && disabledHint != null 
                    ? disabledHint! 
                    : (displayText ?? hintText)),
            style: hasValue ? WebTextStyles.bodyMedium : WebTextStyles.bodyMediumGray,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 4),
        Icon(
          Icons.arrow_drop_down,
          size: 20,
          color: hasValue ? WebColors.tealAccent : WebColors.textLabel,
        ),
        if (hasValue) ...[
          const SizedBox(width: 4),
          GestureDetector(
            onTap: _clearValue,
            child: const Icon(
              Icons.clear,
              size: 16,
              color: WebColors.textLabel,
            ),
          ),
        ],
      ],
    );
  }
}