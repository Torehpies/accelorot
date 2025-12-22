import 'package:flutter/material.dart';

enum DateFilter {
  all('All'),
  today('Today'),
  last3Days('Last 3 Days'),
  last7Days('Last 7 Days'),
  last30Days('Last 30 Days'),
  custom('Custom Range');

  final String label;
  const DateFilter(this.label);
}

class DateFilterDropdown extends StatelessWidget {
  final DateFilter selectedFilter;
  final Function(DateFilter) onFilterChanged;
  final VoidCallback? onCustomRangePressed;
  final bool isDesktop;

  const DateFilterDropdown({
    super.key,
    required this.selectedFilter,
    required this.onFilterChanged,
    this.onCustomRangePressed,
    this.isDesktop = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE5E7EB)),
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.calendar_today,
            size: 18,
            color: Color(0xFF6B7280),
          ),
          const SizedBox(width: 8),
          if (isDesktop)
            Text(
              selectedFilter.label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF1F2937),
              ),
            ),
          const SizedBox(width: 4),
          PopupMenuButton<DateFilter>(
            icon: const Icon(
              Icons.keyboard_arrow_down,
              size: 20,
              color: Color(0xFF6B7280),
            ),
            offset: const Offset(0, 40),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            itemBuilder: (context) => [
              _buildMenuItem(DateFilter.all),
              const PopupMenuDivider(height: 1),
              _buildMenuItem(DateFilter.today),
              _buildMenuItem(DateFilter.last3Days),
              _buildMenuItem(DateFilter.last7Days),
              _buildMenuItem(DateFilter.last30Days),
              const PopupMenuDivider(height: 1),
              _buildMenuItem(DateFilter.custom, hasIcon: true),
            ],
            onSelected: (DateFilter filter) {
              if (filter == DateFilter.custom && onCustomRangePressed != null) {
                onCustomRangePressed!();
              } else {
                onFilterChanged(filter);
              }
            },
          ),
        ],
      ),
    );
  }

  PopupMenuItem<DateFilter> _buildMenuItem(DateFilter filter, {bool hasIcon = false}) {
    final isSelected = filter == selectedFilter;
    
    return PopupMenuItem<DateFilter>(
      value: filter,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              if (hasIcon) ...[
                const Icon(
                  Icons.date_range,
                  size: 18,
                  color: Color(0xFF6B7280),
                ),
                const SizedBox(width: 8),
              ],
              Text(
                filter.label,
                style: TextStyle(
                  fontSize: 14,
                  color: isSelected ? const Color(0xFF10B981) : const Color(0xFF1F2937),
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ],
          ),
          if (isSelected)
            const Icon(
              Icons.check,
              size: 18,
              color: Color(0xFF10B981),
            ),
        ],
      ),
    );
  }
}