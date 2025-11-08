// lib/frontend/operator/activity_logs/web/web_alerts_section.dart
import 'package:flutter/material.dart';
import '../../../../services/firestore_activity_service.dart';
import '../models/activity_item.dart';
import 'package:intl/intl.dart';

class WebAlertsSection extends StatefulWidget {
  final String? viewingOperatorId;
  final VoidCallback? onViewAll;
  final String? focusedMachineId;

  const WebAlertsSection({
    super.key,
    this.viewingOperatorId,
    this.onViewAll,
    this.focusedMachineId,
  });

  @override
  State<WebAlertsSection> createState() => _WebAlertsSectionState();
}

class _WebAlertsSectionState extends State<WebAlertsSection> {
  bool _isLoading = true;
  List<ActivityItem> _alerts = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadAlerts();
  }

  Future<void> _loadAlerts() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final alerts = await FirestoreActivityService.getAlerts(
        viewingOperatorId: widget.viewingOperatorId,
      );

      // Filter by machine if focusedMachineId is provided
      final filteredAlerts = widget.focusedMachineId != null
          ? alerts.where((a) => a.machineId == widget.focusedMachineId).toList()
          : alerts;

      setState(() {
        _alerts = filteredAlerts.take(5).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final diff = now.difference(timestamp);

    if (diff.inDays == 0) {
      return DateFormat('h:mm a').format(timestamp);
    } else if (diff.inDays == 1) {
      return 'Yesterday';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} days ago';
    } else {
      return DateFormat('MMM d').format(timestamp);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color.fromARGB(255, 243, 243, 243), width: 1),
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.all(32),
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage != null) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color.fromARGB(255, 243, 243, 243), width: 1),
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.all(16),
        child: Text('Error: $_errorMessage', style: const TextStyle(color: Colors.red)),
      );
    }
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
                const Icon(Icons.warning, color: Colors.orange, size: 20),
                const SizedBox(width: 12),
                // ✅ Title text: explicitly black
                const Text(
                  'Recent Alerts',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black, // 🔲 Explicit black text
                  ),
                ),
                if (widget.onViewAll != null) ...[
                  const Spacer(),
                  TextButton(
                    onPressed: widget.onViewAll,
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
          
          if (_alerts.isEmpty)
            const Padding(
              padding: EdgeInsets.all(32),
              child: Center(
                child: Text(
                  'No recent alerts',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _alerts.length,
              itemBuilder: (context, index) {
                final alert = _alerts[index];
                final color = alert.statusColorValue;
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  title: Text(
                    alert.title,
                    style: const TextStyle(fontSize: 14, color: Color.fromARGB(255, 48, 47, 47)),
                  ),
                  subtitle: Text(
                    '${_formatTime(alert.timestamp)} • ${alert.value}',
                    style: const TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: color),
                    ),
                    child: Text(
                      alert.category,
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}