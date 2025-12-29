import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../view_model/reports_notifier.dart';
import '../../../services/sess_service.dart';
import 'search_bar.dart';
import 'filter_dropdown.dart';
import 'sort_dropdown.dart';
import 'report_card.dart';
import 'edit_report_modal.dart';

class ReportsView extends ConsumerStatefulWidget {
  const ReportsView({super.key});

  @override
  ConsumerState<ReportsView> createState() => _ReportsViewState();
}

class _ReportsViewState extends ConsumerState<ReportsView> {
  final _searchController = TextEditingController();
  final _searchFocusNode = FocusNode();
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _initialize());
  }

  Future<void> _initialize() async {
    if (_isInitialized) return;
    
    final sessionService = SessionService();
    final userData = await sessionService.getCurrentUserData();
    final teamId = userData?['teamId'] as String?;

    if (teamId != null) {
      await ref.read(reportsProvider.notifier).initialize(teamId);
      _isInitialized = true;
    }
  }

  Future<void> _handleRefresh() async {
    final sessionService = SessionService();
    final userData = await sessionService.getCurrentUserData();
    final teamId = userData?['teamId'] as String?;

    if (teamId != null) {
      await ref.read(reportsProvider.notifier).refresh(teamId);
    }
  }

  void _showEditReportModal(BuildContext context, report) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => EditReportModal(report: report),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(reportsProvider);
    final notifier = ref.read(reportsProvider.notifier);

    return GestureDetector(
      onTap: () => _searchFocusNode.unfocus(),
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: const Text(
            'Reports',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: Colors.teal,
          elevation: 0,
          centerTitle: false,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white),
              onPressed: _handleRefresh,
              tooltip: 'Refresh',
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Main Container
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.grey[200]!, width: 0.5),
                  ),
                  child: Column(
                    children: [
                      // Search Bar and Sort Dropdown Row
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Expanded(
                              child: ReportsSearchBar(
                                controller: _searchController,
                                focusNode: _searchFocusNode,
                                onSearchChanged: notifier.setSearchQuery,
                                onClear: notifier.clearSearch,
                              ),
                            ),
                            const SizedBox(width: 12),
                            SortDropdown(
                              sortOption: state.sortOption,
                              onChanged: notifier.setSortOption,
                            ),
                          ],
                        ),
                      ),

                      // Filter Chips
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        child: FilterDropdown(
                          selectedFilter: state.selectedFilter,
                          onFilterChanged: notifier.setFilter,
                          autoHighlightedFilters: state.autoHighlightedFilters,
                        ),
                      ),

                      // Divider
                      Divider(height: 1, color: Colors.grey[200]),

                      // Reports List
                      Expanded(
                        child: _buildReportsList(state),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReportsList(ReportsState state) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
              const SizedBox(height: 16),
              Text(
                state.errorMessage!,
                style: TextStyle(color: Colors.red.shade700),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _handleRefresh,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (state.displayedReports.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                state.searchQuery.isNotEmpty
                    ? Icons.search_off
                    : Icons.report_off,
                size: 64,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                state.searchQuery.isNotEmpty
                    ? 'No reports match your search'
                    : 'No reports available',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      itemCount: state.displayedReports.length + (state.hasMoreToLoad ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == state.displayedReports.length) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: ElevatedButton.icon(
                onPressed: () => ref.read(reportsProvider.notifier).loadMore(),
                icon: const Icon(Icons.expand_more, size: 18),
                label: Text(
                  'Load More (${state.remainingCount} remaining)',
                  style: const TextStyle(fontSize: 14),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ),
          );
        }

        final report = state.displayedReports[index];
        return ReportCard(
          report: report,
          onTap: () => _showEditReportModal(context, report),
        );
      },
    );
  }
}