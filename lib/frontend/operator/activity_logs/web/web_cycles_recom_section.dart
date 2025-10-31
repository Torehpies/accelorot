// lib/frontend/operator/activity_logs/web/web_cycles_recom_section.dart
import 'package:flutter/material.dart';

class WebCyclesRecomSection extends StatelessWidget {
  final String? viewingOperatorId;
  final VoidCallback? onViewAll;

  const WebCyclesRecomSection({
    super.key,
    this.viewingOperatorId,
    this.onViewAll,
  });

  static List<Map<String, dynamic>> get _mockCycles => [
    {'id': '#42', 'status': 'Active', 'days': 'Day 12', 'temp': '58°C', 'bin': 'Bin A'},
    {'id': '#41', 'status': 'Completed', 'days': 'Finished', 'temp': '25°C', 'bin': 'Bin B'},
    {'id': '#40', 'status': 'Paused', 'days': 'Day 8', 'temp': '30°C', 'bin': 'Bin C'},
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
                const Icon(Icons.auto_awesome, color: Colors.blue, size: 20),
                const SizedBox(width: 12),
                // ✅ Title: explicitly black
                const Text(
                  'Composting Cycles',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black, // 🔲 Explicit black
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
            itemCount: _mockCycles.length,
            itemBuilder: (context, index) {
              final cycle = _mockCycles[index];
              final status = cycle['status'] as String;
              final color = _getStatusColor(status);
              return ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                // ✅ Cycle ID: black
                title: Text(
                  'Cycle ${cycle['id']}',
                  style: const TextStyle(fontSize: 14, color: Color.fromARGB(255, 48, 47, 47)),
                ),
                // ✅ Details: grey
                subtitle: Text(
                  '${cycle['bin']} • ${cycle['days']} • Current: ${cycle['temp']}',
                  style: const TextStyle(fontSize: 13, color: Colors.grey),
                ),
                trailing: Chip(
                  label: Text(status),
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

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Active': return Colors.blue;
      case 'Completed': return Colors.green;
      case 'Paused': return Colors.orange;
      default: return Colors.grey;
    }
  }
}