// lib/ui/web_admin_home/widgets/dashboard_view.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_model/web_admin_dashboard_view_model.dart';
import 'stat_card.dart';
import 'activity_chart.dart';
import 'report_donut_chart.dart';
import 'recent_activities_table.dart';

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFDFF2FF),
      body: Consumer<WebAdminDashboardViewModel>(
        builder: (context, vm, _) {
          // Show loading indicator
          if (vm.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          // Show error message
          if (vm.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    vm.errorMessage!,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: vm.refresh,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

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
                                          value: vm.totalOperators,
                                          growth: vm.operatorGrowthRate,
                                          icon: Icons.person_outline,
                                          iconBackgroundColor: const Color(0xFF22C55E),
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: StatCard(
                                          title: "Total Machines",
                                          value: vm.totalMachines,
                                          growth: vm.machineGrowthRate,
                                          icon: Icons.settings_outlined,
                                          iconBackgroundColor: const Color(0xFF3B82F6),
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: StatCard(
                                          title: "Total Reports",
                                          value: vm.totalReports,
                                          growth: vm.reportGrowthRate,
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
                                  child: ActivityChart(activities: vm.activities),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          // Right column: Report Status (spans full height)
                          Expanded(
                            flex: 1,
                            child: ReportDonutChart(reportStatus: vm.reportStatus),
                          ),
                        ],
                      ),
                    ),
                      const SizedBox(height: 16),
                      // Recent Activities table (full width)
                      SizedBox(
                        height: 220,
                        child: RecentActivitiesTable(activities: vm.recentActivities),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
} 