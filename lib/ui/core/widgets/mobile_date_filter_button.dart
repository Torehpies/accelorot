// lib/ui/core/widgets/mobile_date_filter_button.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../themes/app_theme.dart';
import '../../activity_logs/models/activity_common.dart';

/// Mobile date filter button with updated styling
class MobileDateFilterButton extends StatefulWidget {
  final Function(DateFilterRange) onFilterChanged;

  const MobileDateFilterButton({
    super.key,
    required this.onFilterChanged,
  });

  @override
  State<MobileDateFilterButton> createState() => _MobileDateFilterButtonState();
}

class _MobileDateFilterButtonState extends State<MobileDateFilterButton> {
  DateFilterRange _currentFilter = const DateFilterRange(type: DateFilterType.none);

  // UI Colors
  static const _inactiveBg = Color(0xFFF5F5F5); // Light gray background
  static const _inactiveBorder = Color(0xFFE0E0E0); // Gray border
  static const _inactiveIcon = Color(0xFF757575); // Gray icon (Colors.grey[600])

  @override
  Widget build(BuildContext context) {
    final isActive = _currentFilter.isActive;

    return Container(
      height: 40,
      width: 40,
      decoration: BoxDecoration(
        color: _inactiveBg, // Always gray background
        border: Border.all(
          color: _inactiveBorder, // Always gray border
          width: 1,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        children: [
          // Filter icon button
          IconButton(
            icon: Icon(
              Icons.calendar_today,
              color: isActive ? AppColors.green100 : _inactiveIcon, // GREEN when active
              size: 20,
            ),
            onPressed: _showFilterOptions,
            padding: EdgeInsets.zero,
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
                    color: _inactiveBg,
                    width: 1.5,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showFilterOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Filter by Date',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (_currentFilter.isActive)
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _currentFilter = const DateFilterRange(type: DateFilterType.none);
                        });
                        widget.onFilterChanged(_currentFilter);
                        Navigator.pop(context);
                      },
                      child: Text(
                        'Clear',
                        style: TextStyle(color: AppColors.green100),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),

              // Quick filters
              _buildFilterOption('Today', DateFilterType.today),
              _buildFilterOption('Yesterday', DateFilterType.yesterday),
              _buildFilterOption('Last 7 Days', DateFilterType.last7Days),
              _buildFilterOption('Last 30 Days', DateFilterType.last30Days),
              
              const Divider(height: 32),

              // Custom date picker
              _buildCustomDateOption(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterOption(String label, DateFilterType type) {
    final isSelected = _currentFilter.type == type;

    return ListTile(
      title: Text(label),
      trailing: isSelected
          ? Icon(Icons.check_circle, color: AppColors.green100)
          : null,
      onTap: () {
        setState(() {
          _currentFilter = DateFilterRange(type: type);
        });
        widget.onFilterChanged(_currentFilter);
        Navigator.pop(context);
      },
    );
  }

  Widget _buildCustomDateOption() {
    return ListTile(
      leading: Icon(Icons.date_range, color: AppColors.green100),
      title: const Text('Custom Date'),
      subtitle: _currentFilter.type == DateFilterType.custom
          ? Text(
              DateFormat('MMM d, y').format(_currentFilter.customDate!),
              style: TextStyle(color: AppColors.green100, fontSize: 12),
            )
          : null,
      onTap: () async {
        Navigator.pop(context);
        
        final picked = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(2020),
          lastDate: DateTime.now(),
        );

        if (picked != null) {
          setState(() {
            _currentFilter = DateFilterRange(
              type: DateFilterType.custom,
              customDate: picked,
            );
          });
          widget.onFilterChanged(_currentFilter);
        }
      },
    );
  }
}