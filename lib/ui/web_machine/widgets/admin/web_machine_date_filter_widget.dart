// lib/.../ui/widgets/MachineDateFilterWidget.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MachineDateFilterWidget extends StatefulWidget {
  final DateTime? initialSelectedDate; 
  final Function(DateTime?)? onDateSelected; 
  final Function()? onClose;

  const MachineDateFilterWidget({
    super.key,
    this.initialSelectedDate,
    this.onDateSelected,
    this.onClose,
  });

  @override
  State<MachineDateFilterWidget> createState() => _MachineDateFilterWidgetState();
}

class _MachineDateFilterWidgetState extends State<MachineDateFilterWidget> {
  late DateTime _currentMonth;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _currentMonth = widget.initialSelectedDate ?? DateTime.now();
    _selectedDate = widget.initialSelectedDate;
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
      _selectedDate = date;
    });
    widget.onDateSelected?.call(_selectedDate);
  }

  void _clearSelection() {
    setState(() {
      _selectedDate = null;
      _currentMonth = DateTime.now();
    });
    widget.onDateSelected?.call(null);
    widget.onClose?.call();
  }

  List<DateTime> _getDaysInMonth() {
    final firstDayOfMonth = DateTime(_currentMonth.year, _currentMonth.month, 1);
    final lastDayOfMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 0);

    final days = <DateTime>[];

    final firstWeekday = firstDayOfMonth.weekday % 7;
    for (int i = 0; i < firstWeekday; i++) {
      days.add(DateTime(_currentMonth.year, _currentMonth.month, 0 - (firstWeekday - i - 1)));
    }


    for (int day = 1; day <= lastDayOfMonth.day; day++) {
      days.add(DateTime(_currentMonth.year, _currentMonth.month, day));
    }

    return days;
  }

  bool _isSameDay(DateTime? a, DateTime? b) {
    if (a == null || b == null) return false;
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return _isSameDay(date, now);
  }

  bool _isCurrentMonth(DateTime date) {
    return date.month == _currentMonth.month && date.year == _currentMonth.year;
  }

  @override
  Widget build(BuildContext context) {
    final monthFormat = DateFormat('MMMM yyyy');
    final days = _getDaysInMonth();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                monthFormat.format(_currentMonth),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF111827),
                ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left),
                    onPressed: _previousMonth,
                    color: const Color(0xFF6B7280),
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right),
                    onPressed: _nextMonth,
                    color: const Color(0xFF6B7280),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Weekday headers
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']
                .map((day) => Expanded(
                      child: Center(
                        child: Text(
                          day,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: 8),

          // Calendar grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(), // Disable scrolling within the grid
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1,
              mainAxisSpacing: 2,
              crossAxisSpacing: 2,
            ),
            itemCount: days.length,
            itemBuilder: (context, index) {
              final date = days[index];
              final isSelected = _isSameDay(date, _selectedDate);
              final isToday = _isToday(date);
              final isCurrentMonth = _isCurrentMonth(date);

              return InkWell(
                onTap: () => _selectDate(date),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  // margin: const EdgeInsets.all(2), // Replaced by grid delegate spacing
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF10B981)
                        : (isToday ? const Color(0xFFD1FAE5) : Colors.transparent),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isToday && !isSelected
                          ? const Color(0xFF10B981)
                          : Colors.transparent,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      '${date.day}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: isSelected || isToday ? FontWeight.w600 : FontWeight.normal,
                        color: isSelected
                            ? Colors.white
                            : (isCurrentMonth ? const Color(0xFF111827) : const Color(0xFF9CA3AF)),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 16),

          // Selected Date Display & Clear Button
          if (_selectedDate != null)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.event,
                    size: 20,
                    color: Color(0xFF10B981),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Selected: ${DateFormat('MMMM dd, yyyy').format(_selectedDate!)}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF111827),
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: _clearSelection,
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFFEF4444),
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                    child: const Text('Clear'),
                  ),
                ],
              ),
            )
          else
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _clearSelection,
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFFEF4444),
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                ),
                child: const Text('Clear Filter'),
              ),
            ),

          // Close Btn
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(); 
              widget.onClose?.call(); 
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }
}