// lib/frontend/operator/activity_logs/web/web_reports_section.dart
import 'package:flutter/material.dart';
import '../../../../services/firestore_activity_service.dart';
import '../../../../data/models/activity_item.dart';

class WebReportsSection extends StatefulWidget {
  final String? viewingOperatorId;
  final VoidCallback? onViewAll;
  final String? focusedMachineId;

  const WebReportsSection({
    super.key,
    this.viewingOperatorId,
    this.onViewAll,
    this.focusedMachineId,
  });

  @override
  State<WebReportsSection> createState() => _WebReportsSectionState();
}

class _WebReportsSectionState extends State<WebReportsSection> {
  bool _isLoading = true;
  List<ActivityItem> _reports = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  Future<void> _loadReports() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final reports = await FirestoreActivityService.getReports(
        viewingOperatorId: widget.viewingOperatorId,
      );

      // Filter by machine if focusedMachineId is provided
      final filteredReports = widget.focusedMachineId != null
          ? reports.where((r) => r.machineId == widget.focusedMachineId).toList()
          : reports;

      setState(() {
        _reports = filteredReports.take(3).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
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
                const Icon(Icons.report_outlined, color: Colors.deepPurple, size: 20),
                const SizedBox(width: 12),
                const Text(
                  'Reports',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
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
          
          if (_reports.isEmpty)
            Padding(
              padding: const EdgeInsets.all(32),
              child: Center(
                child: Text(
                  'No reports yet',
                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                ),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _reports.length,
              itemBuilder: (context, index) {
                final report = _reports[index];
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  leading: CircleAvatar(
                    radius: 16,
                    backgroundColor: _getReportColor(report.reportType),
                    child: Icon(
                      report.icon,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                  title: Text(
                    report.title,
                    style: const TextStyle(fontSize: 14, color: Color.fromARGB(255, 48, 47, 47)),
                  ),
                  subtitle: Text(
                    report.formattedTimestamp,
                    style: const TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: report.statusColorValue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      report.value,
                      style: TextStyle(
                        color: report.statusColorValue,
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

  Color _getReportColor(String? reportType) {
    switch (reportType?.toLowerCase()) {
      case 'maintenance issue':
        return Colors.blue;
      case 'observation':
        return Colors.green;
      case 'safety concern':
        return Colors.red;
      default:
        return Colors.deepPurple;
    }
  }
}