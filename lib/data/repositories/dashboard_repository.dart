// lib/data/repositories/dashboard_repository.dart

import 'package:flutter/foundation.dart';
import 'operator_repository/operator_repository.dart';
import 'machine_repository/machine_repository.dart';
import 'report_repository.dart';
import '../models/report.dart';

abstract class DashboardRepository {
  Future<DashboardData> fetchDashboardData(String teamId);
}

class DashboardRepositoryImpl implements DashboardRepository {
  final OperatorRepository _operatorRepo;
  final MachineRepository _machineRepo;
  final ReportRepository _reportRepo;

  DashboardRepositoryImpl({
    required OperatorRepository operatorRepo,
    required MachineRepository machineRepo,
    required ReportRepository reportRepo,
  })  : _operatorRepo = operatorRepo,
        _machineRepo = machineRepo,
        _reportRepo = reportRepo;

  @override
  Future<DashboardData> fetchDashboardData(String teamId) async {
    // 1. Fetch totals
    final operators = await _operatorRepo.getOperators(teamId);
    final machines = await _machineRepo.getMachinesByTeam(teamId);
    final reports = await _reportRepo.getReportsByTeam(teamId);

    // 2. Count report statuses
    final reportStatus = _countReportStatus(reports);

    // 3. Build recent activities (use reports as activities)
    final recentActivities = reports
        .map((report) => _mapReportToActivity(report))
        .where((activity) => activity != null)
        .take(8)
        .toList();

    // 4. Build daily activity counts (last 7 days)
    final activities = _buildDailyActivityCounts(reports);

    return DashboardData(
      totalOperators: operators.length,
      totalMachines: machines.length,
      reportStatus: reportStatus,
      recentActivities: recentActivities.cast<Map<String, String>>(),
      activities: activities,
    );
  }

  Map<String, int> _countReportStatus(List<Report> reports) {
    final counts = {'Open': 0, 'In Progress': 0, 'Closed': 0, 'Pending': 0};
    for (final report in reports) {
      final status = _normalizeStatus(report.status);
      if (counts.containsKey(status)) {
        counts[status] = counts[status]! + 1;
      }
    }
    return counts;
  }

  String _normalizeStatus(String status) {
    final lower = status.toLowerCase();
    if (lower == 'open') return 'Open';
    if (lower == 'in_progress' || lower == 'in progress') return 'In Progress';
    if (lower == 'closed' || lower == 'resolved') return 'Closed';
    return 'Pending';
  }

  Map<String, String>? _mapReportToActivity(Report report) {
    String icon;
    if (report.status.toLowerCase() == 'open' || report.status.toLowerCase() == 'pending') {
      icon = 'alert';
    } else if (report.status.toLowerCase() == 'closed' || report.status.toLowerCase() == 'resolved') {
      icon = 'check';
    } else {
      icon = 'clipboard';
    }

    // Format date as "Dec 18"
    final date = report.createdAt.toLocal();
    final formattedDate = '${_monthAbbrev(date.month)} ${date.day}';

    // Determine category from report type
    String category = 'Reporting';
    if (report.reportType.toLowerCase().contains('maintenance')) {
      category = 'Maintenance';
    } else if (report.reportType.toLowerCase().contains('safety')) {
      category = 'Safety';
    } else if (report.reportType.toLowerCase().contains('observation')) {
      category = 'Observation';
    }

    return {
      'icon': icon,
      'description': report.title,
      'username': report.userName,
      'category': category,
      'status': _normalizeStatus(report.status),
      'date': formattedDate,
    };
  }

  String _monthAbbrev(int month) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }

  List<Map<String, dynamic>> _buildDailyActivityCounts(List<Report> reports) {
    // Get last 7 days (including today)
    final now = DateTime.now().toLocal();
    final dayNames = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];

    // Initialize counts for the last 7 days
    final counts = <String, int>{};
    for (int i = 6; i >= 0; i--) {
      final day = now.subtract(Duration(days: i));
      final dayName = dayNames[day.weekday - 1]; // Monday = 1 → index 0
      counts[dayName] = 0;
    }

    // Count reports per day
    for (final report in reports) {
      final reportDate = report.createdAt.toLocal();

      // Only include reports from last 7 days
      final difference = now.difference(reportDate).inDays;
      if (difference >= 0 && difference < 7) {
        final dayName = dayNames[reportDate.weekday - 1];
        counts[dayName] = (counts[dayName] ?? 0) + 1;
      }
    }

    // Convert to list format expected by the chart
    return counts.entries.map((e) => {'day': e.key, 'count': e.value}).toList();
  }
}

@immutable
class DashboardData {
  final int totalOperators;
  final int totalMachines;
  final Map<String, int> reportStatus;
  final List<Map<String, String>> recentActivities;
  final List<Map<String, dynamic>> activities;

  const DashboardData({
    required this.totalOperators,
    required this.totalMachines,
    required this.reportStatus,
    required this.recentActivities,
    required this.activities,
  });
}