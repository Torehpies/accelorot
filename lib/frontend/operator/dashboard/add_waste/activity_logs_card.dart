// lib/frontend/operator/dashboard/add_waste/activity_logs_card.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../services/firestore_activity_service.dart';
import '../../activity_logs/models/activity_item.dart';
import 'widgets/activity_log_item.dart';

class ActivityLogsCard extends StatefulWidget {
  final String? focusedMachineId;

  const ActivityLogsCard({
    super.key,
    this.focusedMachineId,
  });

  @override
  State<ActivityLogsCard> createState() => ActivityLogsCardState();
}

class ActivityLogsCardState extends State<ActivityLogsCard> {
  bool _loading = true;
  bool _logsFetchError = false;
  List<ActivityItem> _allLogs = [];

  @override
  void initState() {
    super.initState();
    _fetchAllLogs();
  }

  /// Public method to refresh the activity logs from parent widget
  Future<void> refresh() async {
    await _fetchAllLogs();
  }

  /// Fetches activity logs from Firestore (substrates + reports)
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
          _allLogs.clear();
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.focusedMachineId != null
                      ? 'Machine Activity Logs'
                      : 'Recent Activity',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.teal,
                  ),
                ),
                const Icon(Icons.history, size: 20, color: Colors.teal),
              ],
            ),
            const SizedBox(height: 12),
            _buildCardBody(),
          ],
        ),
      ),
    );
  }

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
        return Center(
          child: Text(
            widget.focusedMachineId != null
                ? 'No activity logs for this machine yet.'
                : 'No logs yet. Add waste or submit a report to get started!',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey, fontSize: 13),
          ),
        );
      }
    } else {
      // Filter logs by machine if focusedMachineId is provided
      final filteredLogs = widget.focusedMachineId != null
          ? _allLogs.where((log) => log.machineId == widget.focusedMachineId).toList()
          : _allLogs;

      if (filteredLogs.isEmpty && widget.focusedMachineId != null) {
        return const Center(
          child: Text(
            'No activity logs for this machine yet.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, fontSize: 13),
          ),
        );
      }

      return SizedBox(
        height: 140,
        child: ListView.builder(
          itemCount: filteredLogs.length,
          physics: const BouncingScrollPhysics(),
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: ActivityLogItem(log: filteredLogs[index]),
            );
          },
        ),
      );
    }
  }
}