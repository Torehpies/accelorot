// lib/frontend/operator/activity_logs/web/web_all_activity_section.dart
import 'package:flutter/material.dart';

class WebAllActivitySection extends StatelessWidget {
  final String? viewingOperatorId;

  const WebAllActivitySection({
    super.key,
    this.viewingOperatorId,
  });

  static List<Map<String, dynamic>> get _mockLogs => [
    {'time': '10:30 AM', 'user': 'Miguel', 'action': 'Added greens', 'details': '5kg kitchen waste'},
    {'time': '09:15 AM', 'user': 'System', 'action': 'Temp alert', 'details': '62°C in Bin A'},
    {'time': 'Yesterday', 'user': 'Admin', 'action': 'Cycle started', 'details': 'Cycle #42'},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color.fromARGB(255, 243, 243, 243), width: 1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(Icons.history, color: Colors.teal, size: 20),
                const SizedBox(width: 12),
                // ✅ Title text: explicitly black
                const Text(
                  'Recent Activity',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black, // 🔲 Explicit black
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color.fromARGB(255, 243, 243, 243)),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _mockLogs.length,
            itemBuilder: (context, index) {
              final log = _mockLogs[index];
              return ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                // ✅ Action: black (bold)
                title: Text(
                  log['action'] as String,
                  style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14, color:Color.fromARGB(255, 48, 47, 47)),
                ),
                // ✅ Details: grey
                subtitle: Text(
                  '${log['time']} • ${log['details']}',
                  style: const TextStyle(fontSize: 13, color: Colors.grey),
                ),
                // ✅ User: grey
                trailing: Text(
                  log['user'] as String,
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}