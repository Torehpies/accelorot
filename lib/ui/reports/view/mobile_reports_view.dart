import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_application_1/ui/core/widgets/shared/mobile_header.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../view_model/reports_viewmodel.dart';
//import '../models/reports_state.dart';
import '../widgets/mobile_report_card.dart';
import '../widgets/edit_report_modal.dart';
//import '../widgets/reports_stats_row.dart';
import '../../core/themes/web_colors.dart';
import '../../core/widgets/base_stats_card.dart';
import '../../core/widgets/filters/search_field.dart';
import '../../core/widgets/filters/date_filter_dropdown.dart';
//import '../../core/widgets/shared/pagination_controls.dart';

class MobileReportsView extends ConsumerStatefulWidget {
  const MobileReportsView({super.key});

  @override
  ConsumerState<MobileReportsView> createState() => _MobileReportsViewState();
}

class _MobileReportsViewState extends ConsumerState<MobileReportsView> {
  final PageController _statsController = PageController(viewportFraction: 0.9);

  @override
  void dispose() {
    _statsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reportsState = ref.watch(reportsViewModelProvider);
    final viewModel = ref.read(reportsViewModelProvider.notifier);

    final stats = viewModel.getStatsWithChange();
    final statCards = _buildStatCards(stats, reportsState.isLoading);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: kIsWeb
          ? null 
          : MobileHeader(title: 'Reports'),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),

            SizedBox(
              height: 160,
              child: PageView.builder(
                controller: _statsController,
                padEnds: false,
                itemCount: statCards.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: statCards[index],
                  );
                },
              ),
            ),

            const SizedBox(height: 24),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: .05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Report List',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        // Date Filter Button
                        SizedBox(
                          width: 42,
                          height: 42,
                          child: DateFilterDropdown(
                            onFilterChanged: (filter) => 
                              viewModel.onDateFilterChanged(filter),
                            isLoading: reportsState.isLoading, 
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Search Bar
                        Expanded(
                          child: SearchField(
                            hintText: 'Search...',
                            width: double.infinity,
                            isLoading: reportsState.isLoading,
                            onChanged: (val) => viewModel.onSearchChanged(val),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),
                    const Divider(height: 1),

                    // 5. Report List
                    if (reportsState.isLoading &&
                        reportsState.allReports.isEmpty)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(32.0),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    else if (reportsState.paginatedReports.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: Column(
                            children: [
                              const Icon(
                                Icons.inbox,
                                size: 48,
                                color: Colors.grey,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'No reports found',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: EdgeInsets.zero,
                        itemCount: reportsState.paginatedReports.length,
                        itemBuilder: (context, index) {
                          final report = reportsState.paginatedReports[index];
                          return MobileReportCard(
                            report: report,
                            onTap: () {
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                backgroundColor: Colors.transparent,
                                builder: (context) =>
                                    EditReportModal(report: report),
                              );
                            },
                          );
                        },
                      ),

                    const SizedBox(height: 16),

                    // 6. Pagination Controls (Mobile Optimized)
                    if (!reportsState.isLoading &&
                        reportsState.filteredReports.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Back Button
                            TextButton.icon(
                              onPressed: reportsState.currentPage > 1
                                  ? () => viewModel.onPageChanged(
                                      reportsState.currentPage - 1,
                                    )
                                  : null,
                              icon: const Icon(Icons.chevron_left, size: 20),
                              label: const Text('Back'),
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.black54,
                                disabledForegroundColor: Colors.black26,
                              ),
                            ),

                            // Page Info
                            Text(
                              'Page ${reportsState.currentPage} of ${reportsState.totalPages}',
                              style: const TextStyle(
                                color: Colors.black87,
                                fontWeight: FontWeight.w500,
                              ),
                            ),

                            // Next Button
                            TextButton.icon(
                              onPressed:
                                  reportsState.currentPage <
                                      reportsState.totalPages
                                  ? () => viewModel.onPageChanged(
                                      reportsState.currentPage + 1,
                                    )
                                  : null,
                              // Swap icon and label for Next button naturally?
                              // TextButton.icon puts icon left. Let's use Directionality or Row if needed.
                              // For simplicity, standard TextButton.icon is fine, or manual Row.
                              // Let's align icon to right for "Next >" feel.
                              label: const Text('Next'),
                              icon: const Icon(Icons.chevron_right, size: 20),
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.black54,
                                disabledForegroundColor: Colors.black26,
                              ), // Icon will be on left by default, which is ok, or we flip it.
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildStatCards(
    Map<String, Map<String, dynamic>> stats,
    bool isLoading,
  ) {
    return [
      BaseStatsCard(
        title: 'Completed Reports',
        value: stats['completed']?['count'] ?? 0,
        icon: Icons.check_circle_outline,
        iconColor: WebColors.success,
        backgroundColor: const Color(0xFFD1FAE5),
        changeText: stats['completed']?['change'],
        subtext: 'completed reports this month',
        isPositive: stats['completed']?['isPositive'],
        isLoading: isLoading,
      ),
      BaseStatsCard(
        title: 'Open Reports',
        value: stats['open']?['count'] ?? 0,
        icon: Icons.folder_open,
        iconColor: WebColors.info,
        backgroundColor: const Color(0xFFDBEAFE),
        changeText: stats['open']?['change'],
        subtext: 'opened reports this month',
        isPositive: stats['open']?['isPositive'],
        isLoading: isLoading,
      ),
      BaseStatsCard(
        title: 'In Progress Reports',
        value: stats['inProgress']?['count'] ?? 0,
        icon: Icons.pending_actions,
        iconColor: WebColors.warning,
        backgroundColor: const Color(0xFFFEF3C7),
        changeText: stats['inProgress']?['change'],
        subtext: 'reports started this month',
        isPositive: stats['inProgress']?['isPositive'],
        isLoading: isLoading,
      ),
      BaseStatsCard(
        title: 'On Hold Reports',
        value: stats['onHold']?['count'] ?? 0,
        icon: Icons.pause_circle_outline,
        iconColor: WebColors.error,
        backgroundColor: const Color(0xFFFEE2E2),
        changeText: stats['onHold']?['change'],
        subtext: 'closed reports this month',
        isPositive: stats['onHold']?['isPositive'],
        isLoading: isLoading,
      ),
    ];
  }
}
