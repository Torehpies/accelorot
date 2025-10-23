// view_screens/substrates_screen.dart
import 'package:flutter/material.dart';
import '../widgets/shared/base_activity_screen.dart';
import '../models/activity_item.dart';
import '../../../../services/firestore_activity_service.dart';

class SubstratesScreen extends BaseActivityScreen {
  const SubstratesScreen({super.key, super.initialFilter});

  @override
  State<SubstratesScreen> createState() => _SubstratesScreenState();
}

class _SubstratesScreenState extends BaseActivityScreenState<SubstratesScreen> {
  @override
  String get screenTitle => 'Substrate Logs';

  @override
  List<String> get filters => const ['All', 'Greens', 'Browns', 'Compost'];

  @override
  Future<List<ActivityItem>> fetchData() async {
    return await FirestoreActivityService.getSubstrates();
  }

  @override
List<ActivityItem> filterByCategory(List<ActivityItem> items, String filter) {
  if (filter == 'All') return items;
  
  // ⭐ Only debug newly added items
  final filtered = items.where((item) {
    if (item.title == 'Fruit Trees' || item.title == 'Compost') {  // Your newly added titles
    }
    return item.category == filter;
  }).toList();
  
  return filtered;
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