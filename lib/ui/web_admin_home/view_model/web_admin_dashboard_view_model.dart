// lib/ui/web_admin_home/view_model/web_admin_dashboard_view_model.dart
import 'package:flutter/foundation.dart';

class WebAdminDashboardViewModel extends ChangeNotifier {
  int totalOperators = 36;
  int totalMachines = 14;
  int totalReports = 158;
  double operatorGrowthRate = 29.0;
  double machineGrowthRate = 23.0;
  double reportGrowthRate = -10.0;

  List<Map<String, dynamic>> activities = [
    {'day': 'Monday', 'count': 55},
    {'day': 'Tuesday', 'count': 65},
    {'day': 'Wednesday', 'count': 80},
    {'day': 'Thursday', 'count': 75},
    {'day': 'Friday', 'count': 70},
    {'day': 'Saturday', 'count': 35},
  ];

  Map<String, int> reportStatus = {
    'Open': 8,
    'In Progress': 10,
    'Closed': 7,
    'Pending': 5,
  };

  List<Map<String, String>> recentActivities = [
    {
      'icon': 'alert',
      'description': 'Critical system alert detected',
      'username': 'john_doe',
      'category': 'System',
      'status': 'Open',
      'date': 'Dec 18'
    },
    {
      'icon': 'check',
      'description': 'Machine maintenance completed',
      'username': 'jane_smith',
      'category': 'Maintenance',
      'status': 'Closed',
      'date': 'Dec 17'
    },
    {
      'icon': 'clipboard',
      'description': 'New report submitted for review',
      'username': 'admin_user',
      'category': 'Reporting',
      'status': 'In Progress',
      'date': 'Dec 16'
    },
    {
      'icon': 'alert',
      'description': 'Equipment malfunction reported',
      'username': 'operator_5',
      'category': 'Equipment',
      'status': 'Open',
      'date': 'Dec 15'
    },
    {
      'icon': 'check',
      'description': 'Safety inspection passed',
      'username': 'inspector_1',
      'category': 'Safety',
      'status': 'Closed',
      'date': 'Dec 14'
    },
    {
      'icon': 'clipboard',
      'description': 'Monthly report generated',
      'username': 'system',
      'category': 'Reporting',
      'status': 'Closed',
      'date': 'Dec 13'
    },
    {
      'icon': 'alert',
      'description': 'Low inventory warning',
      'username': 'inventory_bot',
      'category': 'Inventory',
      'status': 'Open',
      'date': 'Dec 12'
    },
    {
      'icon': 'check',
      'description': 'User training completed',
      'username': 'trainer_2',
      'category': 'Training',
      'status': 'Closed',
      'date': 'Dec 11'
    },
  ];

  List<String> get reportLegends => reportStatus.keys.toList();
}