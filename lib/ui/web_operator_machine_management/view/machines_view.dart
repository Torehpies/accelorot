import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../ui/machine_management/view_model/operator_machine_notifier.dart';
import '../widgets/stat_card.dart';
import '../widgets/machine_table/machine_table.dart';
import '../widgets/machine_mobile_card.dart';
import '../widgets/pagination.dart';
import '../widgets/search_bar.dart';
import '../widgets/date_filter.dart';
import '../../../../../ui/machine_management/widgets/machine_view_dialog.dart';

/// Main machines view connected to real data - Fully Responsive with Custom Search
class MachinesView extends ConsumerStatefulWidget {
  final String teamId;

  const MachinesView({
    super.key,
    required this.teamId,
  });

  @override
  ConsumerState<MachinesView> createState() => _MachinesViewState();
}

class _MachinesViewState extends ConsumerState<MachinesView> {
  final _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // Initialize the notifier with teamId
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(operatorMachineProvider.notifier).initialize(widget.teamId);
    });
  }

  @override
  void dispose() {
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    ref.read(operatorMachineProvider.notifier).setSearchQuery(query);
  }

  void _onSearchCleared() {
    ref.read(operatorMachineProvider.notifier).clearSearch();
  }

  void _onDateFilterChanged(DateFilterType filterType) {
    // Convert from DateFilterType to DateFilter
    final backendFilter = _convertToBackendFilter(filterType);
    ref.read(operatorMachineProvider.notifier).setDateFilter(backendFilter);
  }

  void _onCustomDateRangeSelected(DateTime? start, DateTime? end) {
    ref.read(operatorMachineProvider.notifier).setCustomDateRange(start, end);
  }

  // Helper function to convert from widget enum to backend enum
  DateFilter _convertToBackendFilter(DateFilterType filterType) {
    switch (filterType) {
      case DateFilterType.none:
        return DateFilter.none;
      case DateFilterType.today:
        return DateFilter.today;
      case DateFilterType.last3Days:
        return DateFilter.last3Days;
      case DateFilterType.last7Days:
        return DateFilter.last7Days;
      case DateFilterType.last30Days:
        return DateFilter.last30Days;
      case DateFilterType.custom:
        return DateFilter.custom;
    }
  }

  // Helper function to convert from backend enum to widget enum
  DateFilterType _convertToWidgetFilter(DateFilter filter) {
    switch (filter) {
      case DateFilter.none:
        return DateFilterType.none;
      case DateFilter.today:
        return DateFilterType.today;
      case DateFilter.last3Days:
        return DateFilterType.last3Days;
      case DateFilter.last7Days:
        return DateFilterType.last7Days;
      case DateFilter.last30Days:
        return DateFilterType.last30Days;
      case DateFilter.custom:
        return DateFilterType.custom;
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(operatorMachineProvider);

    // Show error if any
    if (state.errorMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(state.errorMessage!),
            action: SnackBarAction(
              label: 'Dismiss',
              onPressed: () {
                ref.read(operatorMachineProvider.notifier).clearError();
              },
            ),
          ),
        );
        ref.read(operatorMachineProvider.notifier).clearError();
      });
    }

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 202, 231, 255),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final screenWidth = constraints.maxWidth;
          final isDesktop = screenWidth > 1200;
          final isTablet = screenWidth > 768 && screenWidth <= 1200;
          final isMobile = screenWidth <= 768;

          if (state.isLoading && state.machines.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(isDesktop ? 8.0 : (isTablet ? 6.0 : 4.0)),
              child: Container(
                // Blue outlined box wrapping everything - Made lighter
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height * 0.9, // Increased by 10%
                ),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 202, 231, 255),
                  borderRadius: BorderRadius.circular(isDesktop ? 12 : (isTablet ? 10 : 8)),
                  border: Border.all(
                    color: Colors.blue.shade200, // Lighter blue
                    width: 1.5, // Slightly thinner
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.shade50, // Much lighter shadow
                      blurRadius: 6,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Stats Cards - Always in same row
                    _buildStatsSection(state, isDesktop, isTablet, isMobile, screenWidth),

                    // Inner box wrapping machine list section
                    Container(
                        margin: EdgeInsets.only(
                          left: isDesktop ? 24.0 : (isTablet ? 16.0 : 12.0),
                          right: isDesktop ? 24.0 : (isTablet ? 16.0 : 12.0),
                          bottom: isDesktop ? 24.0 : (isTablet ? 16.0 : 12.0),
                        ),
                        decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(isDesktop ? 10 : (isTablet ? 8 : 6)),
                        border: Border.all(
                          color: Colors.grey.shade200,
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.shade100,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // Machine List Header with Search & Date Filter
                          _buildListHeader(state, isDesktop, isTablet, isMobile),
                          
                          // Machine list content - Increased height by 10%
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.61, // Changed from 0.5 to 0.6 (+10%)
                            child: state.displayedMachines.isEmpty
                                ? _buildEmptyState(isMobile, state)
                                : (isMobile
                                    ? MachineMobileCardWidget(
                                        machines: state.displayedMachines,
                                        onMachineAction: _handleMachineAction,
                                      )
                                    : MachineTableWidget(
                                        machines: state.displayedMachines,
                                        onMachineAction: _handleMachineAction,
                                      )),
                          ),
                          
                          // Pagination - Always show if there are any machines
                          if (state.filteredMachines.isNotEmpty)
                            Container(
                              padding: EdgeInsets.all(isDesktop ? 8.0 : (isTablet ?6.0 : 4.0)),
                              decoration: BoxDecoration(
                                border: Border(
                                  top: BorderSide(
                                    color: Colors.grey.shade200,
                                    width: 1,
                                  ),
                                ),
                              ),
                              child: PaginationWidget(
                                currentPage: state.currentPage,
                                totalPages: state.totalPages,
                                itemsPerPage: state.itemsPerPage,
                                isDesktop: isDesktop,
                                canGoNext: state.currentPage < state.totalPages,
                                canGoPrevious: state.currentPage > 1,
                                onNext: () => ref
                                    .read(operatorMachineProvider.notifier)
                                    .goToNextPage(),
                                onPrevious: () => ref
                                    .read(operatorMachineProvider.notifier)
                                    .goToPreviousPage(),
                                onPageChanged: (page) => ref
                                    .read(operatorMachineProvider.notifier)
                                    .goToPage(page),
                                onItemsPerPageChanged: (value) => ref
                                    .read(operatorMachineProvider.notifier)
                                    .setItemsPerPage(value),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatsSection(
    OperatorMachineState state,
    bool isDesktop,
    bool isTablet,
    bool isMobile,
    double screenWidth,
  ) {
    return Padding(
      padding: EdgeInsets.all(isDesktop ? 16.0 : (isTablet ? 12.0 : 8.0)),
      child: _buildStatsCards(state, isDesktop, isTablet, isMobile, screenWidth),
    );
  }

  Widget _buildStatsCards(
    OperatorMachineState state,
    bool isDesktop,
    bool isTablet,
    bool isMobile,
    double screenWidth,
  ) {
    final stats = [
      StatCardData(
        label: 'Active Machines',
        count: state.activeMachinesCount.toString(),
        change: '+0',
        subtext: 'currently active',
        color: const Color(0xFF10B981),
        lightColor: const Color(0xFFD1FAE5),
        icon: Icons.check_circle_outline,
      ),
      StatCardData(
        label: 'Archived Machines',
        count: state.archivedMachinesCount.toString(),
        change: '+0',
        subtext: 'archived machines',
        color: const Color(0xFFF59E0B),
        lightColor: const Color(0xFFFEF3C7),
        icon: Icons.archive_outlined,
      ),
      StatCardData(
        label: 'Total Machines',
        count: state.machines.length.toString().padLeft(2, '0'),
        change: '+0',
        subtext: 'all machines',
        color: const Color(0xFF3B82F6),
        lightColor: const Color(0xFFDBEAFE),
        icon: Icons.precision_manufacturing_outlined,
      ),
      StatCardData(
        label: 'Filtered Results',
        count: state.filteredMachines.length.toString().padLeft(2, '0'),
        change: '+0',
        subtext: 'matching search',
        color: const Color(0xFF8B5CF6),
        lightColor: const Color(0xFFEDE9FE),
        icon: Icons.filter_alt_outlined,
      ),
    ];

    // Always keep stat cards in the same row with responsive spacing
    final cardSpacing = isDesktop ? 16.0 : (isTablet ? 12.0 : 8.0);

    return Row(
      children: stats
          .asMap()
          .entries
          .expand((entry) => [
                Expanded(
                  child: StatCardWidget(data: entry.value),
                ),
                if (entry.key < stats.length - 1)
                  SizedBox(width: cardSpacing),
              ])
          .toList(),
    );
  }

  Widget _buildListHeader(OperatorMachineState state, bool isDesktop, bool isTablet, bool isMobile) {
    final headerPadding = isDesktop ? 12.0 : (isTablet ? 10.0 : 8.0);
    final titleFontSize = isDesktop ? 24.0 : (isTablet ? 22.0 : 20.0);

    return Padding(
      padding: EdgeInsets.all(headerPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title and search bar in the same row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Title
              Expanded(
                child: Text(
                  'Machine List',
                  style: TextStyle(
                    fontSize: titleFontSize,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1F2937),
                    letterSpacing: -0.5,
                  ),
                ),
              ),
              
              // Search bar with date filter (desktop/tablet)
              if (isDesktop || isTablet)
                Row(
                  children: [
                    DateFilterWidget(
                      selectedFilter: _convertToWidgetFilter(state.dateFilter),
                      customStartDate: state.customStartDate,
                      customEndDate: state.customEndDate,
                      onFilterChanged: _onDateFilterChanged,
                      onCustomRangeSelected: _onCustomDateRangeSelected,
                      isDesktop: isDesktop,
                      isTablet: isTablet,
                      isMobile: isMobile,
                    ),
                    const SizedBox(width: 12),
                    SizedBox(
                      width: isDesktop ? 300 : 250,
                      child: SearchBarWidget(
                        onSearchChanged: _onSearchChanged,
                        onClear: _onSearchCleared,
                        focusNode: _searchFocusNode,
                      ),
                    ),
                  ],
                )
              else
                // Mobile layout
                Expanded(
                  child: Row(
                    children: [
                      DateFilterWidget(
                        selectedFilter: _convertToWidgetFilter(state.dateFilter),
                        customStartDate: state.customStartDate,
                        customEndDate: state.customEndDate,
                        onFilterChanged: _onDateFilterChanged,
                        onCustomRangeSelected: _onCustomDateRangeSelected,
                        isDesktop: isDesktop,
                        isTablet: isTablet,
                        isMobile: isMobile,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: SearchBarWidget(
                          onSearchChanged: _onSearchChanged,
                          onClear: _onSearchCleared,
                          focusNode: _searchFocusNode,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isMobile, OperatorMachineState state) {
    final hasSearch = state.searchQuery.isNotEmpty;
    final hasDateFilter = state.dateFilter != DateFilter.none;
    final iconSize = isMobile ? 56.0 : 64.0;
    final titleSize = isMobile ? 15.0 : 16.0;
    final subtextSize = isMobile ? 13.0 : 14.0;

    // Determine the reason for empty state
    String title = 'No machines found';
    String subtext = 'Try adjusting your filters or search query';
    
    if (!hasSearch && !hasDateFilter && state.machines.isEmpty) {
      title = 'No machines yet';
      subtext = 'Add your first machine to get started';
    } else if (hasSearch && !hasDateFilter) {
      title = 'No machines found';
      subtext = 'Try adjusting your search query';
    } else if (!hasSearch && hasDateFilter) {
      title = 'No machines in selected date range';
      subtext = 'Try a different date range';
    } else if (hasSearch && hasDateFilter) {
      title = 'No machines match your criteria';
      subtext = 'Try adjusting your search or date filter';
    }

    return Center(
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 24.0 : 32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              hasSearch || hasDateFilter ? Icons.search_off : Icons.precision_manufacturing_outlined,
              size: iconSize,
              color: const Color(0xFF9CA3AF),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: titleSize,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF6B7280),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtext,
              style: TextStyle(
                fontSize: subtextSize,
                color: const Color(0xFF9CA3AF),
              ),
              textAlign: TextAlign.center,
            ),
            if (hasSearch || hasDateFilter) ...[
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () {
                  if (hasSearch) {
                    _onSearchCleared();
                  }
                  // Clear date filter
                  _onDateFilterChanged(DateFilterType.none);
                },
                icon: Icon(Icons.clear, size: isMobile ? 16 : 18),
                label: Text(
                  'Clear Filters',
                  style: TextStyle(fontSize: subtextSize),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _handleMachineAction(String machineId) {
    final state = ref.read(operatorMachineProvider);
    final machine = state.machines.firstWhere(
      (m) => m.machineId == machineId,
      orElse: () => throw Exception('Machine not found'),
    );

    showDialog(
      context: context,
      builder: (context) => MachineViewDialog(
        machine: machine,
      ),
    );
  }
}