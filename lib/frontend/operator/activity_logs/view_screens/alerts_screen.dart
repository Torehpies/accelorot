import 'package:flutter/material.dart';
import '../widgets/shared/base_activity_screen.dart';
import '../models/activity_item.dart';
import '../../../../services/firestore_activity_service.dart';

class AlertsScreen extends BaseActivityScreen {
  const AlertsScreen({
    super.key,
    super.initialFilter,
    super.focusedMachineId,
  });

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends BaseActivityScreenState<AlertsScreen> {
  @override
  String get screenTitle =>
      widget.focusedMachineId != null ? 'Machine Alerts' : 'Alerts Logs';

  @override
  List<String> get filters => const ['All', 'Temperature', 'Moisture', 'Oxygen'];

  /// Helper function to capitalize first letter properly
  String toProperCase(String input) {
    if (input.isEmpty) return input;
    return input[0].toUpperCase() + input.substring(1).toLowerCase();
  }

  @override
  Future<List<ActivityItem>> fetchData() async {
    return await FirestoreActivityService.getAlerts();
  }

  @override
  List<ActivityItem> filterByCategory(List<ActivityItem> items, String filter) {
    if (filter == 'All') return items;
    return items.where((item) => item.category == filter).toList();
  }

  @override
  Set<String> getCategoriesInSearchResults(List<ActivityItem> searchResults) {
    final categories = searchResults.map((item) => item.category).toSet();
    final specificCategories = {'Temperature', 'Moisture', 'Oxygen'};

    Set<String> result = {};
    for (var cat in specificCategories) {
      if (categories.contains(cat)) {
        result.add(cat);
      }
    }

    if (specificCategories.every((cat) => categories.contains(cat))) {
      result.add('All');
    }

    return result;
  }
}
