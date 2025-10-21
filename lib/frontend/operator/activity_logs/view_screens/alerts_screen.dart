// view_screens/alerts_screen.dart
import 'package:flutter/material.dart';
import '../widgets/shared/base_activity_screen.dart';
import '../models/activity_item.dart';
import '../../../../services/firestore_activity_service.dart';

class AlertsScreen extends BaseActivityScreen {
  const AlertsScreen({super.key, String? initialFilter})
      : super(initialFilter: initialFilter);

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends BaseActivityScreenState<AlertsScreen> {
  @override
  String get screenTitle => 'Alerts Logs';

  @override
  List<String> get filters => const ['All', 'Temp', 'Moisture', 'Oxygen'];

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
    final specificCategories = {'Temp', 'Moisture', 'Oxygen'};
    
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