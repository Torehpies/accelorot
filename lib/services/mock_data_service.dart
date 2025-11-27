//mock_data_service.dart
import '../data/models/activity_item.dart';
import 'act_logs_firestore/mock_data/substrates.dart';
import 'act_logs_firestore/mock_data/alerts.dart';
import 'act_logs_firestore/mock_data/recom_cycles.dart';

class MockDataService {
  // Helper to get date X days ago
  static DateTime daysAgo(int days, {int hour = 12, int minute = 0}) {
    final now = DateTime.now();
    final target = now.subtract(Duration(days: days));
    return DateTime(target.year, target.month, target.day, hour, minute);
  }

  static List<ActivityItem> getSubstrates() => List.from(substrates);
  static List<ActivityItem> getAlerts() => List.from(alerts);
  static List<ActivityItem> getCyclesRecom() => List.from(cyclesRecom);

  // Get all activities combined and sorted by timestamp
  static List<ActivityItem> getAllActivities() {
    final combined = [...substrates, ...alerts, ...cyclesRecom];
    combined.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return combined;
  }
}
