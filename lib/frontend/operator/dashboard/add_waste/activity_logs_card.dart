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
      if (mounted) {
        setState(() {
          _allLogs = logs;
          _loading = false;
          _logsFetchError = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _logsFetchError = true;
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
            // Header row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Activity Logs',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.teal,
                  ),
                ),
                const Icon(Icons.history, size: 20, color: Colors.teal),
              ],
            ),
            const SizedBox(height: 12),

            if (_loading)
              const Center(child: CircularProgressIndicator())
            else if (_logsFetchError)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Center(
                  child: Text(
                    'Please log in to view recent activities.',
                    style: TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                ),
              )
            else if (_allLogs.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Center(
                  child: Text(
                    'No logs yet. Add some activity to see updates here.',
                    style: TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                ),
              )
            else
              _buildLogsList(),
          ],
        ),
      ),
    );
  }

  Widget _buildLogsList() {
    return SizedBox(
      height: 140, // fits approximately 2 logs
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
                // title and quantity row
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
                // description
                if (log.description.isNotEmpty)
                  Text(
                    log.description,
                    style: const TextStyle(fontSize: 12, color: Colors.black87),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                const SizedBox(height: 4),
                // category + date row
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

  // --- helpers ---

  String _formatQuantity(String value) {
    String str = value.trim().toLowerCase();

    // If the string already contains valid unit characters, leave it alone.
    final hasKnownUnit = str.contains(
      RegExp(r'(kg|%|°c|min|hr|hours?)', caseSensitive: false),
    );

    // Remove weird double suffixes (kgkg, %% etc.)
    str = str.replaceAll(
      RegExp(r'(kgkg|%%|°c°c|minmin|hrhr)', caseSensitive: false),
      '',
    );

    // Only append kg if truly numeric (for substrates)
    if (!hasKnownUnit && RegExp(r'^\d+(\.\d+)?$').hasMatch(str)) {
      str = '$str kg';
    }

    // Clean leftover spaces between number and unit
    str = str.replaceAll(RegExp(r'\s+'), '');

    return str;
  }

  String _capitalize(String? text) {
    if (text == null || text.isEmpty) return '';
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }
}
