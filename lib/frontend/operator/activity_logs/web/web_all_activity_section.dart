// lib/frontend/operator/activity_logs/web/web_all_activity_section.dart
import 'package:flutter/material.dart';
import '../../../../services/firestore_activity_service.dart';
import '../../activity_logs/models/activity_item.dart';

class WebAllActivitySection extends StatelessWidget {
  final String? viewingOperatorId;

  const WebAllActivitySection({
    super.key,
    this.viewingOperatorId,
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
                const Icon(Icons.history, color: Colors.teal, size: 20),
                const SizedBox(width: 12),
                const Text(
                  'Recent Activity',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color.fromARGB(255, 243, 243, 243)),
          
          // Fetch real data from Firestore - all activities combined
          FutureBuilder<List<ActivityItem>>(
            future: FirestoreActivityService.getAllActivities(
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
                    'Error loading activities',
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                  ),
                );
              }

              final activities = snapshot.data ?? [];
              
              if (activities.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.all(32),
                  child: Center(
                    child: Text(
                      'No activities yet',
                      style: TextStyle(color: Colors.grey[600], fontSize: 13),
                    ),
                  ),
                );
              }

              // Show only first 5 most recent activities
              final recentActivities = activities.take(5).toList();

              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: recentActivities.length,
                itemBuilder: (context, index) {
                  final activity = recentActivities[index];
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    leading: Icon(
                      activity.icon,
                      color: Colors.teal,
                      size: 20,
                    ),
                    title: Text(
                      activity.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                        color: Color.fromARGB(255, 48, 47, 47),
                      ),
                    ),
                    subtitle: Text(
                      '${activity.formattedTimestamp} • ${activity.value}',
                      style: const TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: activity.statusColorValue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        activity.category,
                        style: TextStyle(
                          color: activity.statusColorValue,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
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