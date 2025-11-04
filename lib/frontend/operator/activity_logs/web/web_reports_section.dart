// lib/frontend/operator/activity_logs/web/web_reports_section.dart
import 'package:flutter/material.dart';
import '../../../../services/firestore_activity_service.dart';
import '../../activity_logs/models/activity_item.dart';

class WebReportsSection extends StatelessWidget {
  final String? viewingOperatorId;
  final VoidCallback? onViewAll;

  const WebReportsSection({
    super.key,
    this.viewingOperatorId,
    this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
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
                if (onViewAll != null) ...[
                  const Spacer(),
                  TextButton(
                    onPressed: onViewAll,
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
          
          // Fetch real data
          FutureBuilder<List<ActivityItem>>(
            future: FirestoreActivityService.getReports(
              viewingOperatorId: viewingOperatorId,
            ),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              if (snapshot.hasError) {
                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'Error loading reports',
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                  ),
                );
              }

              final reports = snapshot.data ?? [];
              
              if (reports.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.all(32),
                  child: Center(
                    child: Text(
                      'No reports yet',
                      style: TextStyle(color: Colors.grey[600], fontSize: 13),
                    ),
                  ),
                );
              }

              // Show only first 3 reports
              final previewReports = reports.take(3).toList();

              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: previewReports.length,
                itemBuilder: (context, index) {
                  final report = previewReports[index];
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