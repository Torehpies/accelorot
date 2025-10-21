import 'package:flutter/material.dart';
import '../../../../services/firestore_activity_service.dart';
import '../../activity_logs/models/activity_item.dart';

class ActivityLogsCard extends StatefulWidget {
  const ActivityLogsCard({super.key});

  @override
  State<ActivityLogsCard> createState() => _ActivityLogsCardState();
}

class _ActivityLogsCardState extends State<ActivityLogsCard> {
  bool _loading = true;
  bool _logsFetchError = false;
  List<ActivityItem> _allLogs = [];

  @override
  void initState() {
    super.initState();
    _fetchAllLogs();
  }

  Future<void> _fetchAllLogs() async {
    try {
      final logs = await FirestoreActivityService.getAllActivities();

      // If there’s no data, still treat as success (empty)
      if (mounted) {
        setState(() {
          _allLogs = logs;
          _loading = false;
          _logsFetchError = false;
        });
      }
    } catch (e) {
      // Handle login or Firestore access failures gracefully
      if (mounted) {
        setState(() {
          _loading = false;
          _logsFetchError = true;
          _allLogs.clear(); // ensure no stale data
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.white,
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text(
                  'Activity Logs',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.teal,
                  ),
                ),
                Icon(Icons.history, size: 20, color: Colors.teal),
              ],
            ),
            const SizedBox(height: 12),

            // Loading state
            if (_loading)
              const Center(child: CircularProgressIndicator())
            // Error state
            else if (_logsFetchError)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 18),
                child: Center(
                  child: Text(
                    'Please log in to view recent activities.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                ),
              )
            // Empty state
            else if (_allLogs.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 18),
                child: Center(
                  child: Text(
                    'No logs yet. Add some activity to see updates here.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                ),
              )
            // Data state
            else
              _buildLogsList(),
          ],
        ),
      ),
    );
  }

  Widget _buildLogsList() {
    return SizedBox(
      height: 140, // fits ~2 logs
      child: ListView.builder(
        itemCount: _allLogs.length,
        physics: const BouncingScrollPhysics(),
        itemBuilder: (context, index) {
          final log = _allLogs[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildLogItem(log),
          );
        },
      ),
    );
  }

  Widget _buildLogItem(ActivityItem log) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(log.icon, color: Colors.black54, size: 32),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // title + value
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        log.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    Text(
                      _formatQuantity(log.value),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                if (log.description.isNotEmpty)
                  Text(
                    log.description,
                    style: const TextStyle(fontSize: 12, color: Colors.black87),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _capitalize(log.category),
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      log.formattedTimestamp,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper: detect and format value units properly
  String _formatQuantity(String value) {
    String str = value.trim().toLowerCase();
    final hasKnownUnit =
        str.contains(RegExp(r'(kg|%|°c|min|hr|hours?)', caseSensitive: false));
    str = str.replaceAll(
        RegExp(r'(kgkg|%%|°c°c|minmin|hrhr)', caseSensitive: false), '');
    if (!hasKnownUnit && RegExp(r'^\d+(\.\d+)?$').hasMatch(str)) str = '$str kg';
    return str.replaceAll(RegExp(r'\s+'), '');
  }

  String _capitalize(String? text) {
    if (text == null || text.isEmpty) return '';
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }
}
