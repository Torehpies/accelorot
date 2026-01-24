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
  final DateTime? startDate; // used as initial date for picker
  final ValueChanged<DateTimeRange?>? onDateRangeChanged;
  final String? searchQuery;
  final ValueChanged<String>? onSearchChanged;
  final bool showSearch;
  final bool showDropdown;
  final bool showFilterButton;
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
    this.onDateRangeChanged,
    this.searchQuery,
    this.onSearchChanged,
    this.showSearch = false,
    this.showDropdown = false,
    this.showFilterButton = false,
    this.showAddButton = false,
    this.onAddPressed,
    this.elevation = 0.0,
    this.backgroundColor,
    this.foregroundColor,
  });

  @override
  State<MobileHeader> createState() => _MobileHeaderState();

  @override
  Size get preferredSize {
    bool hasSecondRow = showSearch || showFilterButton || showAddButton;
    return Size.fromHeight(
      hasSecondRow ? kToolbarHeight + 56.0 : kToolbarHeight,
    );
  }
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

  Future<void> _selectSingleDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: widget.startDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      // Treat single date as a 1-day range
      final range = DateTimeRange(start: picked, end: picked);
      widget.onDateRangeChanged?.call(range);
    }
  }

  @override
  Widget build(BuildContext context) {
    bool hasSecondRow =
        widget.showSearch || widget.showFilterButton || widget.showAddButton;

    return Container(
      decoration: BoxDecoration(
        color: widget.backgroundColor ?? AppColors.background,
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
            // Main header bar
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
                            style: Theme.of(context).textTheme.bodyMedium
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

            // Secondary row
            if (hasSecondRow)
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.sm,
                ),
                child: Row(
                  children: [
                    if (widget.showSearch)
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
                              hintText:
                                  'Search ${widget.title.toLowerCase()}...',
                              hintStyle: Theme.of(context).textTheme.bodyMedium
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
                    if (widget.showFilterButton)
                      Container(
                        margin: EdgeInsets.only(
                          left: widget.showSearch ? AppSpacing.sm : 0,
                        ),
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: AppColors.background2,
                          border: Border.all(color: AppColors.grey),
                        ),
                        child: IconButton(
                          onPressed: _selectSingleDate,
                          icon: Icon(
                            Icons.calendar_today,
                            color: AppColors.textSecondary,
                            size: 18,
                          ),
                          padding: EdgeInsets.zero,
                        ),
                      ),
                    if (widget.showAddButton && widget.onAddPressed != null)
                      Container(
                        margin: EdgeInsets.only(
                          left: (widget.showSearch || widget.showFilterButton)
                              ? AppSpacing.sm
                              : 0,
                        ),
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: AppColors.green100,
                        ),
                        child: IconButton(
                          onPressed: widget.onAddPressed,
                          icon: Icon(Icons.add, color: Colors.white, size: 18),
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
