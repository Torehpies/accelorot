// lib/ui/core/widgets/filters/filter_dropdown.dart

import 'package:flutter/material.dart';
import '../../themes/web_colors.dart';

/// Reusable styled dropdown for filters with icon-only design
class FilterDropdown<T> extends StatefulWidget {
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

  @override
  State<FilterDropdown<T>> createState() => _FilterDropdownState<T>();
}

class _FilterDropdownState<T> extends State<FilterDropdown<T>> {
  bool _isHovered = false;

  String _getDisplayText(T item) {
    if (widget.displayName != null) {
      return widget.displayName!(item);
    }
    return item.toString();
  }

  void _showFilterMenu(BuildContext context) async {
    if (widget.isLoading) return;

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
      items: widget.items.map((item) {
        return PopupMenuItem<T>(
          value: item,
          child: Text(_getDisplayText(item)),
        );
      }).toList(),
    );

    if (selected != null) {
      widget.onChanged(selected);
    }
  }

  @override
  Widget build(BuildContext context) {
    final valueStr = _getDisplayText(widget.value).toLowerCase();
    final isActive = !valueStr.contains('all');
    final iconColor = isActive ? WebColors.greenAccent : WebColors.textLabel;

    return MouseRegion(
      cursor: widget.isLoading ? SystemMouseCursors.basic : SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Opacity(
        opacity: widget.isLoading ? 0.5 : 1.0,
        child: InkWell(
          onTap: widget.isLoading ? null : () => _showFilterMenu(context),
          borderRadius: BorderRadius.circular(4),
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: Icon(
              Icons.filter_alt,
              size: 18,
              color: _isHovered 
                ? (isActive ? WebColors.greenAccent.withValues(alpha: 0.8) : WebColors.textSecondary)
                : iconColor,
            ),
          ),
        ),
      ),
    );
  }
}