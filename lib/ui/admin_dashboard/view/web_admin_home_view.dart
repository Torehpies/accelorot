import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/activity_log_item.dart';
import '../../../data/providers/activity_providers.dart';
import '../view_model/admin_home_provider.dart';
import '../../core/widgets/base_stats_card.dart';
import '../web_widgets/activity_chart.dart';
import '../web_widgets/report_donut_chart.dart';
import '../web_widgets/recent_activities_table.dart';
import '../../core/widgets/web_base_container.dart';

class WebAdminHomeView extends ConsumerStatefulWidget {
  const WebAdminHomeView({super.key});

  @override
  ConsumerState<WebAdminHomeView> createState() => _WebAdminHomeViewState();
}

class _WebAdminHomeViewState extends ConsumerState<WebAdminHomeView> {
  @override
  Widget build(BuildContext context) {
    /// ✅ Watch AsyncValue state
    final asyncState = ref.watch(adminHomeProvider);
    final activitiesAsync = ref.watch(userTeamActivitiesProvider);

    return WebScaffoldContainer(
      child: WebContentContainer(
        innerPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
        child: asyncState.when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: Color(0xFF4CAF50)),
          ),
          error: (err, _) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  'Error: $err',
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () =>
                      ref.read(adminHomeProvider.notifier).refresh(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
          data: (state) => _buildDashboard(state, activitiesAsync),
        ),
      ),
    );
  }

  Widget _buildDashboard(
    AdminHomeState state,
    AsyncValue<List<ActivityLogItem>> activitiesAsync,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Responsive breakpoints
        final isLargeScreen = constraints.maxWidth > 1200;
        final isMediumScreen = constraints.maxWidth > 800;

        // Calculate responsive heights based on available viewport
        final topSectionHeight = isLargeScreen
            ? 400.0
            : (isMediumScreen ? 360.0 : 320.0);

        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Main layout: Left side (Stats + Activity) + Right side (Report Status)
              SizedBox(
                height: topSectionHeight,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Left column: Stats cards + Activity chart
                    Expanded(
                      flex: 3,
                      child: Column(
                        children: [
                          // Three stat cards
                          SizedBox(
                            height: 160,
                            child: Row(
                              children: [
                                Expanded(
                                  child: BaseStatsCard(
                                    title: "Total Operators",
                                    value: state.totalOperators,
                                    icon: Icons.person_outline,
                                    iconColor: const Color(0xFF22C55E),
                                    backgroundColor: const Color(
                                      0xFF22C55E,
                                    ).withValues(alpha: 0.1),
                                    changeText:
                                        '${state.operatorGrowthRate.abs().toStringAsFixed(0)}%',
                                    subtext: 'compared this month',
                                    isPositive: state.operatorGrowthRate >= 0,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: BaseStatsCard(
                                    title: "Total Machines",
                                    value: state.totalMachines,
                                    icon: Icons.settings_outlined,
                                    iconColor: const Color(0xFF3B82F6),
                                    backgroundColor: const Color(
                                      0xFF3B82F6,
                                    ).withValues(alpha: 0.1),
                                    changeText:
                                        '${state.machineGrowthRate.abs().toStringAsFixed(0)}%',
                                    subtext: 'compared this month',
                                    isPositive: state.machineGrowthRate >= 0,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: BaseStatsCard(
                                    title: "Total Reports",
                                    value: state.totalReports,
                                    icon: Icons.description_outlined,
                                    iconColor: const Color(0xFFF59E0B),
                                    backgroundColor: const Color(
                                      0xFFF59E0B,
                                    ).withValues(alpha: 0.1),
                                    changeText:
                                        '${state.reportGrowthRate.abs().toStringAsFixed(0)}%',
                                    subtext: 'compared this month',
                                    isPositive: state.reportGrowthRate >= 0,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          // Activity Overview chart
                          Expanded(
                            child: activitiesAsync.when(
                              data: (activities) {
                                final chartData = _groupActivitiesByDay(
                                  activities,
                                );
                                return ActivityChart(activities: chartData);
                              },
                              loading: () => const Center(
                                child: CircularProgressIndicator(),
                              ),
                              error: (err, _) =>
                                  Center(child: Text('Error: $err')),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Right column: Report Status (spans full height)
                    Expanded(
                      flex: 1,
                      child: ReportDonutChart(reportStatus: state.reportStatus),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              // Recent Activities table (full width, anchored to screen height)
              Expanded(child: const RecentActivitiesTable()),
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

    // Generate last 7 days (chronological: 6 days ago -> Today)
    for (int i = 6; i >= 0; i--) {
      final date = today.subtract(Duration(days: i));
      final dayName = _getDayName(date.weekday);

      // Count activities for this specific calendar date
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
      case DateTime.monday:
        return 'Mon';
      case DateTime.tuesday:
        return 'Tue';
      case DateTime.wednesday:
        return 'Wed';
      case DateTime.thursday:
        return 'Thu';
      case DateTime.friday:
        return 'Fri';
      case DateTime.saturday:
        return 'Sat';
      case DateTime.sunday:
        return 'Sun';
      default:
        return '';
    }
  }
}
