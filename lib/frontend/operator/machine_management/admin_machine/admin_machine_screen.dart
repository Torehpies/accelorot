// lib/frontend/operator/machine_management/admin_machine/admin_machine_screen.dart

import 'package:flutter/material.dart';
import 'controllers/admin_machine_controller.dart';
import '../components/machine_action_card.dart';
import 'widgets/add_machine_modal.dart';
import '../widgets/report_search.dart';
import 'widgets/admin_machine_list.dart';
import '../admin_machine/reports/controllers/reports_controller.dart';
import '../admin_machine/reports/widgets/report_card.dart';
import '../admin_machine/reports/widgets/edit_report_modal.dart';
import '../admin_machine/reports/widgets/reports_search_bar.dart';
import '../../../../ui/activity_logs/widgets/filter_section.dart';
import '../admin_machine/reports/models/report_model.dart';

class AdminMachineScreen extends StatefulWidget {
  final String? viewingOperatorId;

  const AdminMachineScreen({super.key, this.viewingOperatorId});

  @override
  State<AdminMachineScreen> createState() => _AdminMachineScreenState();
}

class _AdminMachineScreenState extends State<AdminMachineScreen> {
  late final AdminMachineController _machineController;
  late final ReportsController _reportsController;
  final FocusNode _searchFocusNode = FocusNode();
  final TextEditingController _searchController = TextEditingController();
  final GlobalKey _filterKey = GlobalKey();

  // Track which view to show
  bool _showReportsView = false;

  @override
  void initState() {
    super.initState();
    _machineController = AdminMachineController();
    _machineController.initialize();
    _reportsController = ReportsController();
    _reportsController.initialize();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _machineController.dispose();
    _reportsController.dispose();
    super.dispose();
  }

  void _showAddMachineModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => AddMachineModal(controller: _machineController),
    );
  }

  void _showEditReportModal(ReportModel report) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) =>
          EditReportModal(controller: _reportsController, report: report),
    );
  }

  void _toggleReportsView() {
    setState(() {
      _searchController.clear();
      _searchFocusNode.unfocus();

      _machineController.clearSearch();
      _reportsController.clearSearch();

      _showReportsView = !_showReportsView;
    });
  }

  Future<void> _handleRefresh() async {
    if (_showReportsView) {
      await _reportsController.refresh();
    } else {
      await _machineController.refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _searchFocusNode.unfocus();
      },
      child: AnimatedBuilder(
        animation: Listenable.merge([_machineController, _reportsController]),
        builder: (context, _) {
          return Scaffold(
            backgroundColor: Colors.grey[50],
            appBar: AppBar(
              leading: (_machineController.showArchived || _showReportsView)
                  ? IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.black),
                      onPressed: () {
                        // Clear search and unfocus
                        _searchController.clear();
                        _searchFocusNode.unfocus();

                        if (_showReportsView) {
                          _reportsController.clearSearch();
                          _toggleReportsView();
                        } else {
                          _machineController.clearSearch();
                          _machineController.setShowArchived(false);
                        }
                      },
                    )
                  : null,
              automaticallyImplyLeading: false,
              title: Text(
                _showReportsView
                    ? 'Reports'
                    : _machineController.showArchived
                    ? 'Archived Machines'
                    : 'Machine Management',
                style: const TextStyle(
                  color: Colors.black,
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
                  // Action Cards Row - Only show when not in reports view
                  if (!_showReportsView)
                    Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: MachineActionCard(
                                icon: Icons.archive,
                                label: 'Archive',
                                onPressed: () {
                                  _searchController.clear();
                                  _searchFocusNode.unfocus();
                                  _machineController.clearSearch();
                                  _machineController.setShowArchived(true);
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: MachineActionCard(
                                icon: Icons.report,
                                label: 'Reports',
                                onPressed: _toggleReportsView,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: MachineActionCard(
                                icon: Icons.add_circle_outline,
                                label: 'Add Machine',
                                onPressed: _showAddMachineModal,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),

                  // Main Container
                  Expanded(
                    child: _showReportsView
                        ? _buildReportsView()
                        : _buildMachineView(),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // Machine Management View
  Widget _buildMachineView() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[300]!, width: 1.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SearchBarWidget(
              controller: _searchController,
              onSearchChanged: _machineController.setSearchQuery,
              onClear: _machineController.clearSearch,
              focusNode: _searchFocusNode,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Text(
                  _machineController.showArchived
                      ? 'Archived Machines'
                      : 'List of Machines',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Expanded(child: _buildMachineContent()),
        ],
      ),
    );
  }

  // Reports View
  Widget _buildReportsView() {
    return Column(
      children: [
        // Search Bar with Sort
        ReportsSearchBar(
          controller: _reportsController.searchController,
          onSearchChanged: _reportsController.setSearchQuery,
          onClear: _reportsController.clearSearch,
          focusNode: _searchFocusNode,
          reportsController: _reportsController,
        ),
        const SizedBox(height: 12),

        // Main Container
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
              border: Border.all(color: Colors.grey[300]!, width: 1.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                // Filter Chips
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: FilterSection(
                    key: _filterKey,
                    filters: const ['All', 'Open', 'In Progress', 'Closed'],
                    onSelected: _reportsController.setFilter,
                    initialFilter: 'All',
                    autoHighlightedFilters:
                        _reportsController.autoHighlightedFilters,
                  ),
                ),
                Expanded(child: _buildReportsContent()),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMachineContent() {
    if (_machineController.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_machineController.errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
              const SizedBox(height: 16),
              Text(
                _machineController.errorMessage!,
                style: TextStyle(color: Colors.red.shade700, fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  _machineController.clearError();
                  _machineController.initialize();
                },
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return AdminMachineList(controller: _machineController);
  }

  Widget _buildReportsContent() {
    if (_reportsController.isLoading) {
      return const Center(child: CircularProgressIndicator(color: Colors.teal));
    }

    if (_reportsController.errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
              const SizedBox(height: 16),
              Text(
                _reportsController.errorMessage!,
                style: TextStyle(color: Colors.red.shade700, fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  _reportsController.clearError();
                  _reportsController.initialize();
                },
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_reportsController.filteredReports.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.report_outlined,
                size: 64,
                color: Colors.grey.shade300,
              ),
              const SizedBox(height: 16),
              Text(
                _reportsController.searchQuery.isNotEmpty
                    ? 'No reports found matching "${_reportsController.searchQuery}"'
                    : 'No reports found',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _reportsController.displayedReports.length,
            itemBuilder: (context, index) {
              final report = _reportsController.displayedReports[index];
              return ReportCard(
                report: report,
                onTap: () => _showEditReportModal(report),
              );
            },
          ),
        ),
        if (_reportsController.hasMoreToLoad)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: ElevatedButton.icon(
              onPressed: _reportsController.loadMore,
              icon: const Icon(Icons.expand_more),
              label: Text(
                'Load More (${_reportsController.remainingCount} remaining)',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
