// lib/ui/home/web_admin_home_view.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/activity_log_item.dart';
import '../../../data/providers/activity_providers.dart';
import '../view_model/admin_home_provider.dart';
import '../../core/widgets/sample_cards/base_stats_card.dart';
import '../web_widgets/activity_chart.dart';
import '../web_widgets/report_donut_chart.dart';
import '../web_widgets/recent_activities_table.dart';
import '../../core/widgets/containers/web_base_container.dart';
import '../../core/skeleton/activity_chart_skeleton.dart';
import '../../core/skeleton/report_donut_chart_skeleton.dart';

class WebAdminHomeView extends ConsumerStatefulWidget {
  const WebAdminHomeView({super.key});

  @override
  ConsumerState<WebAdminHomeView> createState() => _WebAdminHomeViewState();
}

class _WebAdminHomeViewState extends ConsumerState<WebAdminHomeView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _skeletonController;
  late final Animation<double> _skeletonPulse;

  @override
  void initState() {
    super.initState();
    _skeletonController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _skeletonPulse = CurvedAnimation(
      parent: _skeletonController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _skeletonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final asyncState = ref.watch(adminHomeProvider);
    final activitiesAsync = ref.watch(userTeamActivitiesProvider);

    return WebScaffoldContainer(
      child: WebContentContainer(
        innerPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
        child: asyncState.when(
          loading: () => _buildDashboard(null, activitiesAsync, pulse: _skeletonPulse),
          error: (err, _) => WebErrorState(
            message: err.toString(),
            onRetry: () => ref.read(adminHomeProvider.notifier).refresh(),
          ),
          data: (state) => _buildDashboard(state, activitiesAsync),
        ),
      ),
    );
  }

  Widget _buildDashboard(
    AdminHomeState? state,
    AsyncValue<List<ActivityLogItem>> activitiesAsync, {
    Animation<double>? pulse,
  }) {
    final isLoading = state == null;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isLargeScreen = constraints.maxWidth > 1200;
        final isMediumScreen = constraints.maxWidth > 800;
        final topSectionHeight =
            isLargeScreen ? 400.0 : (isMediumScreen ? 360.0 : 320.0);

        return Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: topSectionHeight,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ── Left column
                    Expanded(
                      flex: 3,
                      child: Column(
                        children: [
                          // ── Stat cards — isLoading drives built-in skeleton
                          SizedBox(
                            height: 160,
                            child: Row(
                              children: [
                                Expanded(
                                  child: BaseStatsCard(
                                    title: 'Total Operators',
                                    value: state?.totalOperators ?? 0,
                                    icon: Icons.person_outline,
                                    iconColor: const Color(0xFF22C55E),
                                    backgroundColor: const Color(0xFF22C55E).withValues(alpha: 0.1),
                                    changeText: isLoading ? null : '${state.operatorGrowthRate.abs().toStringAsFixed(0)}%',
                                    subtext: 'compared this month',
                                    isPositive: state?.operatorGrowthRate != null ? state!.operatorGrowthRate >= 0 : null,
                                    isLoading: isLoading,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: BaseStatsCard(
                                    title: 'Total Machines',
                                    value: state?.totalMachines ?? 0,
                                    icon: Icons.settings_outlined,
                                    iconColor: const Color(0xFF3B82F6),
                                    backgroundColor: const Color(0xFF3B82F6).withValues(alpha: 0.1),
                                    changeText: isLoading ? null : '${state.machineGrowthRate.abs().toStringAsFixed(0)}%',
                                    subtext: 'compared this month',
                                    isPositive: state?.machineGrowthRate != null ? state!.machineGrowthRate >= 0 : null,
                                    isLoading: isLoading,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: BaseStatsCard(
                                    title: 'Total Reports',
                                    value: state?.totalReports ?? 0,
                                    icon: Icons.description_outlined,
                                    iconColor: const Color(0xFFF59E0B),
                                    backgroundColor: const Color(0xFFF59E0B).withValues(alpha: 0.1),
                                    changeText: isLoading ? null : '${state.reportGrowthRate.abs().toStringAsFixed(0)}%',
                                    subtext: 'compared this month',
                                    isPositive: state?.reportGrowthRate != null ? state!.reportGrowthRate >= 0 : null,
                                    isLoading: isLoading,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),

                          // ── Activity chart
                          Expanded(
                            child: activitiesAsync.when(
                              data: (activities) => ActivityChart(
                                activities: _groupActivitiesByDay(activities),
                              ),
                              loading: () => ActivityChartSkeleton(pulse: pulse ?? _skeletonPulse),
                              error: (err, _) =>
                                  Center(child: Text('Error: $err')),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),

                    // ── Right column: donut chart
                    Expanded(
                      flex: 1,
                      child: isLoading
                          ? ReportDonutChartSkeleton(pulse: pulse ?? _skeletonPulse)
                          : ReportDonutChart(reportStatus: state.reportStatus),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              // ── Recent activities (handles its own skeleton internally)
              Expanded(child: RecentActivitiesTable(pulse: _skeletonPulse)),
            ],
          ),
        );
      },
    );
  }

  List<Map<String, dynamic>> _groupActivitiesByDay(
    List<ActivityLogItem> activities,
  ) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final result = <Map<String, dynamic>>[];

    for (int i = 6; i >= 0; i--) {
      final date = today.subtract(Duration(days: i));
      final dayName = _getDayName(date.weekday);
      int count = 0;
      for (var activity in activities) {
        final aDate = activity.timestamp;
        if (aDate.year == date.year &&
            aDate.month == date.month &&
            aDate.day == date.day) {
          count++;
        }
      }
      result.add({'day': dayName, 'count': count});
    }

    return result;
  }

  String _getDayName(int weekday) {
    switch (weekday) {
      case DateTime.monday: return 'Mon';
      case DateTime.tuesday: return 'Tue';
      case DateTime.wednesday: return 'Wed';
      case DateTime.thursday: return 'Thu';
      case DateTime.friday: return 'Fri';
      case DateTime.saturday: return 'Sat';
      case DateTime.sunday: return 'Sun';
      default: return '';
    }
  }
}