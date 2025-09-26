import 'package:flutter/material.dart';
// Uncomment these when you add Firebase later
// import 'package:cloud_firestore/cloud_firestore.dart';

class ActivityLogs extends StatelessWidget {
  final String title;

  const ActivityLogs({
    super.key,
    required this.title,
  });

  // 🔹 Firestore fetch function (ready for later)
  Future<List<LogEntry>> _fetchLogs() async {
    // Uncomment when Firestore is set up
    /*
    final snapshot = await FirebaseFirestore.instance
        .collection('logs')
        .orderBy('time', descending: true)
        .limit(10) // limit for performance
        .get();

    return snapshot.docs.map((doc) {
      return LogEntry(
        icon: Icons.info, // you can map this based on doc['type']
        iconColor: Colors.blue, // map based on severity maybe
        message: doc['message'] ?? "No message",
        time: doc['time'] ?? "--:--",
      );
    }).toList();
    */

    // 🔹 For now, just return empty → fallback to placeholders
    await Future.delayed(const Duration(seconds: 1));
    return [];
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Card(
        elevation: 10,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  const Icon(Icons.history, size: 26, color: Colors.black87),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),
              const Divider(thickness: 1, color: Colors.grey),
              const SizedBox(height: 12),

              // 🔹 Fetch logs dynamically
              FutureBuilder<List<LogEntry>>(
                future: _fetchLogs(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final logs = snapshot.data?.isNotEmpty == true
                      ? snapshot.data!
                      : _placeholderLogs();

                  return Column(
                    children: logs
                        .map((log) => _buildLogItem(
                              icon: log.icon,
                              iconColor: log.iconColor,
                              message: log.message,
                              time: log.time,
                            ))
                        .toList(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 🔹 Placeholder logs (fallback)
  List<LogEntry> _placeholderLogs() {
    return [
      LogEntry(
        icon: Icons.error,
        iconColor: Colors.red,
        message: "Moisture levels have dropped below optimal range",
        time: "10:15",
      ),
      LogEntry(
        icon: Icons.warning,
        iconColor: Colors.orange,
        message: "Brown Matter Added",
        time: "09:45",
      ),
      LogEntry(
        icon: Icons.check_circle,
        iconColor: Colors.green,
        message: "This is a sample text for smart suggestions.",
        time: "09:30",
      ),
    ];
  }


  // 🔹 Helper widget for log entries
  static Widget _buildLogItem({
    required IconData icon,
    required Color iconColor,
    required String message,
    required String time,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(fontSize: 14),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            time,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// 🔹 Model class
class LogEntry {
  final IconData icon;
  final Color iconColor;
  final String message;
  final String time;

  LogEntry({
    required this.icon,
    required this.iconColor,
    required this.message,
    required this.time,
  });
}
