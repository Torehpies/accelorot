// lib/frontend/operator/activity_logs/view_screens/reports_screen.dart
import 'package:flutter/material.dart';
import '../widgets/shared/base_activity_screen.dart';
import '../models/activity_item.dart';
import '../../../../services/firestore_activity_service.dart';

class ReportsScreen extends BaseActivityScreen {
  const ReportsScreen({super.key, super.initialFilter, super.focusedMachineId});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends BaseActivityScreenState<ReportsScreen> {
  @override
  String get screenTitle =>
      widget.focusedMachineId != null ? 'Machine Reports' : 'Reports';

  @override
  List<String> get filters => const [
    'All',
    'Maintenance',
    'Observation',
    'Safety',
  ];

  @override
  Future<List<ActivityItem>> fetchData() async {
    return await FirestoreActivityService.getReports(
      viewingOperatorId: widget.viewingOperatorId,
    );
  }

  @override
  List<ActivityItem> filterByCategory(List<ActivityItem> items, String filter) {
    if (filter == 'All') return items;
    return items.where((item) => item.category == filter).toList();
  }

  @override
  Set<String> getCategoriesInSearchResults(List<ActivityItem> searchResults) {
    final categories = searchResults.map((item) => item.category).toSet();
    final specificCategories = {'Maintenance', 'Observation', 'Safety'};

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
