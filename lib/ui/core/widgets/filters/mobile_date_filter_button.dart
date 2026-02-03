// lib/ui/core/widgets/mobile_date_filter_button.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../themes/app_theme.dart';
import '../../../activity_logs/models/activity_common.dart';

/// Mobile date filter button with dropdown menu
class MobileDateFilterButton extends StatefulWidget {
  final Function(DateFilterRange) onFilterChanged;
  final bool isLoading;

  const MobileDateFilterButton({
    super.key,
    required this.onFilterChanged,
    this.isLoading = false,
  });

  @override
  State<MobileDateFilterButton> createState() => _MobileDateFilterButtonState();
}

class _MobileDateFilterButtonState extends State<MobileDateFilterButton> {
  DateFilterRange _currentFilter = const DateFilterRange(type: DateFilterType.none);
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isActive = _currentFilter.isActive;
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
            message: isActive ? _getFilterDisplayText() : '',
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
                    // Calendar icon (centered)
                    Center(
                      child: Icon(
                        Icons.calendar_today,
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
    // Tooltip is handled by the Tooltip widget automatically on long-press
    // This method exists for explicit long-press gesture handling
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
    if (_currentFilter.isActive) {
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

    // Add date filter options
    menuItems.addAll([
      _buildMenuItem('today', 'Today', DateFilterType.today),
      _buildMenuItem('yesterday', 'Yesterday', DateFilterType.yesterday),
      _buildMenuItem('last7days', 'Last 7 Days', DateFilterType.last7Days),
      _buildMenuItem('last30days', 'Last 30 Days', DateFilterType.last30Days),
      _buildCustomMenuItem(),
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
        _clearFilter();
      } else if (selected == 'custom') {
        await _handleCustomDate();
      } else {
        _handleQuickFilter(selected);
      }
    }
  }

  PopupMenuItem<String> _buildMenuItem(String value, String label, DateFilterType type) {
    final isSelected = _currentFilter.type == type;

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

  PopupMenuItem<String> _buildCustomMenuItem() {
    final isSelected = _currentFilter.type == DateFilterType.custom;

    return PopupMenuItem<String>(
      value: 'custom',
      height: _currentFilter.type == DateFilterType.custom ? 64 : 48,
      child: Row(
        children: [
          SizedBox(
            width: 24,
            child: isSelected
                ? Icon(Icons.check, size: 18, color: AppColors.green100)
                : null,
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Custom Date'),
              if (isSelected && _currentFilter.customDate != null)
                Text(
                  DateFormat('MMM d, y').format(_currentFilter.customDate!),
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.green100,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  void _handleQuickFilter(String value) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    DateFilterRange newFilter;

    switch (value) {
      case 'today':
        newFilter = DateFilterRange(
          type: DateFilterType.today,
          startDate: today,
          endDate: today.add(const Duration(days: 1)),
        );
        break;

      case 'yesterday':
        final yesterday = today.subtract(const Duration(days: 1));
        newFilter = DateFilterRange(
          type: DateFilterType.yesterday,
          startDate: yesterday,
          endDate: today,
        );
        break;

      case 'last7days':
        newFilter = DateFilterRange(
          type: DateFilterType.last7Days,
          startDate: today.subtract(const Duration(days: 6)),
          endDate: today.add(const Duration(days: 1)),
        );
        break;

      case 'last30days':
        newFilter = DateFilterRange(
          type: DateFilterType.last30Days,
          startDate: today.subtract(const Duration(days: 29)),
          endDate: today.add(const Duration(days: 1)),
        );
        break;

      default:
        return;
    }

    setState(() {
      _currentFilter = newFilter;
    });
    widget.onFilterChanged(newFilter);
  }

  Future<void> _handleCustomDate() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: today,
      firstDate: DateTime(2020),
      lastDate: today,
    );

    if (pickedDate != null) {
      final selectedDay = DateTime(pickedDate.year, pickedDate.month, pickedDate.day);
      final newFilter = DateFilterRange(
        type: DateFilterType.custom,
        startDate: selectedDay,
        endDate: selectedDay.add(const Duration(days: 1)),
        customDate: selectedDay,
      );

      setState(() {
        _currentFilter = newFilter;
      });
      widget.onFilterChanged(newFilter);
    }
    // If canceled, previous filter remains unchanged
  }

  void _clearFilter() {
    setState(() {
      _currentFilter = const DateFilterRange(type: DateFilterType.none);
    });
    widget.onFilterChanged(_currentFilter);
  }

  String _getFilterDisplayText() {
    switch (_currentFilter.type) {
      case DateFilterType.today:
        return 'Today';
      case DateFilterType.yesterday:
        return 'Yesterday';
      case DateFilterType.last7Days:
        return 'Last 7 Days';
      case DateFilterType.last30Days:
        return 'Last 30 Days';
      case DateFilterType.custom:
        if (_currentFilter.customDate != null) {
          return DateFormat('MMM d, y').format(_currentFilter.customDate!);
        }
        return 'Custom Date';
      case DateFilterType.none:
        return '';
    }
  }
}