import 'package:flutter/material.dart';

class CustomCard extends StatelessWidget {
  final String title;
  final List<Map<String, dynamic>> logs;

  const CustomCard({
    super.key, // ✅ Fixed: use super.key
    required this.title,
    required this.logs,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 400,
      height: 190,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
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
              const SizedBox(height: 8),
              const Divider(thickness: 1, color: Colors.grey),
              const SizedBox(height: 12),

              Expanded(
                child: logs.isEmpty
                    ? const Center(
                        child: Text(
                          "No waste logs yet...",
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    : ListView.builder(
                        itemCount: logs.length > 3 ? 3 : logs.length,
                        itemBuilder: (context, index) {
                          // ✅ This correctly shows newest first
                          final log = logs[logs.length - 1 - index];
                          final category = log['category'] == 'greens' ? 'Greens' : 'Browns';
                          final plant = log['plantTypeLabel'] ?? 'Plant';
                          final qty = log['quantity'];

                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            child: Text(
                              '• $category → $plant (${qty}kg)',
                              style: const TextStyle(fontSize: 13),
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