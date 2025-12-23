import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../ui/machine_management/view_model/operator_machine_notifier.dart';
import '../widgets/stat_card.dart';
import '../widgets/machine_table.dart';
import '../widgets/machine_mobile_card.dart';
import '../widgets/pagination.dart';
import '../widgets/search_bar.dart';
import '../widgets/date_filter.dart'; // Import the widget
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
  DateFilterType _selectedDateFilter = DateFilterType.none;
  DateTime? _customStartDate;
  DateTime? _customEndDate;

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
    setState(() {
      _selectedDateFilter = filterType;
      if (filterType != DateFilterType.custom) {
        _customStartDate = null;
        _customEndDate = null;
      }
    });
    // TODO: Apply date filter to machine data
    print('Date filter changed to: $filterType');
  }

  void _onCustomDateRangeSelected(DateTime? start, DateTime? end) {
    setState(() {
      _customStartDate = start;
      _customEndDate = end;
      if (start != null && end != null) {
        _selectedDateFilter = DateFilterType.custom;
      }
    });
    // TODO: Apply custom date range filter
    print('Custom date range selected: $start to $end');
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
      backgroundColor: const Color(0xFFF5F7FA),
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
            child: Column(
              children: [
                // Stats Cards - Always in same row
                _buildStatsSection(state, isDesktop, isTablet, isMobile, screenWidth),

                // Machine List Card
                _buildMachineListCard(
                  state,
                  isDesktop,
                  isTablet,
                  isMobile,
                  screenWidth,
                ),
              ],
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
      padding: EdgeInsets.all(isDesktop ? 32.0 : (isTablet ? 24.0 : 16.0)),
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

  Widget _buildMachineListCard(
    OperatorMachineState state,
    bool isDesktop,
    bool isTablet,
    bool isMobile,
    double screenWidth,
  ) {
    final horizontalPadding = isDesktop ? 32.0 : (isTablet ? 24.0 : 16.0);
    final bottomPadding = isDesktop ? 32.0 : (isTablet ? 24.0 : 16.0);

    return Padding(
      padding: EdgeInsets.fromLTRB(
        horizontalPadding,
        0,
        horizontalPadding,
        bottomPadding,
      ),
      child: Container(
        constraints: BoxConstraints(
          minHeight: MediaQuery.of(context).size.height * 0.5,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(isDesktop ? 16 : (isTablet ? 14 : 12)),
          border: Border.all(color: const Color(0xFFE5E7EB)),
          boxShadow: [
            BoxShadow(
              color: const Color(0x0A000000),
              blurRadius: isDesktop ? 12 : 8,
              offset: Offset(0, isDesktop ? 4 : 2),
            ),
          ],
        ),
        child: Column(
          children: [
            _buildListHeader(isDesktop, isTablet, isMobile),
            
            // Machine list content
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.5,
              child: state.displayedMachines.isEmpty
                  ? _buildEmptyState(isMobile)
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
              PaginationWidget(
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
          ],
        ),
      ),
    );
  }

  Widget _buildListHeader(bool isDesktop, bool isTablet, bool isMobile) {
    final headerPadding = isDesktop ? 24.0 : (isTablet ? 20.0 : 16.0);
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
                      selectedFilter: _selectedDateFilter,
                      customStartDate: _customStartDate,
                      customEndDate: _customEndDate,
                      onFilterChanged: _onDateFilterChanged,
                      onCustomRangeSelected: _onCustomDateRangeSelected,
                      isDesktop: isDesktop,
                      isTablet: isTablet,
                      isMobile: isMobile,
                    ),
                    const SizedBox(width: 12),
                    SizedBox(
                      width: isDesktop ? 400 : 350,
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
                        selectedFilter: _selectedDateFilter,
                        customStartDate: _customStartDate,
                        customEndDate: _customEndDate,
                        onFilterChanged: _onDateFilterChanged,
                        onCustomRangeSelected: _onCustomDateRangeSelected,
                        isDesktop: isDesktop,
                        isTablet: isTablet,
                        isMobile: isMobile,
                      ),
                      const SizedBox(width: 8),
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

  Widget _buildEmptyState(bool isMobile) {
    final state = ref.watch(operatorMachineProvider);
    final hasSearch = state.searchQuery.isNotEmpty;
    final iconSize = isMobile ? 56.0 : 64.0;
    final titleSize = isMobile ? 15.0 : 16.0;
    final subtextSize = isMobile ? 13.0 : 14.0;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 24.0 : 32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              hasSearch ? Icons.search_off : Icons.precision_manufacturing_outlined,
              size: iconSize,
              color: const Color(0xFF9CA3AF),
            ),
            const SizedBox(height: 16),
            Text(
              hasSearch ? 'No machines found' : 'No machines yet',
              style: TextStyle(
                fontSize: titleSize,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF6B7280),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              hasSearch
                  ? 'Try adjusting your search query'
                  : 'Add your first machine to get started',
              style: TextStyle(
                fontSize: subtextSize,
                color: const Color(0xFF9CA3AF),
              ),
              textAlign: TextAlign.center,
            ),
            if (hasSearch) ...[
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: _onSearchCleared,
                icon: Icon(Icons.clear, size: isMobile ? 16 : 18),
                label: Text(
                  'Clear Search',
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