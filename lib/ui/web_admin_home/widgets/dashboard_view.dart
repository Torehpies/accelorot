// lib/ui/web_admin_home/widgets/dashboard_view.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_model/web_admin_dashboard_view_model.dart';
import 'stat_card.dart';
import 'activity_chart.dart';
import 'report_donut_chart.dart';
import 'recent_activities_table.dart';
import 'calendar_widget.dart';

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Dashboard')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Consumer<WebAdminDashboardViewModel>(
          builder: (context, vm, _) => SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top row: Stat Cards
                Row(
                  children: [
                    Expanded(
                      child: StatCard(
                        title: "Total Operators",
                        value: vm.totalOperators,     // ✅ No ?? needed
                        growth: vm.growthRate,       // ✅ No ?? needed
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: StatCard(
                        title: "Total Machines",
                        value: vm.totalMachines,     // ✅ No ?? needed
                        growth: vm.growthRate,       // ✅ No ?? needed
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: ReportDonutChart(reportStatus: vm.reportStatus),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Middle row: Charts
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: ActivityChart(activities: vm.activities),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      flex: 1,
                      child: RecentActivitiesTable(activities: vm.recentActivities),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Bottom row: Calendar
                Row(
                  children: [
                    Expanded(child: CalendarWidget()),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}