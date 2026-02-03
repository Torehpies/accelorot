// lib/ui/reports/bottom_sheets/report_view_bottom_sheet.dart

import 'package:flutter/material.dart';
import '../../../data/models/report.dart';
import '../../core/bottom_sheet/mobile_bottom_sheet_base.dart';
import '../../core/bottom_sheet/fields/mobile_readonly_field.dart';
import '../../core/bottom_sheet/fields/mobile_readonly_section.dart';

/// Read-only view of a single report
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

  // Build
  @override
  Widget build(BuildContext context) {
    return MobileBottomSheetBase(
      title: 'Report Details',
      actions: [
        BottomSheetAction.primary(
          label: 'Edit',
          onPressed: onEdit,
        ),
      ],
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Identity
          MobileReadOnlySection(
            sectionTitle: 'Identity',
            fields: [
              MobileReadOnlyField(label: 'Report ID', value: report.id),
              MobileReadOnlyField(label: 'Machine', value: report.machineName),
              MobileReadOnlyField(label: 'Machine ID', value: report.machineId),
            ],
          ),
          const SizedBox(height: 16),

          // Details
          MobileReadOnlySection(
            sectionTitle: 'Details',
            fields: [
              MobileReadOnlyField(label: 'Title', value: report.title),
              MobileReadOnlyField(label: 'Type', value: report.reportTypeLabel),
              MobileReadOnlyField(label: 'Priority', value: report.priorityLabel),
              MobileReadOnlyField(label: 'Status', value: report.statusLabel),
            ],
          ),
          const SizedBox(height: 16),

          // Description
          MobileReadOnlySection(
            sectionTitle: 'Description',
            fields: [
              // Full-width text block
              _DescriptionBlock(text: report.description),
            ],
          ),
          const SizedBox(height: 16),

          // Meta
          MobileReadOnlySection(
            sectionTitle: 'Meta',
            fields: [
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
        ],
      ),
    );
  }
}

class _DescriptionBlock extends StatelessWidget {
  final String text;

  // ignore: unused_element_parameter
  const _DescriptionBlock({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    final isEmpty = text.trim().isEmpty;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Text(
        isEmpty ? '—' : text,
        style: TextStyle(
          fontFamily: 'dm-sans',
          fontSize: 14,
          color: isEmpty
              ? const Color(0xFF9CA3AF) // muted
              : const Color(0xFF374151),
          height: 1.6,
        ),
      ),
    );
  }
}