// lib/ui/reports/view/mobile_reports_view.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/widgets/mobile_common_widgets.dart';
import '../../core/widgets/mobile_list_header.dart';
import '../../core/widgets/mobile_list_content.dart';
import '../../core/widgets/data_card.dart';
import '../../core/widgets/filters/mobile_dropdown_filter_button.dart';
import '../../core/widgets/filters/mobile_date_filter_button.dart';
import '../../core/themes/app_theme.dart';
import '../../../data/models/report.dart';
import '../view_model/mobile_reports_viewmodel.dart';
import '../models/mobile_reports_state.dart';
import '../models/report_filters.dart';
import '../dialogs/edit_report_modal.dart';

class MobileReportsView extends ConsumerStatefulWidget {
  const MobileReportsView({super.key});

  @override
  ConsumerState<MobileReportsView> createState() => _MobileReportsViewState();
}

class _MobileReportsViewState extends ConsumerState<MobileReportsView> {
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(mobileReportsViewModelProvider.notifier).initialize();
    });
  }

  @override
  void dispose() {
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _showReportDetails(Report report) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => EditReportModal(report: report),
    );
  }

  EmptyStateConfig _getEmptyStateConfig(MobileReportsState state) {
    String message;

    if (state.selectedStatus != ReportStatusFilter.all) {
      message = 'No ${state.selectedStatus.displayName.toLowerCase()} reports';
    } else if (state.selectedCategory != ReportCategoryFilter.all) {
      message = 'No ${state.selectedCategory.displayName.toLowerCase()} reports';
    } else if (state.selectedPriority != ReportPriorityFilter.all) {
      message = 'No ${state.selectedPriority.displayName.toLowerCase()} priority reports';
    } else {
      message = 'No reports available';
    }

    if (state.hasActiveFilters) {
      message = 'No reports match your filters';
    }

    return EmptyStateConfig(
      icon: Icons.inbox_outlined,
      message: message,
      actionLabel: state.hasActiveFilters ? 'Clear All Filters' : null,
      onAction: state.hasActiveFilters
          ? () {
              ref.read(mobileReportsViewModelProvider.notifier).clearAllFilters();
            }
          : null,
    );
  }

  Widget _buildReportCard(BuildContext context, Report report, int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: DataCard<Report>(
        data: report,
        icon: _getReportIcon(report),
        iconBgColor: _getReportIconColor(report),
        title: report.title,
        description: report.description,
        category: report.statusLabel,
        status: 'Created ${_formatDate(report.createdAt)}',
        userName: report.userName,
        statusColor: _getStatusColor(report),
        statusTextColor: const Color(0xFF424242),
        onTap: () => _showReportDetails(report),
      ),
    );
  }

  IconData _getReportIcon(Report report) {
    switch (report.reportType.toLowerCase()) {
      case 'maintenance_issue':
        return Icons.build_circle_outlined;
      case 'safety_concern':
        return Icons.warning_amber_rounded;
      case 'observation':
        return Icons.visibility_outlined;
      default:
        return Icons.description_outlined;
    }
  }

  Color _getReportIconColor(Report report) {
    switch (report.priority.toLowerCase()) {
      case 'high':
        return const Color(0xFFEF4444);
      case 'medium':
        return const Color(0xFFF59E0B);
      case 'low':
        return const Color(0xFF10B981);
      default:
        return AppColors.textSecondary;
    }
  }

  Color _getStatusColor(Report report) {
    switch (report.status.toLowerCase()) {
      case 'completed':
        return const Color(0xFFD1FAE5);
      case 'in_progress':
        return const Color(0xFFFEF3C7);
      case 'open':
        return const Color(0xFFDBEAFE);
      case 'on_hold':
        return const Color(0xFFFEE2E2);
      default:
        return AppColors.grey;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'today';
    } else if (difference.inDays == 1) {
      return 'yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  Widget _buildSkeletonCard(BuildContext context, int index) {
    return Container(
      height: 120,
      margin: const EdgeInsets.only(bottom: 20, left: 16, right: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.backgroundBorder.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.grey,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(height: 16, color: AppColors.grey),
                const SizedBox(height: 8),
                Container(height: 14, width: 150, color: AppColors.grey),
                const Spacer(),
                Container(height: 24, width: 80, color: AppColors.grey),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(mobileReportsViewModelProvider);
    final notifier = ref.read(mobileReportsViewModelProvider.notifier);

    return MobileScaffoldContainer(
      onTap: () => _searchFocusNode.unfocus(),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: MobileListHeader(
          title: 'Reports',
          showAddButton: false,
          searchConfig: SearchBarConfig(
            onSearchChanged: notifier.setSearchQuery,
            searchHint: 'Search reports...',
            isLoading: state.isLoading,
            searchFocusNode: _searchFocusNode,
          ),
          filterWidgets: [
            MobileDropdownFilterButton<ReportStatusFilter>(
              icon: Icons.tune,
              currentFilter: state.selectedStatus,
              options: ReportStatusFilter.values,
              onFilterChanged: notifier.setStatusFilter,
              isLoading: state.isLoading,
            ),
            const SizedBox(width: 8),
            MobileDateFilterButton(
              onFilterChanged: notifier.setDateFilter,
              isLoading: state.isLoading,
            ),
          ],
        ),
        body: Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 8),
            child: MobileListContent<Report>(
              isLoading: state.isLoading,
              isInitialLoad: state.reports.isEmpty,
              hasError: state.hasError,
              errorMessage: state.errorMessage,
              items: state.filteredReports,
              displayedItems: state.displayedReports,
              hasMoreToLoad: state.hasMoreToLoad,
              remainingCount: state.remainingCount,
              emptyStateConfig: _getEmptyStateConfig(state),
              onRefresh: () async {
                await notifier.refresh();
              },
              onLoadMore: notifier.loadMore,
              onRetry: () {
                notifier.clearError();
                notifier.initialize();
              },
              itemBuilder: _buildReportCard,
              skeletonBuilder: _buildSkeletonCard,
            ),
          ),
        ),
      ),
    );
  }
}