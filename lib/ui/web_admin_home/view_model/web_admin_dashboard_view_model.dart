import 'package:flutter/foundation.dart';

class WebAdminDashboardViewModel extends ChangeNotifier {
  // Static dummy data for now — replace with API calls later
  int totalOperators = 20;
  int totalMachines = 20;
  double growthRate = 10.0; // %

  List<Map<String, dynamic>> activities = [
    {'day': 'Monday', 'count': 50},
    {'day': 'Tuesday', 'count': 65},
    {'day': 'Wednesday', 'count': 75},
    {'day': 'Thursday', 'count': 80},
    {'day': 'Friday', 'count': 70},
    {'day': 'Saturday', 'count': 35},
  ];

  Map<String, int> reportStatus = {
    'Open': 10,
    'In Progress': 12,
    'Closed': 8,
    'Pending': 0, // For demo
  };

  List<Map<String, String>> recentActivities = [
    {
      'icon': 'assets/icons/clipboard.png',
      'description': 'Lorem ipsum is a sample text description',
      'username': 'Username',
      'category': 'Category',
      'status': 'Status',
      'date': 'Date'
    },
    {
      'icon': 'assets/icons/check.png',
      'description': 'Lorem ipsum is a sample text description',
      'username': 'Username',
      'category': 'Category',
      'status': 'Status',
      'date': 'Date'
    },
    {
      'icon': 'assets/icons/alert.png',
      'description': 'Lorem ipsum is a sample text description',
      'username': 'Username',
      'category': 'Category',
      'status': 'Status',
      'date': 'Date'
    },
  ];

  // Future<void> fetchDashboardData() async {
  //   // TODO: Fetch from repository
  // }

  int get totalReports => reportStatus.values.reduce((a, b) => a + b);

  List<String> get reportLegends => reportStatus.keys.toList();
}