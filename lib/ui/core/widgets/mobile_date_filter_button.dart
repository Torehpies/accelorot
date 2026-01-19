// lib/ui/core/widgets/mobile_date_filter_button.dart
import 'package:flutter/material.dart';
import '../themes/app_theme.dart';

/// Date filter types for mobile
enum DateFilterType {
  none,
  today,
  yesterday,
  last7Days,
  last30Days,
  custom,
}

/// Date filter range model
class DateFilterRange {
  final DateFilterType type;
  final DateTime? startDate;
  final DateTime? endDate;
  final DateTime? customDate;

  const DateFilterRange({
    required this.type,
    this.startDate,
    this.endDate,
    this.customDate,
  });

  bool get isActive => type != DateFilterType.none;

  @override
  String toString() => 'DateFilterRange(type: $type, start: $startDate, end: $endDate)';
}

/// Mobile-optimized 40x40 date filter button with badge indicator
class MobileDateFilterButton extends StatefulWidget {
  final ValueChanged<DateFilterRange> onFilterChanged;
  final double size;
  final double borderRadius;
  final Color? backgroundColor;
  final Color? iconColor;
  final Color? activeIndicatorColor;

  const MobileDateFilterButton({
    super.key,
    required this.onFilterChanged,
    this.size = 40,
    this.borderRadius = 12,
    this.backgroundColor,
    this.iconColor,
    this.activeIndicatorColor,
  });

  @override
  State<MobileDateFilterButton> createState() => _MobileDateFilterButtonState();
}

class _MobileDateFilterButtonState extends State<MobileDateFilterButton> {
  DateFilterRange _currentFilter = const DateFilterRange(type: DateFilterType.none);

  void _showFilterMenu() {
    final RenderBox button = context.findRenderObject() as RenderBox;
    final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    final RelativeRect position = RelativeRect.fromRect(
      Rect.fromPoints(
        button.localToGlobal(Offset.zero, ancestor: overlay),
        button.localToGlobal(button.size.bottomRight(Offset.zero), ancestor: overlay),
      ),
      Offset.zero & overlay.size,
    );

    showMenu<DateFilterType>(
      context: context,
      position: position,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 8,
      items: [
        const PopupMenuItem(
          value: DateFilterType.today,
          child: Text('Today'),
        ),
        const PopupMenuItem(
          value: DateFilterType.yesterday,
          child: Text('Yesterday'),
        ),
        const PopupMenuItem(
          value: DateFilterType.last7Days,
          child: Text('Last 7 Days'),
        ),
        const PopupMenuItem(
          value: DateFilterType.last30Days,
          child: Text('Last 30 Days'),
        ),
        const PopupMenuItem(
          value: DateFilterType.custom,
          child: Text('Custom Date'),
        ),
        if (_currentFilter.isActive) ...[
          const PopupMenuDivider(),
          const PopupMenuItem(
            value: DateFilterType.none,
            child: Text('Clear Filter'),
          ),
        ],
      ],
    ).then((selected) {
      if (selected != null) {
        if (selected == DateFilterType.none) {
          _clearFilter();
        } else {
          _handleFilterSelection(selected);
        }
      }
    });
  }

  void _handleFilterSelection(DateFilterType type) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    DateFilterRange newFilter;

    switch (type) {
      case DateFilterType.today:
        newFilter = DateFilterRange(
          type: DateFilterType.today,
          startDate: today,
          endDate: today.add(const Duration(days: 1)),
        );
        break;

      case DateFilterType.yesterday:
        final yesterday = today.subtract(const Duration(days: 1));
        newFilter = DateFilterRange(
          type: DateFilterType.yesterday,
          startDate: yesterday,
          endDate: today,
        );
        break;

      case DateFilterType.last7Days:
        newFilter = DateFilterRange(
          type: DateFilterType.last7Days,
          startDate: today.subtract(const Duration(days: 6)),
          endDate: today.add(const Duration(days: 1)),
        );
        break;

      case DateFilterType.last30Days:
        newFilter = DateFilterRange(
          type: DateFilterType.last30Days,
          startDate: today.subtract(const Duration(days: 29)),
          endDate: today.add(const Duration(days: 1)),
        );
        break;

      case DateFilterType.custom:
        final pickedDate = await showDatePicker(
          context: context,
          initialDate: today,
          firstDate: DateTime(2020),
          lastDate: today,
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: ColorScheme.light(
                  primary: widget.backgroundColor ?? AppColors.green100,
                  onPrimary: Colors.white,
                  surface: Colors.white,
                  onSurface: AppColors.textPrimary,
                ),
              ),
              child: child!,
            );
          },
        );

        if (pickedDate != null) {
          final selectedDay = DateTime(pickedDate.year, pickedDate.month, pickedDate.day);
          newFilter = DateFilterRange(
            type: DateFilterType.custom,
            startDate: selectedDay,
            endDate: selectedDay.add(const Duration(days: 1)),
            customDate: selectedDay,
          );
        } else {
          return;
        }
        break;

      case DateFilterType.none:
        return;
    }

    setState(() {
      _currentFilter = newFilter;
    });
    widget.onFilterChanged(newFilter);
  }

  void _clearFilter() {
    setState(() {
      _currentFilter = const DateFilterRange(type: DateFilterType.none);
    });
    widget.onFilterChanged(_currentFilter);
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = widget.backgroundColor ?? AppColors.green100;
    final iconColor = widget.iconColor ?? Colors.white;
    final indicatorColor = widget.activeIndicatorColor ?? Colors.white;

    return Container(
      height: widget.size,
      width: widget.size,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(widget.borderRadius),
      ),
      child: Stack(
        children: [
          // Main button
          IconButton(
            icon: Icon(
              Icons.calendar_today,
              color: iconColor,
              size: 20,
            ),
            onPressed: _showFilterMenu,
            padding: EdgeInsets.zero,
          ),
          
          // Active indicator dot
          if (_currentFilter.isActive)
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: indicatorColor,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: bgColor,
                    width: 1,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}