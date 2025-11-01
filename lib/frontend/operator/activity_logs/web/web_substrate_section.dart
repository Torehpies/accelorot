// lib/frontend/operator/activity_logs/web/web_substrate_section.dart
import 'package:flutter/material.dart';

class WebSubstrateSection extends StatelessWidget {
  final String? viewingOperatorId;
  final VoidCallback? onViewAll;

  const WebSubstrateSection({
    super.key,
    this.viewingOperatorId,
    this.onViewAll,
  });

  static List<Map<String, dynamic>> get _mockSubstrates => [
    {'type': 'Greens', 'amount': '5 kg', 'time': 'Today, 10:30 AM', 'source': 'Kitchen'},
    {'type': 'Browns', 'amount': '3 kg', 'time': 'Today, 09:00 AM', 'source': 'Yard'},
    {'type': 'Compost', 'amount': '10 kg', 'time': 'Yesterday', 'source': 'Harvest'},
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
                const Icon(Icons.eco, color: Colors.green, size: 20),
                const SizedBox(width: 12),
                // ✅ Title: explicitly black
                const Text(
                  'Substrate Log',
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
            itemCount: _mockSubstrates.length,
            itemBuilder: (context, index) {
              final item = _mockSubstrates[index];
              return ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                leading: CircleAvatar(
                  radius: 16,
                  backgroundColor: _getTypeColor(item['type'] as String),
                  child: Icon(
                    _getTypeIcon(item['type'] as String),
                    color: Colors.white,
                    size: 16,
                  ),
                ),
                // ✅ Type: black
                title: Text(
                  item['type'] as String,
                  style: const TextStyle(fontSize: 14, color: Color.fromARGB(255, 48, 47, 47)),
                ),
                // ✅ Amount & source: grey
                subtitle: Text(
                  '${item['amount']} • ${item['source']}',
                  style: const TextStyle(fontSize: 13, color: Colors.grey),
                ),
                // ✅ Time: grey
                trailing: Text(
                  item['time'] as String,
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'Greens': return Colors.green;
      case 'Browns': return Colors.brown;
      case 'Compost': return Colors.teal;
      default: return Colors.grey;
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'Greens': return Icons.local_dining;
      case 'Browns': return Icons.park;
      case 'Compost': return Icons.recycling;
      default: return Icons.eco;
    }
  }
}