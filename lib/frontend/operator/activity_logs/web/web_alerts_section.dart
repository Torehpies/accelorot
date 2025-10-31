// lib/frontend/operator/activity_logs/web/web_alerts_section.dart
import 'package:flutter/material.dart';

class WebAlertsSection extends StatelessWidget {
  final String? viewingOperatorId;
  final VoidCallback? onViewAll;

  const WebAlertsSection({
    super.key,
    this.viewingOperatorId,
    this.onViewAll,
  });

  static List<Map<String, dynamic>> get _mockAlerts => [
    {'time': '10:30 AM', 'type': 'High Temp', 'value': '62°C', 'status': 'Unresolved'},
    {'time': '09:15 AM', 'type': 'Low O2', 'value': '8%', 'status': 'Resolved'},
    {'time': 'Yesterday', 'type': 'Moisture', 'value': 'Too dry', 'status': 'Pending'},
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
                const Icon(Icons.warning, color: Colors.orange, size: 20),
                const SizedBox(width: 12),
                // ✅ Title text: explicitly black
                const Text(
                  'Recent Alerts',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black, // 🔲 Explicit black text
                  ),
                ),
                if (onViewAll != null) ...[
                  const Spacer(),
                  TextButton(
                    onPressed: onViewAll,
                    child: const Text(
                      'View All',
                      style: TextStyle(color: Colors.teal, fontSize: 13),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const Divider(height: 1, color: Color.fromARGB(255, 243, 243, 243)),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _mockAlerts.length,
            itemBuilder: (context, index) {
              final alert = _mockAlerts[index];
              final color = alert['status'] == 'Unresolved' ? Colors.red : Colors.green;
              return ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                // ✅ Alert type: black
                title: Text(
                  alert['type'] as String,
                  style: const TextStyle(fontSize: 14, color: Color.fromARGB(255, 48, 47, 47)),
                ),
                // ✅ Time & value: grey (as intended)
                subtitle: Text(
                  '${alert['time']} • ${alert['value']}',
                  style: const TextStyle(fontSize: 13, color: Colors.grey),
                ),
                trailing: Chip(
                  label: Text(alert['status'] as String),
                  backgroundColor: color,
                  labelStyle: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}