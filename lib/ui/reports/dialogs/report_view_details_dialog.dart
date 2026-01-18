// lib/ui/reports/dialogs/report_view_details_dialog.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../data/models/report.dart';
import '../../core/dialog/base_dialog.dart';
import '../../core/dialog/dialog_action.dart';
import '../../core/dialog/dialog_fields.dart';

class ReportViewDetailsDialog extends StatelessWidget {
  final Report report;

  const ReportViewDetailsDialog({
    super.key,
    required this.report,
  });

  @override
  Widget build(BuildContext context) {
    return BaseDialog(
      title: report.title,
      subtitle: 'Report Details',
      maxHeightFactor: 0.75,
      content: ReadOnlySection(
        fields: [
          ReadOnlyField(
            label: 'Category',
            value: report.reportTypeLabel,
          ),
          ReadOnlyField(
            label: 'Status',
            value: report.statusLabel,
          ),
          ReadOnlyField(
            label: 'Priority',
            value: _formatPriority(report.priority),
          ),
          ReadOnlyField(
            label: 'Machine Name',
            value: report.machineName,
          ),
          ReadOnlyField(
            label: 'Submitted By',
            value: report.userName,
          ),
          ReadOnlyField(
            label: 'Date Added',
            value: DateFormat('MM/dd/yyyy, hh:mm a').format(report.createdAt),
          ),
          if (report.updatedAt != null)
            ReadOnlyField(
              label: 'Last Modified',
              value: DateFormat('MM/dd/yyyy, hh:mm a').format(report.updatedAt!),
            ),
          ReadOnlyMultilineField(
            label: 'Description',
            value: report.description,
          ),
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

  String _formatPriority(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return 'High';
      case 'medium':
        return 'Medium';
      case 'low':
        return 'Low';
      default:
        return priority;
    }
  }
}