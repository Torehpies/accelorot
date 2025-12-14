// lib/frontend/operator/dashboard/add_waste/activity_logs_card.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../services/firestore_activity_service.dart';
import '../../../../frontend/operator/activity_logs/models/activity_item.dart';
import '../activity_log/activity_log_item.dart';

class ActivityLogsCard extends StatefulWidget {
  final String? focusedMachineId;
  final double?
  maxHeight; // 👈 Optional: constrain height (mobile), or leave infinite (web)

  const ActivityLogsCard({super.key, this.focusedMachineId, this.maxHeight});

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
    // On web, we don't want the outer Card — it's already inside a white container
    // But we keep it for mobile compatibility
    final isWeb = widget.maxHeight == null;

    if (isWeb) {
      // Web: just return the body directly (no Card, no padding)
      return _buildCardBody();
    } else {
      // Mobile: original styled card
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
      final filteredLogs = widget.focusedMachineId != null
          ? _allLogs
                .where((log) => log.machineId == widget.focusedMachineId)
                .toList()
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

      // ✅ Web: no height constraint → fills available space
      // ✅ Mobile: constrained by maxHeight (e.g., 140)
      Widget listView = ListView.builder(
        itemCount: filteredLogs.length,
        physics: const ClampingScrollPhysics(), // Better for web
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: ActivityLogItem(log: filteredLogs[index]),
          );
        },
      );

      if (widget.maxHeight != null) {
        return SizedBox(height: widget.maxHeight, child: listView);
      } else {
        // Web: let it expand naturally inside a scrollable parent
        return listView;
      }
    }
  }
}
