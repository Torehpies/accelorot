import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../view_model/web_admin_home_provider.dart';
import '../../core/ui/admin_app_bar.dart';
import '../web_widgets/stat_card.dart';
import '../web_widgets/activity_chart.dart';
import '../web_widgets/report_donut_chart.dart';
import '../web_widgets/recent_activities_table.dart';

class WebAdminHomeView extends ConsumerStatefulWidget {
  const WebAdminHomeView({super.key});

  @override
  ConsumerState<WebAdminHomeView> createState() =>
      _WebAdminHomeViewState();
}

class _WebAdminHomeViewState extends ConsumerState<WebAdminHomeView> {
  @override
  Widget build(BuildContext context) {
    /// ✅ Watch AsyncValue state
    final asyncState = ref.watch(webAdminHomeProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFDFF2FF),
      body: asyncState.when(
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
                onPressed: () => ref.read(webAdminHomeProvider.notifier).refresh(),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (state) => _buildDashboard(state),
      ),
    );
  }

  Widget _buildDashboard(WebAdminHomeState state) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Responsive breakpoints
        final isLargeScreen = constraints.maxWidth > 1200;
        final isMediumScreen = constraints.maxWidth > 800;
        
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Main layout: Left side (Stats + Activity) + Right side (Report Status)
                SizedBox(
                  height: isLargeScreen ? 400 : (isMediumScreen ? 360 : 320),
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
                              height: 110,
                              child: Row(
                                children: [
                                  Expanded(
                                    child: StatCard(
                                      title: "Total Operators",
                                      value: state.totalOperators,
                                      growth: state.operatorGrowthRate,
                                      icon: Icons.person_outline,
                                      iconBackgroundColor: const Color(0xFF22C55E),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: StatCard(
                                      title: "Total Machines",
                                      value: state.totalMachines,
                                      growth: state.machineGrowthRate,
                                      icon: Icons.settings_outlined,
                                      iconBackgroundColor: const Color(0xFF3B82F6),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: StatCard(
                                      title: "Total Reports",
                                      value: state.totalReports,
                                      growth: state.reportGrowthRate,
                                      icon: Icons.description_outlined,
                                      iconBackgroundColor: const Color(0xFFF59E0B),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            // Activity Overview chart
                            Expanded(
                              child: ActivityChart(activities: state.activities),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Right column: Report Status (spans full height)
                      Expanded(
                        flex: 1,
                        child: ReportDonutChart(reportStatus: state.reportStatus),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Recent Activities table (full width)
                SizedBox(
                  height: 220,
                  child: RecentActivitiesTable(activities: state.recentActivities),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

