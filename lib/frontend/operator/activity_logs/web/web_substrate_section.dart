// lib/frontend/operator/activity_logs/web/web_substrate_section.dart
import 'package:flutter/material.dart';
import '../../../../services/firestore_activity_service.dart';
import '../../activity_logs/models/activity_item.dart';

class WebSubstrateSection extends StatelessWidget {
  final String? viewingOperatorId;
  final VoidCallback? onViewAll;

  const WebSubstrateSection({
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
                const Icon(Icons.eco, color: Colors.green, size: 20),
                const SizedBox(width: 12),
                const Text(
                  'Substrate Log',
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
            future: FirestoreActivityService.getSubstrates(
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
                    'Error loading substrates',
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                  ),
                );
              }

              final substrates = snapshot.data ?? [];
              
              if (substrates.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.all(32),
                  child: Center(
                    child: Text(
                      'No substrates yet',
                      style: TextStyle(color: Colors.grey[600], fontSize: 13),
                    ),
                  ),
                );
              }

              // Show only first 3 substrates
              final previewSubstrates = substrates.take(3).toList();

              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: previewSubstrates.length,
                itemBuilder: (context, index) {
                  final item = previewSubstrates[index];
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    leading: CircleAvatar(
                      radius: 16,
                      backgroundColor: _getTypeColor(item.category),
                      child: Icon(
                        item.icon,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                    title: Text(
                      item.title,
                      style: const TextStyle(fontSize: 14, color: Color.fromARGB(255, 48, 47, 47)),
                    ),
                    subtitle: Text(
                      '${item.value} • ${item.category}',
                      style: const TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                    trailing: Text(
                      item.formattedTimestamp,
                      style: const TextStyle(color: Colors.grey, fontSize: 13),
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

  Color _getTypeColor(String category) {
    switch (category.toLowerCase()) {
      case 'greens':
        return Colors.green;
      case 'browns':
        return Colors.brown;
      case 'compost':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }
}