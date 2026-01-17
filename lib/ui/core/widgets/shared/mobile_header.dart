// lib/ui/core/widgets/shared/mobile_header.dart
import 'package:flutter/material.dart';
import '../../constants/spacing.dart'; 
import '../../themes/app_theme.dart'; 

class MobileHeader extends StatefulWidget implements PreferredSizeWidget {
  final String title;
  final List<DropdownMenuItem<String>>? dropdownItems;
  final String? dropdownValue;
  final String? dropdownHint;
  final ValueChanged<String?>? onDropdownChanged;
  final DateTime? startDate;
  final DateTime? endDate;
  final ValueChanged<DateTimeRange?>? onDateRangeChanged;
  final String? searchQuery;
  final ValueChanged<String>? onSearchChanged;
  final bool showSearch;
  final bool showDropdown;
  final bool showFilterButton; // Renamed for clarity (was showDateFilter)
  final bool showAddButton;
  final VoidCallback? onAddPressed;
  final double elevation;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const MobileHeader({
    super.key,
    required this.title,
    this.dropdownItems,
    this.dropdownValue,
    this.dropdownHint = 'Select option',
    this.onDropdownChanged,
    this.startDate,
    this.endDate,
    this.onDateRangeChanged,
    this.searchQuery,
    this.onSearchChanged,
    this.showSearch = true,
    this.showDropdown = true,
    this.showFilterButton = true,
    this.showAddButton = false,
    this.onAddPressed,
    this.elevation = 0.0,
    this.backgroundColor,
    this.foregroundColor,
  });

  @override
  State<MobileHeader> createState() => _MobileHeaderState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 56.0);
}

class _MobileHeaderState extends State<MobileHeader> {
  late TextEditingController _searchController;
  late String _dropdownValue;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.searchQuery);
    _dropdownValue = widget.dropdownValue ?? '';
  }

  @override
  void didUpdateWidget(MobileHeader oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.searchQuery != widget.searchQuery) {
      _searchController.text = widget.searchQuery ?? '';
    }
    if (oldWidget.dropdownValue != widget.dropdownValue) {
      _dropdownValue = widget.dropdownValue ?? '';
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDialog<DateTimeRange>(
      context: context,
      builder: (context) => _CustomDateRangePicker(
        initialStart: widget.startDate,
        initialEnd: widget.endDate,
      ),
    );

    if (picked != null) {
      widget.onDateRangeChanged?.call(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: widget.backgroundColor ?? AppColors.background2,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Main header bar with title and optional dropdown
            Container(
              height: kToolbarHeight,
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.title,
                      style: Theme.of(context).textTheme.titleLarge,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (widget.showDropdown && widget.dropdownItems != null)
                    Container(
                      margin: EdgeInsets.only(left: AppSpacing.sm),
                      padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.grey),
                        borderRadius: BorderRadius.circular(8),
                        color: AppColors.background2,
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _dropdownValue.isEmpty ? null : _dropdownValue,
                          hint: Text(
                            widget.dropdownHint!,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(color: AppColors.textSecondary),
                          ),
                          items: widget.dropdownItems,
                          onChanged: (String? newValue) {
                            setState(() {
                              _dropdownValue = newValue ?? '';
                            });
                            widget.onDropdownChanged?.call(newValue);
                          },
                          icon: Icon(
                            Icons.arrow_drop_down,
                            color: AppColors.textSecondary,
                          ),
                          style: Theme.of(context).textTheme.bodyMedium,
                          isDense: true,
                          padding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            // Secondary controls: search field and filter button
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.sm,
              ),
              child: Row(
                children: [
                  // Search field
                  Expanded(
                    child: Container(
                      height: 40,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: AppColors.background2,
                        border: Border.all(color: AppColors.grey),
                      ),
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Search ${widget.title.toLowerCase()}...',
                          hintStyle: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(color: AppColors.textSecondary),
                          prefixIcon: Icon(
                            Icons.search,
                            color: AppColors.textSecondary,
                            size: 18,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                            vertical: 8,
                          ),
                        ),
                        onChanged: widget.onSearchChanged,
                        onSubmitted: widget.onSearchChanged,
                      ),
                    ),
                  ),
                  
                  // Filter button (opens custom date picker)
                  if (widget.showFilterButton)
                    Container(
                      margin: EdgeInsets.only(left: AppSpacing.sm),
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: AppColors.background2,
                        border: Border.all(color: AppColors.grey),
                      ),
                      child: IconButton(
                        onPressed: _selectDateRange,
                       icon: Icon(
                        Icons.calendar_today, 
                        color: AppColors.textSecondary,
                        size: 18,
                      ),
                        padding: EdgeInsets.zero,
                      ),
                    ),
                  
                  // Add button (for admin's add operator)
                  if (widget.showAddButton && widget.onAddPressed != null)
                    Container(
                      margin: EdgeInsets.only(left: AppSpacing.sm),
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: AppColors.green100,
                      ),
                      child: IconButton(
                        onPressed: widget.onAddPressed,
                        icon: Icon(
                          Icons.add,
                          color: Colors.white,
                          size: 18,
                        ),
                        padding: EdgeInsets.zero,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Custom Date Range Picker
class _CustomDateRangePicker extends StatefulWidget {
  final DateTime? initialStart;
  final DateTime? initialEnd;

  const _CustomDateRangePicker({
    this.initialStart,
    this.initialEnd,
  });

  @override
  State<_CustomDateRangePicker> createState() => _CustomDateRangePickerState();
}

class _CustomDateRangePickerState extends State<_CustomDateRangePicker> {
  late DateTimeRange _selectedRange;
  late DateTime _currentMonth;

  @override
  void initState() {
    super.initState();
    _currentMonth = widget.initialStart ?? DateTime.now();
    _selectedRange = DateTimeRange(
      start: widget.initialStart ?? DateTime.now(),
      end: widget.initialEnd ?? DateTime.now(),
    );
  }

  void _previousMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1);
    });
  }

  void _selectDate(DateTime date) {
    setState(() {
      if (_selectedRange.start == _selectedRange.end &&
          _selectedRange.start.isAtSameMomentAs(date)) {
        // Clear selection if same date is tapped again
        _selectedRange = DateTimeRange(start: date, end: date);
      } else if (_selectedRange.start.isBefore(date)) {
        _selectedRange = DateTimeRange(start: _selectedRange.start, end: date);
      } else {
        _selectedRange = DateTimeRange(start: date, end: _selectedRange.end);
      }
    });
  }

  bool _isDateSelected(DateTime date) {
    return date.isAfter(_selectedRange.start.subtract(const Duration(days: 1))) &&
        date.isBefore(_selectedRange.end.add(const Duration(days: 1)));
  }

  bool _isDateStart(DateTime date) {
    return date.isAtSameMomentAs(_selectedRange.start);
  }

  bool _isDateEnd(DateTime date) {
    return date.isAtSameMomentAs(_selectedRange.end);
  }

  @override
  Widget build(BuildContext context) {
    final daysInMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 0).day;
    final firstDayOfMonth = DateTime(_currentMonth.year, _currentMonth.month, 1);
    final startingDayOfWeek = firstDayOfMonth.weekday % 7; // 0=Sunday, 6=Saturday

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      contentPadding: EdgeInsets.zero,
      content: Container(
        width: double.maxFinite,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header: Month Navigation
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: _previousMonth,
                    icon: const Icon(Icons.arrow_back_ios, size: 16),
                  ),
                  Text(
                    '${_currentMonth.monthName} ${_currentMonth.year}',
                    style: Theme.of(context).textTheme.titleMedium!.copyWith(fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    onPressed: _nextMonth,
                    icon: const Icon(Icons.arrow_forward_ios, size: 16),
                  ),
                ],
              ),
            ),

            // Calendar Grid
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Table(
                columnWidths: {
                  for (int i = 0; i < 7; i++) i: const FlexColumnWidth(1.0)
                },
                children: [
                  // Weekday headers
                  TableRow(
                    children: [
                      for (final day in ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'])
                        Center(
                          child: Text(
                            day,
                            style: Theme.of(context).textTheme.bodySmall!.copyWith(fontWeight: FontWeight.w600),
                          ),
                        ),
                    ],
                  ),
                  // Days
                  ...List.generate(
                    (daysInMonth + startingDayOfWeek + 6) ~/ 7,
                    (weekIndex) {
                      return TableRow(
                        children: List.generate(7, (dayIndex) {
                          final dayNumber = weekIndex * 7 + dayIndex - startingDayOfWeek + 1;
                          if (dayNumber < 1 || dayNumber > daysInMonth) {
                            return const SizedBox();
                          }

                          final date = DateTime(_currentMonth.year, _currentMonth.month, dayNumber);

                          return GestureDetector(
                            onTap: () => _selectDate(date),
                            child: Container(
                              margin: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _isDateSelected(date)
                                    ? Colors.blue.withValues(alpha: 0.1)
                                    : Colors.transparent,
                              ),
                              child: Center(
                                child: Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: _isDateStart(date) || _isDateEnd(date)
                                        ? Colors.blue
                                        : Colors.transparent,
                                  ),
                                  child: Center(
                                    child: Text(
                                      dayNumber.toString(),
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: _isDateStart(date) || _isDateEnd(date)
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                        color: _isDateStart(date) || _isDateEnd(date)
                                            ? Colors.white
                                            : Colors.black87,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                      );
                    },
                  ),
                ],
              ),
            ),

            // Buttons
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context, _selectedRange),
                      child: const Text('OK'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Helper extension for month names
extension MonthName on DateTime {
  String get monthName {
    return [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ][month - 1];
  }
}