// lib/ui/activity_logs/bottom_sheets/mobile_report_detail_sheet.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../data/models/report.dart';
import '../../core/widgets/bottom_sheets/mobile_bottom_sheet_base.dart';
import '../../core/widgets/bottom_sheets/mobile_bottom_sheet_buttons.dart';
import '../../core/widgets/bottom_sheets/fields/mobile_readonly_field.dart';
import '../../core/widgets/bottom_sheets/fields/mobile_readonly_section.dart';

class MobileReportDetailSheet extends StatelessWidget {
  final Report report;

  const MobileReportDetailSheet({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    return MobileBottomSheetBase(
      title: report.title,
      subtitle: 'Report Details',
      actions: [
        BottomSheetAction.secondary(
          label: 'Close',
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
      body: MobileReadOnlySection(
        fields: [
          MobileReadOnlyField(
            label: 'Report Type',
            value: report.reportTypeLabel,
          ),
          MobileReadOnlyField(
            label: 'Priority Level',
            value: report.priorityLabel,
          ),
          MobileReadOnlyField(
            label: 'Status',
            value: report.statusLabel,
          ),
          MobileReadOnlyField(
            label: 'Submitted By',
            value: '${report.userName} (${report.userRole})',
          ),
          MobileReadOnlyField(
            label: 'Machine Name',
            value: report.machineName,
          ),
          MobileReadOnlyField(
            label: 'Description',
            value: report.description,
          ),
          MobileReadOnlyField(
            label: 'Date Added',
            value: DateFormat('MM/dd/yyyy, hh:mm a').format(report.createdAt),
          ),
          if (report.resolvedAt != null)
            MobileReadOnlyField(
              label: 'Resolved At',
              value: DateFormat(
                'MM/dd/yyyy, hh:mm a',
              ).format(report.resolvedAt!),
            ),
          if (report.resolvedBy != null)
            MobileReadOnlyField(
              label: 'Resolved By',
              value: report.resolvedBy!,
            ),
        ],
      ),
    );
  }
}