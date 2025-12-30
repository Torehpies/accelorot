import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/providers/activity_providers.dart';
import '../../mobile_operator_dashboard/widgets/activity_log/activity_log_item_widget.dart';

class ActivityLogsCard extends ConsumerWidget {
  final String? focusedMachineId;
  final double? maxHeight;

  const ActivityLogsCard({super.key, this.focusedMachineId, this.maxHeight});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activitiesAsync = ref.watch(allActivitiesProvider);

    final cardContent = Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              const Icon(Icons.history, color: Colors.teal),
              const SizedBox(width: 8),
              const Text(
                'Recent Activities',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.refresh, size: 20),
                onPressed: () => ref.invalidate(allActivitiesProvider),
                tooltip: 'Refresh',
              ),
            ],
          ),
          const Divider(),
          
          // Body
          Expanded(
            child: activitiesAsync.when(
              data: (allLogs) {
                final filteredLogs = focusedMachineId != null
                    ? allLogs.where((log) => log.machineId == focusedMachineId).toList()
                    : allLogs;

                if (filteredLogs.isEmpty) {
                  return _buildEmptyState();
                }

                return ListView.builder(
                  itemCount: filteredLogs.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: ActivityLogItemWidget(log: filteredLogs[index]),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => _buildErrorState(context, ref, error),
            ),
          ),
        ],
      ),
    );

    return Card(
      color: const Color(0xFFF5F7FA),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: maxHeight != null
          ? SizedBox(height: maxHeight, child: cardContent)
          : cardContent,
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'No activities yet',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, WidgetRef ref, Object error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 8),
          Text('Error loading activities'),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: () => ref.invalidate(allActivitiesProvider),
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}