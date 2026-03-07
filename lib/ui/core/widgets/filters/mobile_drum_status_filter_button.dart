// lib/ui/core/widgets/filters/mobile_drum_status_filter_button.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../themes/app_theme.dart';
import '../../../operator_dashboard/models/operator_dashboard_state.dart';

/// Mobile drum status filter button with dropdown menu
class MobileDrumStatusFilterButton extends StatefulWidget {
  final DrumStatusFilter currentFilter;
  final Function(DrumStatusFilter) onFilterChanged;
  final bool isLoading;

  const MobileDrumStatusFilterButton({
    super.key,
    required this.currentFilter,
    required this.onFilterChanged,
    this.isLoading = false,
  });

  @override
  State<MobileDrumStatusFilterButton> createState() => _MobileDrumStatusFilterButtonState();
}

class _MobileDrumStatusFilterButtonState extends State<MobileDrumStatusFilterButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isActive = widget.currentFilter != DrumStatusFilter.all;
    final backgroundColor = _isHovered 
        ? AppColors.grey 
        : AppColors.background2;

    return MouseRegion(
      cursor: widget.isLoading ? SystemMouseCursors.basic : SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Opacity(
        opacity: widget.isLoading ? 0.5 : 1.0,
        child: GestureDetector(
          onLongPress: isActive && !widget.isLoading ? _showTooltip : null,
          child: Tooltip(
            message: isActive ? widget.currentFilter.displayName : '',
            waitDuration: const Duration(milliseconds: 500),
            child: InkWell(
              onTap: widget.isLoading ? null : _showFilterMenu,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                height: 40,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: backgroundColor,
                  border: Border.all(
                    color: AppColors.grey,
                    width: 1.5,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.filter_list,
                      color: isActive ? AppColors.green100 : AppColors.textSecondary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isActive ? widget.currentFilter.displayName : 'Filter',
                      style: TextStyle(
                        fontSize: 14,
                        color: isActive ? AppColors.green100 : AppColors.textSecondary,
                        fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
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

    // Build menu items
    final List<PopupMenuEntry<DrumStatusFilter>> menuItems = [];

    // Add filter options
    for (var filter in DrumStatusFilter.values) {
      menuItems.add(_buildMenuItem(filter));
    }

    final DrumStatusFilter? selected = await showMenu<DrumStatusFilter>(
      context: context,
      position: position,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 8,
      color: Colors.white,
      items: menuItems,
    );

    if (selected != null && selected != widget.currentFilter) {
      HapticFeedback.selectionClick();
      widget.onFilterChanged(selected);
    }
  }

  PopupMenuItem<DrumStatusFilter> _buildMenuItem(DrumStatusFilter filter) {
    final isSelected = widget.currentFilter == filter;

    Color iconColor;
    IconData icon;
    
    switch (filter) {
      case DrumStatusFilter.all:
        iconColor = AppColors.textSecondary;
        icon = Icons.all_inclusive;
        break;
      case DrumStatusFilter.alert:
        iconColor = Colors.red;
        icon = Icons.thermostat;
        break;
      case DrumStatusFilter.running:
        iconColor = AppColors.green100;
        icon = Icons.settings;
        break;
      case DrumStatusFilter.rest:
        iconColor = AppColors.green100;
        icon = Icons.pause;
        break;
      case DrumStatusFilter.empty:
        iconColor = Colors.grey;
        icon = Icons.not_interested;
        break;
    }

    return PopupMenuItem<DrumStatusFilter>(
      value: filter,
      height: 48,
      child: Row(
        children: [
          SizedBox(
            width: 24,
            child: isSelected
                ? Icon(Icons.check, size: 18, color: AppColors.green100)
                : Icon(icon, size: 18, color: iconColor),
          ),
          const SizedBox(width: 8),
          Text(
            filter.displayName,
            style: TextStyle(
              color: isSelected ? AppColors.green100 : AppColors.textPrimary,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
