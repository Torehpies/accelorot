// lib/ui/core/widgets/filters/filter_dropdown.dart

import 'package:flutter/material.dart';
import '../../themes/web_text_styles.dart';
import '../../themes/web_colors.dart';

/// Reusable styled dropdown for filters that matches DateFilterDropdown styling
class FilterDropdown<T> extends StatelessWidget {
  final String label;
  final T value;
  final List<T> items;
  final ValueChanged<T> onChanged;
  final String Function(T)? displayName;
  final bool isLoading;

  const FilterDropdown({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    this.displayName,
    this.isLoading = false,
  });

  String _getDisplayText(T item) {
    if (displayName != null) {
      return displayName!(item);
    }
    return item.toString();
  }

  void _showFilterMenu(BuildContext context) async {
    if (isLoading) return;

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
      items: items.map((item) {
        return PopupMenuItem<T>(
          value: item,
          child: Text(_getDisplayText(item)),
        );
      }).toList(),
    );

    if (selected != null) {
      onChanged(selected);
    }
  }

  @override
  Widget build(BuildContext context) {
    final valueStr = _getDisplayText(value).toLowerCase();
    final isActive = !valueStr.contains('all');

    return MouseRegion(
      cursor: isLoading ? SystemMouseCursors.basic : SystemMouseCursors.click,
      child: Opacity(
        opacity: isLoading ? 0.5 : 1.0,
        child: InkWell(
          onTap: isLoading ? null : () => _showFilterMenu(context),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: WebColors.inputBackground,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: WebColors.cardBorder),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _getDisplayText(value),
                  style: isActive 
                    ? WebTextStyles.bodyMedium 
                    : WebTextStyles.bodyMediumGray,
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.arrow_drop_down,
                  size: 20,
                  color: isActive ? WebColors.tealAccent : WebColors.textLabel,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}