import '../../services/firestore_activity_service.dart';

class ActivityLogRepository {
  static Future<List<Map<String, dynamic>>> fetchWasteLogs() async {
    final activityItems = await FirestoreActivityService.getSubstrates();
    return activityItems.map((item) {
      return {
        'plantTypeLabel': item.title,
        'quantity': item.value,
        'description': item.description,
        'category': item.category,
        'timestamp': item.timestamp,
      };
    }).toList();
  }
}
