// activity_logs_card.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../services/firestore_activity_service.dart';
import '../../activity_logs/models/activity_item.dart';
import 'widgets/activity_log_item.dart';

class ActivityLogsCard extends StatefulWidget {
  final String? viewingOperatorId; // ⭐ NEW: Add parameter
  
  const ActivityLogsCard({
    super.key,
    this.viewingOperatorId, // ⭐ NEW: Add parameter
  });

  // Builds and manages the Activity Logs card widget.
  @override
  State<ActivityLogsCard> createState() => ActivityLogsCardState();
}

class ActivityLogsCardState extends State<ActivityLogsCard> {
  bool _loading = true;
  bool _logsFetchError = false;
  List<ActivityItem> _allLogs = [];

  // Initializes the widget state and triggers data fetch.
  @override
  void initState() {
    super.initState();
    _fetchAllLogs();
  }

  // Public method to refresh the activity logs from parent widget.
  Future<void> refresh() async {
    await _fetchAllLogs();
  }

  // Fetches activity logs from Firestore for the logged-in user or viewed operator.
  Future<void> _fetchAllLogs() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      if (mounted) {
        setState(() {
          _loading = false;
          _logsFetchError = true;
          _allLogs.clear();
        });
      }
      return;
    }

    try {
      setState(() => _loading = true);
      
      // ⭐ UPDATED: Pass viewingOperatorId to get correct user's logs
      final logs = await FirestoreActivityService.getAllActivities(
        viewingOperatorId: widget.viewingOperatorId,
      );

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
          _allLogs.clear();
        });
      }
    }
  }

  // Builds the Activity Logs card layout including header and log list.
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
            _buildCardBody(),
          ],
        ),
      ),
    );
  }

  // Constructs the card body, showing logs or messages based on state.
  Widget _buildCardBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    } else if (_logsFetchError || _allLogs.isEmpty) {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        return const Center(
          child: Text(
            'Please log in to view recent logs.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, fontSize: 13),
          ),
        );
      } else {
        return const Center(
          child: Text(
            'No logs yet. Add waste to get started!',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, fontSize: 13),
          ),
        );
      }
    } else {
      return SizedBox(
        height: 140,
        child: ListView.builder(
          itemCount: _allLogs.length,
          physics: const BouncingScrollPhysics(),
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: ActivityLogItem(log: _allLogs[index]),
            );
          },
        ),
      );
    }
  }
}