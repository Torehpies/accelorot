// lib/ui/core/widgets/filters/mobile_status_filter_button.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../themes/app_theme.dart';
import '../../../../data/models/machine_model.dart';

/// Mobile status filter button with dropdown menu
class MobileStatusFilterButton extends StatefulWidget {
  final Function(MachineStatusFilter) onFilterChanged;
  final MachineStatusFilter currentFilter;
  final bool isLoading;

  const MobileStatusFilterButton({
    super.key,
    required this.onFilterChanged,
    required this.currentFilter,
    this.isLoading = false,
  });

  @override
  State<MobileStatusFilterButton> createState() => _MobileStatusFilterButtonState();
}

class _MobileStatusFilterButtonState extends State<MobileStatusFilterButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isActive = widget.currentFilter != MachineStatusFilter.all;
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
                width: 40,
                decoration: BoxDecoration(
                  color: backgroundColor,
                  border: Border.all(
                    color: AppColors.grey,
                    width: 1.5,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Stack(
                  children: [
                    // Status filter icon (centered)
                    Center(
                      child: Icon(
                        Icons.tune,
                        color: isActive ? AppColors.green100 : AppColors.textSecondary,
                        size: 20,
                      ),
                    ),

                    // Badge indicator (top-right dot)
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
                            border: Border.all(
                              color: backgroundColor,
                              width: 1.5,
                            ),
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

    // Build menu items
    final List<PopupMenuEntry<String>> menuItems = [];

    // Add "Clear Filter" at top if filter is active
    if (widget.currentFilter != MachineStatusFilter.all) {
      menuItems.add(
        PopupMenuItem<String>(
          value: 'clear',
          child: Row(
            children: [
              Icon(Icons.clear, size: 18, color: AppColors.textSecondary),
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

    // Add status filter options
    menuItems.addAll([
      _buildMenuItem('all', 'All Machines', MachineStatusFilter.all),
      _buildMenuItem('active', 'Active', MachineStatusFilter.active),
      _buildMenuItem('archived', 'Archived', MachineStatusFilter.inactive),
      _buildMenuItem('suspended', 'Suspended', MachineStatusFilter.underMaintenance),
    ]);

    final String? selected = await showMenu<String>(
      context: context,
      position: position,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 8,
      color: Colors.white,
      items: menuItems,
    );

    if (selected != null) {
      HapticFeedback.selectionClick();
      
      if (selected == 'clear') {
        widget.onFilterChanged(MachineStatusFilter.all);
      } else {
        _handleFilterSelection(selected);
      }
    }
  }

  PopupMenuItem<String> _buildMenuItem(String value, String label, MachineStatusFilter filter) {
    final isSelected = widget.currentFilter == filter;

    return PopupMenuItem<String>(
      value: value,
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
          Text(label),
        ],
      ),
    );
  }

  void _handleFilterSelection(String value) {
    MachineStatusFilter newFilter;

    switch (value) {
      case 'all':
        newFilter = MachineStatusFilter.all;
        break;
      case 'active':
        newFilter = MachineStatusFilter.active;
        break;
      case 'archived':
        newFilter = MachineStatusFilter.inactive;
        break;
      case 'suspended':
        newFilter = MachineStatusFilter.underMaintenance;
        break;
      default:
        return;
    }

    widget.onFilterChanged(newFilter);
  }
}