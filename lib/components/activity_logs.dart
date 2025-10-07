// lib/components/activity-logs.dart
import 'package:flutter/material.dart';

class CustomCard extends StatelessWidget {
  final String title;
  final List<Map<String, dynamic>> logs;

  const CustomCard({super.key, required this.title, required this.logs});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 400,
      height: 170,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 6),
              const Divider(thickness: 1, color: Colors.grey),
              const SizedBox(height: 8),

              Flexible(
                child: logs.isEmpty
                    ? const Center(
                        child: Text(
                          "No waste logs yet...",
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    : ListView.builder(
                        itemCount: logs.length > 3 ? 3 : logs.length,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (context, index) {
                          final log = logs[logs.length - 1 - index];
                          final category = log['category'] == 'greens'
                              ? 'Greens'
                              : 'Browns';
                          final plant = log['plantTypeLabel'] ?? 'Plant';
                          final qty = log['quantity'];

                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            child: Text(
                              '• $category → $plant (${qty}kg)',
                              style: const TextStyle(fontSize: 13),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
