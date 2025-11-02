//lib/frontend/operator/activity_logs/view_screens/cycles_recom_screen.dart
import 'package:flutter/material.dart';
import '../widgets/shared/base_activity_screen.dart';
import '../models/activity_item.dart';
import '../../../../services/firestore_activity_service.dart';

class CyclesRecomScreen extends BaseActivityScreen {
  const CyclesRecomScreen({
    super.key, 
    super.initialFilter,
    super.focusedMachineId,
  });

  @override
  State<CyclesRecomScreen> createState() => _CyclesRecomScreenState();
}

class _CyclesRecomScreenState extends BaseActivityScreenState<CyclesRecomScreen> {
  @override
  String get screenTitle => widget.focusedMachineId != null
      ? 'Machine Cycles & Recommendations'
      : 'Cycles & Recommendations'; // ⭐ Dynamic title

  @override
  List<String> get filters => const ['All', 'Recoms', 'Cycles'];

  @override
  Future<List<ActivityItem>> fetchData() async {
    // ⭐ UPDATED: Pass viewingOperatorId to service
    return await FirestoreActivityService.getCyclesRecom(
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
    final specificCategories = {'Recoms', 'Cycles'};
    
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