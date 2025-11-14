// lib/frontend/operator/activity_logs/view_screens/all_activity_screen.dart
import 'package:flutter/material.dart';
import '../widgets/shared/base_activity_screen.dart';
import '../models/activity_item.dart';
import '../../../../services/firestore_activity_service.dart';

class AllActivityScreen extends BaseActivityScreen {
  const AllActivityScreen({super.key, super.focusedMachineId})
    : super(initialFilter: 'All');

  @override
  State<AllActivityScreen> createState() => _AllActivityScreenState();
}

class _AllActivityScreenState
    extends BaseActivityScreenState<AllActivityScreen> {
  @override
  String get screenTitle => widget.focusedMachineId != null
      ? 'Machine Activity Logs'
      : 'All Activity Logs';

  @override
  // UPDATED: Added 'Cycles' and 'Reports'
  List<String> get filters => const [
    'All',
    'Substrate',
    'Alerts',
    'Cycles',
    'Reports',
  ];

  @override
  Future<List<ActivityItem>> fetchData() async {
    return await FirestoreActivityService.getAllActivities();
  }

  @override
  List<ActivityItem> filterByCategory(List<ActivityItem> items, String filter) {
    if (filter == 'All') return items;

    if (filter == 'Substrate') {
      return items
          .where(
            (item) => ['Greens', 'Browns', 'Compost'].contains(item.category),
          )
          .toList();
    }

    if (filter == 'Alerts') {
      return items
          .where(
            (item) => ['Temp', 'Moisture', 'Oxygen'].contains(item.category),
          )
          .toList();
    }

    if (filter == 'Cycles') {
      return items
          .where((item) => ['Recoms', 'Cycles'].contains(item.category))
          .toList();
    }

    if (filter == 'Reports') {
      return items
          .where(
            (item) => [
              'Maintenance',
              'Observation',
              'Safety',
            ].contains(item.category),
          )
          .toList();
    }

    return items;
  }

  @override
  Set<String> getCategoriesInSearchResults(List<ActivityItem> searchResults) {
    final categories = searchResults.map((item) => item.category).toSet();

    bool hasSubstrate = categories.any(
      (cat) => ['Greens', 'Browns', 'Compost'].contains(cat),
    );
    bool hasAlerts = categories.any(
      (cat) => ['Temp', 'Moisture', 'Oxygen'].contains(cat),
    );
    bool hasCycles = categories.any(
      (cat) => ['Recoms', 'Cycles'].contains(cat),
    );
    bool hasReports = categories.any(
      (cat) => ['Maintenance', 'Observation', 'Safety'].contains(cat),
    );

    Set<String> result = {};
    if (hasSubstrate) result.add('Substrate');
    if (hasAlerts) result.add('Alerts');
    if (hasCycles) result.add('Cycles');
    if (hasReports) result.add('Reports');

    // UPDATED: All requires all 4 categories
    if (hasSubstrate && hasAlerts && hasCycles && hasReports) {
      result.add('All');
    }

    return result;
  }
}
