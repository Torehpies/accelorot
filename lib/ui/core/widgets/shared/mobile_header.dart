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
  final bool showDateFilter;
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
    this.showDateFilter = true,
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
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      initialDateRange: widget.startDate != null && widget.endDate != null
          ? DateTimeRange(start: widget.startDate!, end: widget.endDate!)
          : null,
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
            color: Colors.black.withValues(alpha: 0.1), // ✅ Fixed deprecation
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
            // Secondary controls: date, search, add button
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.sm,
              ),
              child: Row(
                children: [
                  if (widget.showDateFilter)
                    Flexible(
                      child: Container(
                        height: 40,
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.grey),
                          borderRadius: BorderRadius.circular(8),
                          color: AppColors.background2,
                        ),
                        child: TextButton(
                          onPressed: _selectDateRange,
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.calendar_today,
                                size: 16,
                                color: AppColors.textSecondary,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _getDateRangeText(),
                                  style: Theme.of(context).textTheme.bodyMedium,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Icon(
                                Icons.arrow_drop_down,
                                color: AppColors.textSecondary,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  if (widget.showSearch)
                    Flexible(
                      child: Container(
                        margin: EdgeInsets.only(left: AppSpacing.sm),
                        height: 40,
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.grey),
                          borderRadius: BorderRadius.circular(8),
                          color: AppColors.background2,
                        ),
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: 'Search...',
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
                  if (widget.showAddButton && widget.onAddPressed != null)
                    Container(
                      margin: EdgeInsets.only(left: AppSpacing.sm),
                      height: 40,
                      child: FloatingActionButton.small(
                        onPressed: widget.onAddPressed,
                        backgroundColor: AppColors.green100,
                        child: const Icon(
                          Icons.add,
                          color: Colors.white,
                          size: 18,
                        ),
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

  String _getDateRangeText() {
    if (widget.startDate == null || widget.endDate == null) {
      return 'Select date range';
    }
    final start = _formatDate(widget.startDate!);
    final end = _formatDate(widget.endDate!);
    if (start == end) {
      return start;
    }
    return '$start - $end';
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
