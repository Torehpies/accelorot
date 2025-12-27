import 'package:flutter/material.dart';
import 'custom_date_range_modal.dart';

enum DateFilterType {
  none,
  today,
  last3Days,
  last7Days,
  last30Days,
  custom,
}

class DateFilterWidget extends StatelessWidget {
  final DateFilterType selectedFilter;
  final DateTime? customStartDate;
  final DateTime? customEndDate;
  final Function(DateFilterType) onFilterChanged;
  final Function(DateTime?, DateTime?) onCustomRangeSelected;
  final bool isDesktop;
  final bool isTablet;
  final bool isMobile;

  const DateFilterWidget({
    super.key,
    required this.selectedFilter,
    this.customStartDate,
    this.customEndDate,
    required this.onFilterChanged,
    required this.onCustomRangeSelected,
    required this.isDesktop,
    required this.isTablet,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    final buttonSize = isDesktop ? 42.0 : (isTablet ? 40.0 : 38.0);
    final iconSize = isDesktop ? 20.0 : (isTablet ? 19.0 : 18.0);

    return PopupMenuButton<DateFilterType>(
      onSelected: onFilterChanged,
      itemBuilder: (context) => [
        PopupMenuItem<DateFilterType>(
          value: DateFilterType.none,
          child: Row(
            children: [
              Icon(
                Icons.filter_alt_off,
                size: 18,
                color: selectedFilter == DateFilterType.none
                    ? Colors.blue
                    : Colors.grey[700],
              ),
              const SizedBox(width: 8),
              Text(
                'No Filter',
                style: TextStyle(
                  color: selectedFilter == DateFilterType.none
                      ? Colors.blue
                      : Colors.grey[700],
                  fontWeight: selectedFilter == DateFilterType.none
                      ? FontWeight.w600
                      : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
        const PopupMenuDivider(),
        PopupMenuItem<DateFilterType>(
          value: DateFilterType.today,
          child: Row(
            children: [
              Icon(
                Icons.today,
                size: 18,
                color: selectedFilter == DateFilterType.today
                    ? Colors.blue
                    : Colors.grey[700],
              ),
              const SizedBox(width: 8),
              Text(
                'Today',
                style: TextStyle(
                  color: selectedFilter == DateFilterType.today
                      ? Colors.blue
                      : Colors.grey[700],
                  fontWeight: selectedFilter == DateFilterType.today
                      ? FontWeight.w600
                      : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
        PopupMenuItem<DateFilterType>(
          value: DateFilterType.last3Days,
          child: Row(
            children: [
              Icon(
                Icons.calendar_view_week,
                size: 18,
                color: selectedFilter == DateFilterType.last3Days
                    ? Colors.blue
                    : Colors.grey[700],
              ),
              const SizedBox(width: 8),
              Text(
                'Last 3 Days',
                style: TextStyle(
                  color: selectedFilter == DateFilterType.last3Days
                      ? Colors.blue
                      : Colors.grey[700],
                  fontWeight: selectedFilter == DateFilterType.last3Days
                      ? FontWeight.w600
                      : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
        PopupMenuItem<DateFilterType>(
          value: DateFilterType.last7Days,
          child: Row(
            children: [
              Icon(
                Icons.view_week,
                size: 18,
                color: selectedFilter == DateFilterType.last7Days
                    ? Colors.blue
                    : Colors.grey[700],
              ),
              const SizedBox(width: 8),
              Text(
                'Last 7 Days',
                style: TextStyle(
                  color: selectedFilter == DateFilterType.last7Days
                      ? Colors.blue
                      : Colors.grey[700],
                  fontWeight: selectedFilter == DateFilterType.last7Days
                      ? FontWeight.w600
                      : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
        PopupMenuItem<DateFilterType>(
          value: DateFilterType.last30Days,
          child: Row(
            children: [
              Icon(
                Icons.calendar_month,
                size: 18,
                color: selectedFilter == DateFilterType.last30Days
                    ? Colors.blue
                    : Colors.grey[700],
              ),
              const SizedBox(width: 8),
              Text(
                'Last 30 Days',
                style: TextStyle(
                  color: selectedFilter == DateFilterType.last30Days
                      ? Colors.blue
                      : Colors.grey[700],
                  fontWeight: selectedFilter == DateFilterType.last30Days
                      ? FontWeight.w600
                      : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
        PopupMenuItem<DateFilterType>(
          value: DateFilterType.custom,
          onTap: () {
            // Show custom date range modal in center
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _showCustomDateRangeModal(context);
            });
          },
          child: Row(
            children: [
              Icon(
                Icons.date_range,
                size: 18,
                color: selectedFilter == DateFilterType.custom
                    ? Colors.blue
                    : Colors.grey[700],
              ),
              const SizedBox(width: 8),
              Text(
                'Custom Range',
                style: TextStyle(
                  color: selectedFilter == DateFilterType.custom
                      ? Colors.blue
                      : Colors.grey[700],
                  fontWeight: selectedFilter == DateFilterType.custom
                      ? FontWeight.w600
                      : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ],
      child: Container(
        width: buttonSize,
        height: buttonSize,
        decoration: BoxDecoration(
          color: selectedFilter != DateFilterType.none
              ? Colors.blue.shade50
              : Colors.white,
          border: Border.all(
            color: selectedFilter != DateFilterType.none
                ? Colors.blue.shade200
                : Colors.grey.shade300,
          ),
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Icon(
            Icons.date_range_outlined,
            size: iconSize,
            color: selectedFilter != DateFilterType.none
                ? Colors.blue.shade600
                : Colors.grey.shade600,
          ),
        ),
      ),
    );
  }

  void _showCustomDateRangeModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return CustomDateRangeModal(
          initialStartDate: customStartDate,
          initialEndDate: customEndDate,
          onDateRangeSelected: (start, end) {
            onCustomRangeSelected(start, end);
          },
          isDesktop: isDesktop,
          isTablet: isTablet,
          isMobile: isMobile,
        );
      },
    );
  }
}