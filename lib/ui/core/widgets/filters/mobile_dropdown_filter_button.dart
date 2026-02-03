// lib/ui/core/widgets/filters/mobile_dropdown_filter_button.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../themes/app_theme.dart';

/// Interface for filterable enums - implement this in your filter enums
abstract class FilterOption {
  String get displayName;
  bool get isAll;
}

/// Generic dropdown filter button for any FilterOption enum
class MobileDropdownFilterButton<T extends FilterOption> extends StatefulWidget {
  final T currentFilter;
  final List<T> options;
  final Function(T) onFilterChanged;
  final IconData icon;
  final bool isLoading;
  final String? tooltip;

  const MobileDropdownFilterButton({
    super.key,
    required this.currentFilter,
    required this.options,
    required this.onFilterChanged,
    required this.icon,
    this.isLoading = false,
    this.tooltip,
  });

  @override
  State<MobileDropdownFilterButton<T>> createState() => 
      _MobileDropdownFilterButtonState<T>();
}

class _MobileDropdownFilterButtonState<T extends FilterOption> 
    extends State<MobileDropdownFilterButton<T>> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isActive = !widget.currentFilter.isAll;
    final backgroundColor = _isHovered ? AppColors.grey : AppColors.background2;

    return MouseRegion(
      cursor: widget.isLoading ? SystemMouseCursors.basic : SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Opacity(
        opacity: widget.isLoading ? 0.5 : 1.0,
        child: GestureDetector(
          onLongPress: isActive && !widget.isLoading ? _showTooltip : null,
          child: Tooltip(
            message: isActive ? (widget.tooltip ?? widget.currentFilter.displayName) : '',
            waitDuration: const Duration(milliseconds: 500),
            child: InkWell(
              onTap: widget.isLoading ? null : _showFilterMenu,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                  color: backgroundColor,
                  border: Border.all(color: AppColors.grey, width: 1.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Stack(
                  children: [
                    Center(
                      child: Icon(
                        widget.icon,
                        color: isActive ? AppColors.green100 : AppColors.textSecondary,
                        size: 20,
                      ),
                    ),
                    if (isActive)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: AppColors.green100,
                            shape: BoxShape.circle,
                            border: Border.all(color: backgroundColor, width: 1.5),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showTooltip() {
    HapticFeedback.lightImpact();
  }

  void _showFilterMenu() async {
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

    final List<PopupMenuEntry<T>> menuItems = [];

    // Add clear filter option if active
    if (!widget.currentFilter.isAll) {
      menuItems.add(
        PopupMenuItem<T>(
          value: null,
          child: Row(
            children: [
              Icon(Icons.tune, size: 18, color: AppColors.textSecondary),
              const SizedBox(width: 12),
              Text(
                'Clear Filter',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
      menuItems.add(const PopupMenuDivider());
    }

    // Add all options
    for (final option in widget.options) {
      menuItems.add(_buildMenuItem(option));
    }

    final T? selected = await showMenu<T>(
      context: context,
      position: position,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 8,
      color: Colors.white,
      items: menuItems,
    );

    if (selected != null) {
      HapticFeedback.selectionClick();
      widget.onFilterChanged(selected);
    } else if (selected == null && menuItems.first.represents(null)) {
      HapticFeedback.selectionClick();
      final allOption = widget.options.firstWhere((opt) => opt.isAll);
      widget.onFilterChanged(allOption);
    }
  }

  PopupMenuItem<T> _buildMenuItem(T option) {
    final isSelected = widget.currentFilter == option;

    return PopupMenuItem<T>(
      value: option,
      height: 48,
      child: Row(
        children: [
          SizedBox(
            width: 24,
            child: isSelected
                ? Icon(Icons.check, size: 18, color: AppColors.green100)
                : null,
          ),
          const SizedBox(width: 8),
          Text(option.displayName),
        ],
      ),
    );
  }
}