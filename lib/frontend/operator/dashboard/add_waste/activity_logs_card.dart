import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../services/firestore_activity_service.dart';
import '../../activity_logs/models/activity_item.dart';
import 'widgets/activity_log_item.dart';

class ActivityLogsCard extends StatefulWidget {
  const ActivityLogsCard({super.key});

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

  // Public method for parent to trigger refresh
  Future<void> refresh() async {
    await _fetchAllLogs();
  }

  Future<void> _fetchAllLogs() async {
    // Check if user is logged in
    final user = FirebaseAuth.instance.currentUser;
    
    if (user == null) {
      // User not logged in - show login message
      if (mounted) {
        setState(() {
          _loading = false;
          _logsFetchError = true;
          _allLogs.clear();
        });
      }
      return;
    }

    // User is logged in - fetch data
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
            // Card header (always rendered)
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
            // Card body - always inside card border
            _buildCardBody(),
          ],
        ),
      ),
    );
  }

  Widget _buildCardBody() {
    // Ensure card always keeps its padding and border
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    } else if (_logsFetchError || _allLogs.isEmpty) {
      // Check if user is logged in to show appropriate message
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
        height: 140, // fits ~2 logs, scrollable area
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