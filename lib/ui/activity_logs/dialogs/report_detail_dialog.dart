// lib/ui/activity_logs/dialogs/report_detail_dialog.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../data/models/report.dart';
import '../../core/dialog/base_dialog.dart';
import '../../core/dialog/dialog_action.dart';
import '../../core/dialog/dialog_fields.dart';

class ReportDetailDialog extends StatelessWidget {
  final Report report;

  const ReportDetailDialog({
    super.key,
    required this.report,
  });

  @override
  Widget build(BuildContext context) {
    return BaseDialog(
      title: 'View Report',
      subtitle: 'View in-depth information about this report.',
      maxHeightFactor: 0.7,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ReadOnlyField(label: 'Title:', value: report.title),
          const SizedBox(height: 16),
          
          ReadOnlyField(label: 'Report Type:', value: report.reportTypeLabel),
          const SizedBox(height: 16),
          
          ReadOnlyField(label: 'Priority Level:', value: report.priorityLabel),
          const SizedBox(height: 16),
          
          ReadOnlyField(label: 'Status:', value: report.statusLabel),
          const SizedBox(height: 16),
          
          ReadOnlyField(
            label: 'Submitted By:', 
            value: '${report.userName} (${report.userRole})',
          ),
          const SizedBox(height: 16),
          
          ReadOnlyField(label: 'Machine Name:', value: report.machineName),
          const SizedBox(height: 16),
          
          ReadOnlyMultilineField(
            label: 'Description:',
            value: report.description,
          ),
          const SizedBox(height: 16),
          
          ReadOnlyField(
            label: 'Date Created:',
            value: DateFormat('MM/dd/yyyy, hh:mm a').format(report.createdAt),
          ),
          
          // Show resolution info if resolved
          if (report.resolvedAt != null) ...[
            const SizedBox(height: 16),
            ReadOnlyField(
              label: 'Resolved At:',
              value: DateFormat('MM/dd/yyyy, hh:mm a').format(report.resolvedAt!),
            ),
          ],
          
          if (report.resolvedBy != null) ...[
            const SizedBox(height: 16),
            ReadOnlyField(label: 'Resolved By:', value: report.resolvedBy!),
          ],
        ],
      ),
      actions: [
        DialogAction.secondary(
          label: 'Close',
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }
}