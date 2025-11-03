// lib/frontend/operator/machine_management/reports/reports_screen.dart

import 'package:flutter/material.dart';
import 'controllers/reports_controller.dart';
import 'widgets/report_card.dart';
import 'widgets/edit_report_modal.dart';
import 'widgets/reports_search_bar.dart';
import '../../../activity_logs/widgets/filter_section.dart';
import 'models/report_model.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  late final ReportsController _controller;
  final FocusNode _searchFocusNode = FocusNode();
  final GlobalKey _filterKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _controller = ReportsController();
    _controller.initialize();
  }

  @override
  void dispose() {
    _searchFocusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _showEditReportModal(ReportModel report) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => EditReportModal(
        controller: _controller,
        report: report,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _searchFocusNode.unfocus();
      },
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          title: const Text(
            'Reports',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.teal,
          elevation: 0,
          centerTitle: false,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Column(
                children: [
                  // Search Bar with Sort - Outside Container
                  ReportsSearchBar(
                    controller: _controller.searchController,
                    onSearchChanged: _controller.setSearchQuery,
                    onClear: _controller.clearSearch,
                    focusNode: _searchFocusNode,
                    reportsController: _controller,
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
                          // Filter Chips - Inside Container at Top
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                            child: FilterSection(
                              key: _filterKey,
                              filters: const ['All', 'Open', 'In Progress', 'Closed'],
                              onSelected: _controller.setFilter,
                              initialFilter: 'All',
                              autoHighlightedFilters: _controller.autoHighlightedFilters,
                            ),
                          ),
                          
                          // Content
                          Expanded(
                            child: _buildContent(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildContent() {
    // Loading State
    if (_controller.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.teal),
      );
    }

    // Error State
    if (_controller.errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
              const SizedBox(height: 16),
              Text(
                _controller.errorMessage!,
                style: TextStyle(color: Colors.red.shade700, fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  _controller.clearError();
                  _controller.initialize();
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

    // Empty State
    if (_controller.filteredReports.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.report_outlined, size: 64, color: Colors.grey.shade300),
              const SizedBox(height: 16),
              Text(
                _controller.searchQuery.isNotEmpty
                    ? 'No reports found matching "${_controller.searchQuery}"'
                    : 'No reports found',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    // Reports List
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _controller.displayedReports.length,
            itemBuilder: (context, index) {
              final report = _controller.displayedReports[index];
              return ReportCard(
                report: report,
                onTap: () => _showEditReportModal(report),
              );
            },
          ),
        ),
        
        // Load More Button
        if (_controller.hasMoreToLoad)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: ElevatedButton.icon(
              onPressed: _controller.loadMore,
              icon: const Icon(Icons.expand_more),
              label: Text('Load More (${_controller.remainingCount} remaining)'),
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
