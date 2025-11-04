// lib/frontend/operator/activity_logs/web/web_alerts_section.dart
import 'package:flutter/material.dart';
import '../../../../services/firestore_activity_service.dart';
import '../../activity_logs/models/activity_item.dart';

class WebAlertsSection extends StatelessWidget {
  final String? viewingOperatorId;
  final VoidCallback? onViewAll;

  const WebAlertsSection({
    super.key,
    this.viewingOperatorId,
    this.onViewAll,
  });

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
                const Text(
                  'Recent Alerts',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
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
          
          // Fetch real data from Firestore
          FutureBuilder<List<ActivityItem>>(
            future: FirestoreActivityService.getAlerts(
              viewingOperatorId: viewingOperatorId,
            ),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              if (snapshot.hasError) {
                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'Error loading alerts',
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                  ),
                );
              }

              final alerts = snapshot.data ?? [];
              
              if (alerts.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.all(32),
                  child: Center(
                    child: Text(
                      'No alerts yet',
                      style: TextStyle(color: Colors.grey[600], fontSize: 13),
                    ),
                  ),
                );
              }

              // Show only first 3 alerts
              final previewAlerts = alerts.take(3).toList();

              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: previewAlerts.length,
                itemBuilder: (context, index) {
                  final alert = previewAlerts[index];
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    title: Text(
                      alert.title,
                      style: const TextStyle(fontSize: 14, color: Color.fromARGB(255, 48, 47, 47)),
                    ),
                    subtitle: Text(
                      '${alert.formattedTimestamp} • ${alert.value}',
                      style: const TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: alert.statusColorValue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        alert.category,
                        style: TextStyle(
                          color: alert.statusColorValue,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}