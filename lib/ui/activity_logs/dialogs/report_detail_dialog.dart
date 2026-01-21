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
          // All report information in one gray section
          ReadOnlySection(
            fields: [
              ReadOnlyField(
                label: 'Title',
                value: report.title,
              ),
              ReadOnlyField(
                label: 'Report Type',
                value: report.reportTypeLabel,
              ),
              ReadOnlyField(
                label: 'Priority Level',
                value: report.priorityLabel,
              ),
              ReadOnlyField(
                label: 'Status',
                value: report.statusLabel,
              ),
              ReadOnlyField(
                label: 'Submitted By',
                value: '${report.userName} (${report.userRole})',
              ),
              ReadOnlyField(
                label: 'Machine Name',
                value: report.machineName,
              ),
              
              // Description as multiline field
              ReadOnlyMultilineField(
                label: 'Description',
                value: report.description,
              ),
              
              // Date Created (Date Added)
              ReadOnlyField(
                label: 'Date Added',
                value: DateFormat('MM/dd/yyyy, hh:mm a').format(report.createdAt),
              ),
              
              // Resolution info (if resolved)
              if (report.resolvedAt != null)
                ReadOnlyField(
                  label: 'Resolved At',
                  value: DateFormat('MM/dd/yyyy, hh:mm a').format(report.resolvedAt!),
                ),
              if (report.resolvedBy != null)
                ReadOnlyField(
                  label: 'Resolved By',
                  value: report.resolvedBy!,
                ),
            ],
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
}