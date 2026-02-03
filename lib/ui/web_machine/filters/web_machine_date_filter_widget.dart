// lib/ui/machine_management/shared/admin/web_machine_date_filter.dart

import 'package:flutter/material.dart';
import '../../core/themes/web_colors.dart';
import '../../core/themes/web_text_styles.dart';

/// Date filter dropdown matching the activity logs style
class WebMachineDateFilter extends StatefulWidget {
  final ValueChanged<DateTime?> onDateSelected;
  final bool isLoading;

  const WebMachineDateFilter({
    super.key,
    required this.onDateSelected,
    this.isLoading = false,
  });

  @override
  State<WebMachineDateFilter> createState() => _WebMachineDateFilterState();
}

class _WebMachineDateFilterState extends State<WebMachineDateFilter> {
  DateTime? _selectedDate;
  DateFilterOption _selectedOption = DateFilterOption.none;

  void _showFilterMenu() {
    if (widget.isLoading) return;

    final RenderBox button = context.findRenderObject() as RenderBox;
    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;
    final RelativeRect position = RelativeRect.fromRect(
      Rect.fromPoints(
        button.localToGlobal(Offset.zero, ancestor: overlay),
        button.localToGlobal(
          button.size.bottomRight(Offset.zero),
          ancestor: overlay,
        ),
      ),
      Offset.zero & overlay.size,
    );

    showMenu<DateFilterOption>(
      context: context,
      position: position,
      color: WebColors.cardBackground,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      elevation: 8,
      items: const [
        PopupMenuItem(value: DateFilterOption.today, child: Text('Today')),
        PopupMenuItem(
          value: DateFilterOption.yesterday,
          child: Text('Yesterday'),
        ),
        PopupMenuItem(
          value: DateFilterOption.last7Days,
          child: Text('Last 7 Days'),
        ),
        PopupMenuItem(
          value: DateFilterOption.last30Days,
          child: Text('Last 30 Days'),
        ),
        PopupMenuItem(
          value: DateFilterOption.custom,
          child: Text('Custom Date'),
        ),
      ],
    ).then((selected) {
      if (selected != null) {
        _handleFilterSelection(selected);
      }
    });
  }

  void _handleFilterSelection(DateFilterOption option) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    DateTime? filterDate;

    switch (option) {
      case DateFilterOption.today:
        filterDate = today;
        break;

      case DateFilterOption.yesterday:
        filterDate = today.subtract(const Duration(days: 1));
        break;

      case DateFilterOption.last7Days:
        filterDate = today.subtract(const Duration(days: 6));
        break;

      case DateFilterOption.last30Days:
        filterDate = today.subtract(const Duration(days: 29));
        break;

      case DateFilterOption.custom:
        final pickedDate = await showDatePicker(
          context: context,
          initialDate: today,
          firstDate: DateTime(2020),
          lastDate: today,
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: const ColorScheme.light(
                  primary: Color(0xFF10B981),
                  onPrimary: Colors.white,
                  surface: Colors.white,
                  onSurface: Color(0xFF111827),
                ),
              ),
              child: child!,
            );
          },
        );

        if (pickedDate != null) {
          filterDate = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
          );
        } else {
          return;
        }
        break;

      case DateFilterOption.none:
        filterDate = null;
        break;
    }

    setState(() {
      _selectedOption = option;
      _selectedDate = filterDate;
    });
    widget.onDateSelected(filterDate);
  }

  void _clearFilter() {
    if (widget.isLoading) return;

    setState(() {
      _selectedOption = DateFilterOption.none;
      _selectedDate = null;
    });
    widget.onDateSelected(null);
  }

  String _getDisplayText() {
    if (_selectedDate == null) return 'Date Filter';

    switch (_selectedOption) {
      case DateFilterOption.today:
        return 'Today';
      case DateFilterOption.yesterday:
        return 'Yesterday';
      case DateFilterOption.last7Days:
        return 'Last 7 Days';
      case DateFilterOption.last30Days:
        return 'Last 30 Days';
      case DateFilterOption.custom:
        return '${_selectedDate!.month}/${_selectedDate!.day}/${_selectedDate!.year}';
      case DateFilterOption.none:
        return 'Date Filter';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isActive = _selectedDate != null;

    return MouseRegion(
      cursor: widget.isLoading
          ? SystemMouseCursors.basic
          : SystemMouseCursors.click,
      child: Opacity(
        opacity: widget.isLoading ? 0.5 : 1.0,
        child: InkWell(
          onTap: widget.isLoading ? null : _showFilterMenu,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: WebColors.inputBackground,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: WebColors.cardBorder),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 16,
                  color: isActive
                      ? const Color(0xFF10B981)
                      : WebColors.textLabel,
                ),
                if (isActive) ...[
                  const SizedBox(width: 8),
                  Text(_getDisplayText(), style: WebTextStyles.bodyMedium),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.arrow_drop_down,
                    size: 20,
                    color: const Color(0xFF10B981),
                  ),
                  const SizedBox(width: 4),
                  InkWell(
                    onTap: widget.isLoading ? null : _clearFilter,
                    borderRadius: BorderRadius.circular(4),
                    child: const Icon(
                      Icons.clear,
                      size: 16,
                      color: WebColors.textLabel,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

enum DateFilterOption { none, today, yesterday, last7Days, last30Days, custom }
