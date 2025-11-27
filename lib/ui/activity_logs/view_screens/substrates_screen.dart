// lib/frontend/operator/activity_logs/view_screens/substrates_screen.dart
import 'package:flutter/material.dart';
import '../widgets/shared/base_activity_screen.dart';
import '../../../data/models/activity_item.dart';
import '../../../services/firestore_activity_service.dart';

class SubstratesScreen extends BaseActivityScreen {
  const SubstratesScreen({
    super.key,
    super.initialFilter,
    super.focusedMachineId,
  });

  @override
  State<SubstratesScreen> createState() => _SubstratesScreenState();
}

class _SubstratesScreenState extends BaseActivityScreenState<SubstratesScreen> {
  @override
  String get screenTitle => widget.focusedMachineId != null
      ? 'Machine Substrate Logs'
      : 'Substrate Logs';

  @override
  List<String> get filters => const ['All', 'Greens', 'Browns', 'Compost'];

  @override
  Future<List<ActivityItem>> fetchData() async {
    return await FirestoreActivityService.getSubstrates(
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
    final specificCategories = {'Greens', 'Browns', 'Compost'};

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
