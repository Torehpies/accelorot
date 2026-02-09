// lib/ui/reports/bottom_sheets/report_view_bottom_sheet.dart

import 'package:flutter/material.dart';
import '../../../data/models/report.dart';
import '../../core/bottom_sheet/mobile_bottom_sheet_base.dart';
import '../../core/bottom_sheet/mobile_bottom_sheet_buttons.dart';
import '../../core/bottom_sheet/fields/mobile_readonly_field.dart';
import '../../core/bottom_sheet/fields/mobile_readonly_section.dart';

class ReportViewBottomSheet extends StatelessWidget {
  final Report report;
  final VoidCallback onEdit;

  const ReportViewBottomSheet({
    super.key,
    required this.report,
    required this.onEdit,
  });

  // Date and time formatting helper
  String _formatDateTime(DateTime dt) {
    final months = [
      'Jan','Feb','Mar','Apr','May','Jun',
      'Jul','Aug','Sep','Oct','Nov','Dec',
    ];
    final h = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
    final ampm = dt.hour >= 12 ? 'PM' : 'AM';
    final min = dt.minute.toString().padLeft(2, '0');
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year}  $h:$min $ampm';
  }

  @override
  Widget build(BuildContext context) {
    return MobileBottomSheetBase(
      title: report.title,
      subtitle: 'Report Details',
      actions: [
        BottomSheetAction.primary(
          label: 'Edit',
          onPressed: onEdit,
        ),
      ],
      body: MobileReadOnlySection(
        sectionTitle: null,
        fields: [
          MobileReadOnlyField(label: 'Report ID', value: report.id),
          MobileReadOnlyField(label: 'Machine', value: report.machineName),
          MobileReadOnlyField(label: 'Machine ID', value: report.machineId),
          MobileReadOnlyField(label: 'Type', value: report.reportTypeLabel),
          MobileReadOnlyField(label: 'Priority', value: report.priorityLabel),
          MobileReadOnlyField(label: 'Status', value: report.statusLabel),
          MobileReadOnlyField(label: 'Description', value: report.description),
          MobileReadOnlyField(label: 'Created by', value: report.userName),
          MobileReadOnlyField(
            label: 'Created at',
            value: _formatDateTime(report.createdAt),
          ),
          if (report.updatedAt != null)
            MobileReadOnlyField(
              label: 'Updated at',
              value: _formatDateTime(report.updatedAt!),
            ),
          if (report.resolvedAt != null) ...[
            MobileReadOnlyField(
              label: 'Resolved at',
              value: _formatDateTime(report.resolvedAt!),
            ),
            MobileReadOnlyField(
              label: 'Resolved by',
              value: report.resolvedBy ?? '—',
            ),
          ],
        ],
      ),
    );
  }
}