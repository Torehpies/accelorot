import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
//import '../../../../data/models/activity_log_item.dart';
import '../../../../data/providers/activity_providers.dart';
import '../activity_log/activity_log_item_widget.dart';

class ActivityLogsCard extends ConsumerStatefulWidget {
  final String? focusedMachineId;
  final double? maxHeight;

  const ActivityLogsCard({super.key, this.focusedMachineId, this.maxHeight});

  @override
  ConsumerState<ActivityLogsCard> createState() => ActivityLogsCardState();
}

class ActivityLogsCardState extends ConsumerState<ActivityLogsCard> {
  
  @override
  Widget build(BuildContext context) {
    final activitiesAsync = ref.watch(allActivitiesProvider);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
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
                  'Activity Logs',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.refresh, size: 20),
                  onPressed: () {
                    ref.invalidate(allActivitiesProvider);
                  },
                  tooltip: 'Refresh',
                ),
              ],
            ),
            const Divider(),
            
            // Body
            Expanded(
              child: activitiesAsync.when(
                data: (allLogs) {
                  // Filter by machine if needed
                  final filteredLogs = widget.focusedMachineId != null
                      ? allLogs.where((log) => log.machineId == widget.focusedMachineId).toList()
                      : allLogs;

                  if (filteredLogs.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.inbox, size: 64, color: Colors.grey[300]),
                          const SizedBox(height: 16),
                          Text(
                            'No activities found',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: filteredLogs.length,
                    physics: const ClampingScrollPhysics(),
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: ActivityLogItemWidget(log: filteredLogs[index]),
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 48, color: Colors.red),
                      const SizedBox(height: 8),
                      Text('Error: ${error.toString()}'),
                      const SizedBox(height: 8),
                      ElevatedButton.icon(
                        onPressed: () {
                          ref.invalidate(allActivitiesProvider);
                        },
                        icon: const Icon(Icons.refresh),
                        label: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}