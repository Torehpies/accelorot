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

  // New properties for enhanced functionality
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback? onRetry;
  final List<String>? filterChips;
  final String? selectedFilter;
  final ValueChanged<String>? onFilterChanged;
  final bool showFilterChips;

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
    this.isLoading = false,
    this.errorMessage,
    this.onRetry,
    this.filterChips,
    this.selectedFilter,
    this.onFilterChanged,
    this.showFilterChips = false,
  });

  @override
  State<MobileHeader> createState() => _MobileHeaderState();

  @override
  Size get preferredSize {
    double height = kToolbarHeight + 56.0; // main bar + secondary controls

    if (showFilterChips &&
        filterChips != null &&
        filterChips!.isNotEmpty) {
      height += 52.0;
    }

    if (errorMessage != null) {
      height += 60.0;
    }

    return Size.fromHeight(height);
  }
}

class _MobileHeaderState extends State<MobileHeader>
    with SingleTickerProviderStateMixin {
  late TextEditingController _searchController;
  late String _dropdownValue;
  AnimationController? _shimmerController;
  Animation<double>? _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.searchQuery);
    _dropdownValue = widget.dropdownValue ?? '';

    if (widget.isLoading) {
      _startShimmerAnimation();
    }
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

    // Manage shimmer animation based on loading state
    if (!oldWidget.isLoading && widget.isLoading) {
      _startShimmerAnimation();
    } else if (oldWidget.isLoading && !widget.isLoading) {
      _stopShimmerAnimation();
    }
  }

  void _startShimmerAnimation() {
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _pulseAnimation = CurvedAnimation(
      parent: _shimmerController!,
      curve: Curves.easeInOut,
    );
  }

  void _stopShimmerAnimation() {
    _shimmerController?.stop();
    _shimmerController?.dispose();
    _shimmerController = null;
    _pulseAnimation = null;
  }

  @override
  void dispose() {
    _searchController.dispose();
    _shimmerController?.dispose();
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
            // Error banner (if error exists)
            if (widget.errorMessage != null) _buildErrorBanner(),

            // Main header bar with title and optional dropdown
            Container(
              height: kToolbarHeight,
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Row(
                children: [
                  Expanded(
                    child: widget.isLoading
                        ? _buildSkeletonBox(height: 24, width: 150)
                        : Text(
                            widget.title,
                            style: Theme.of(context).textTheme.titleLarge,
                            overflow: TextOverflow.ellipsis,
                          ),
                  ),
                  if (widget.showDropdown && widget.dropdownItems != null)
                    widget.isLoading
                        ? _buildSkeletonBox(height: 40, width: 120)
                        : Container(
                            margin: EdgeInsets.only(left: AppSpacing.sm),
                            padding:
                                EdgeInsets.symmetric(horizontal: AppSpacing.md),
                            decoration: BoxDecoration(
                              border: Border.all(color: AppColors.grey),
                              borderRadius: BorderRadius.circular(8),
                              color: AppColors.background2,
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _dropdownValue.isEmpty
                                    ? null
                                    : _dropdownValue,
                                hint: Text(
                                  widget.dropdownHint!,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                          color: AppColors.textSecondary),
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

            // Filter chips row (if enabled)
            if (widget.showFilterChips &&
                widget.filterChips != null &&
                widget.filterChips!.isNotEmpty)
              _buildFilterChipsRow(),

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
                      child: widget.isLoading
                          ? _buildSkeletonBox(height: 40, width: 150)
                          : Container(
                              height: 40,
                              decoration: BoxDecoration(
                                border: Border.all(color: AppColors.grey),
                                borderRadius: BorderRadius.circular(8),
                                color: AppColors.background2,
                              ),
                              child: TextButton(
                                onPressed: _selectDateRange,
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: AppSpacing.md),
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
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium,
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
                      child: widget.isLoading
                          ? Container(
                              margin: EdgeInsets.only(left: AppSpacing.sm),
                              child: _buildSkeletonBox(height: 40, width: 200),
                            )
                          : Container(
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
                                      ?.copyWith(
                                          color: AppColors.textSecondary),
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
                      child: widget.isLoading
                          ? _buildSkeletonBox(height: 40, width: 40)
                          : FloatingActionButton.small(
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

  /// Error banner with retry button
  Widget _buildErrorBanner() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: AppColors.redBackground,
        border: Border(
          bottom: BorderSide(
            color: AppColors.redForeground.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: AppColors.redForeground,
            size: 20,
          ),
          SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              widget.errorMessage!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.redForeground,
                    fontSize: 13,
                  ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (widget.onRetry != null) ...[
            SizedBox(width: AppSpacing.sm),
            TextButton(
              onPressed: widget.onRetry,
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.xs,
                ),
                backgroundColor: AppColors.redForeground,
                foregroundColor: Colors.white,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text(
                'Retry',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Filter chips row
  Widget _buildFilterChipsRow() {
    return Container(
      height: 52,
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.xs,
      ),
      child: widget.isLoading
          ? ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 4,
              itemBuilder: (context, index) => Padding(
                padding: EdgeInsets.only(right: AppSpacing.sm),
                child: _buildSkeletonBox(height: 32, width: 80),
              ),
            )
          : ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: widget.filterChips!.length,
              itemBuilder: (context, index) {
                final filter = widget.filterChips![index];
                final isSelected = widget.selectedFilter == filter;

                return Padding(
                  padding: EdgeInsets.only(
                    right: index < widget.filterChips!.length - 1
                        ? AppSpacing.sm
                        : 0,
                  ),
                  child: FilterChip(
                    label: Text(filter),
                    selected: isSelected,
                    onSelected: (_) => widget.onFilterChanged?.call(filter),
                    backgroundColor: AppColors.background2,
                    selectedColor: AppColors.green100,
                    checkmarkColor: Colors.white,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : AppColors.textPrimary,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                      fontSize: 13,
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.xs,
                    ),
                    side: BorderSide(
                      color: isSelected
                          ? AppColors.green100
                          : AppColors.grey,
                      width: isSelected ? 1.5 : 1,
                    ),
                    elevation: isSelected ? 2 : 0,
                    shadowColor: AppColors.green100.withValues(alpha: 0.3),
                  ),
                );
              },
            ),
    );
  }

  /// Animated skeleton box with pulsing effect
  Widget _buildSkeletonBox({
    required double height,
    required double width,
  }) {
    if (_pulseAnimation == null) {
      // Fallback in case animation isn't ready
      return Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: AppColors.grey.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(8),
        ),
      );
    }

    return AnimatedBuilder(
      animation: _pulseAnimation!,
      builder: (context, child) {
        return Container(
          height: height,
          width: width,
          decoration: BoxDecoration(
            color: Color.lerp(
              AppColors.grey.withValues(alpha: 0.3),
              AppColors.grey.withValues(alpha: 0.1),
              _pulseAnimation!.value,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
        );
      },
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
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}