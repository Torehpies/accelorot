// lib/ui/reports/bottom_sheets/report_edit_bottom_sheet.dart

import 'package:flutter/material.dart';
import '../../../data/models/report.dart';
import '../../core/bottom_sheet/mobile_bottom_sheet_base.dart';
import '../../core/bottom_sheet/fields/mobile_readonly_field.dart';
import '../../core/bottom_sheet/fields/mobile_readonly_section.dart';
import '../../core/bottom_sheet/fields/mobile_input_field.dart';
import '../../core/bottom_sheet/fields/mobile_dropdown_field.dart';
import '../../core/dialog/mobile_confirmation_dialog.dart';
import '../../core/toast/mobile_toast_service.dart';
import '../../core/toast/toast_type.dart';

/// Callback signature matching [MobileReportsViewModel.updateReport].
typedef UpdateReportCallback = Future<void> Function({
  required String machineId,
  required String reportId,
  String? title,
  String? description,
  String? status,
  String? priority,
});

/// Editable form for an existing report.
///
/// • Readonly fields: ID, machine, creator (cannot change).
/// • Editable fields: title, description, status, priority.
/// • Tracks [_hasChanges] → shows confirmation dialog on Cancel.
/// • Drag and dismiss disabled to prevent accidental data loss.
/// • Shows toast on save success / error.
class ReportEditBottomSheet extends StatefulWidget {
  final Report report;
  final UpdateReportCallback onUpdate;

  const ReportEditBottomSheet({
    super.key,
    required this.report,
    required this.onUpdate,
  });

  @override
  State<ReportEditBottomSheet> createState() => _ReportEditBottomSheetState();
}

class _ReportEditBottomSheetState extends State<ReportEditBottomSheet> {
  // ---------------------------------------------------------------------------
  // Controllers & editable state
  // ---------------------------------------------------------------------------
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late String _status;
  late String _priority;

  bool _isLoading = false;
  String? _titleError;

  // ---------------------------------------------------------------------------
  // Init / dispose
  // ---------------------------------------------------------------------------
  @override
  void initState() {
    super.initState();
    _titleController =
        TextEditingController(text: widget.report.title);
    _descriptionController =
        TextEditingController(text: widget.report.description);
    _status = widget.report.status;
    _priority = widget.report.priority;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Dirty check
  // ---------------------------------------------------------------------------
  bool get _hasChanges {
    return _titleController.text.trim() != widget.report.title.trim() ||
        _descriptionController.text.trim() != widget.report.description.trim() ||
        _status != widget.report.status ||
        _priority != widget.report.priority;
  }

  // ---------------------------------------------------------------------------
  // Validation
  // ---------------------------------------------------------------------------
  bool _validate() {
    setState(() => _titleError = null);

    if (_titleController.text.trim().isEmpty) {
      setState(() => _titleError = 'Title cannot be empty');
      return false;
    }
    return true;
  }

  // ---------------------------------------------------------------------------
  // Actions
  // ---------------------------------------------------------------------------
  Future<void> _save() async {
    if (!_validate()) return;

    setState(() => _isLoading = true);

    try {
      await widget.onUpdate(
        machineId: widget.report.machineId,
        reportId: widget.report.id,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        status: _status,
        priority: _priority,
      );

      if (mounted) {
        MobileToastService.show(
          context,
          message: 'Report updated successfully',
          type: ToastType.success,
        );
        // Small delay so the toast is visible before the sheet closes
        await Future.delayed(const Duration(milliseconds: 600));
        if (mounted) Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        MobileToastService.show(
          context,
          message: 'Failed to update report',
          type: ToastType.error,
        );
      }
    }
  }

  Future<void> _cancel() async {
    if (_hasChanges) {
      final result = await MobileConfirmationDialog.show(context);
      if (result == ConfirmResult.confirmed && mounted) {
        Navigator.of(context).pop();
      }
      // cancelled → stay on the sheet
    } else {
      Navigator.of(context).pop();
    }
  }

  // ---------------------------------------------------------------------------
  // Dropdown item lists
  // ---------------------------------------------------------------------------
  static const List<MobileDropdownItem<String>> _statusItems = [
    MobileDropdownItem(value: 'open', label: 'Open'),
    MobileDropdownItem(value: 'in_progress', label: 'In Progress'),
    MobileDropdownItem(value: 'completed', label: 'Completed'),
    MobileDropdownItem(value: 'on_hold', label: 'On Hold'),
  ];

  static const List<MobileDropdownItem<String>> _priorityItems = [
    MobileDropdownItem(value: 'high', label: 'High'),
    MobileDropdownItem(value: 'medium', label: 'Medium'),
    MobileDropdownItem(value: 'low', label: 'Low'),
  ];

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return MobileBottomSheetBase(
      title: 'Edit Report',
      showCloseButton: false,      // use Cancel button instead
      actions: [
        BottomSheetAction.secondary(
          label: 'Cancel',
          onPressed: _isLoading ? null : _cancel,
        ),
        BottomSheetAction.primary(
          label: 'Save',
          onPressed: _isLoading ? null : _save,
          isLoading: _isLoading,
        ),
      ],
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Readonly identity ──────────────────────────────────────────
          MobileReadOnlySection(
            sectionTitle: 'Identity',
            fields: [
              MobileReadOnlyField(label: 'Report ID', value: widget.report.id),
              MobileReadOnlyField(label: 'Machine', value: widget.report.machineName),
              MobileReadOnlyField(label: 'Created by', value: widget.report.userName),
            ],
          ),
          const SizedBox(height: 20),

          // ── Editable: Title ────────────────────────────────────────────
          MobileInputField(
            label: 'Title',
            controller: _titleController,
            required: true,
            errorText: _titleError,
            hintText: 'Enter report title',
          ),
          const SizedBox(height: 16),

          // ── Editable: Description ──────────────────────────────────────
          MobileInputField(
            label: 'Description',
            controller: _descriptionController,
            maxLines: 4,
            hintText: 'Describe the issue…',
          ),
          const SizedBox(height: 16),

          // ── Editable: Status & Priority row ────────────────────────────
          Row(
            children: [
              Expanded(
                child: MobileDropdownField<String>(
                  label: 'Status',
                  value: _status,
                  items: _statusItems,
                  required: true,
                  onChanged: (v) {
                    if (v != null) setState(() => _status = v);
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: MobileDropdownField<String>(
                  label: 'Priority',
                  value: _priority,
                  items: _priorityItems,
                  required: true,
                  onChanged: (v) {
                    if (v != null) setState(() => _priority = v);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // ── Readonly: type (cannot change) ─────────────────────────────
          MobileReadOnlySection(
            sectionTitle: 'Report Type',
            fields: [
              MobileReadOnlyField(label: 'Type', value: widget.report.reportTypeLabel),
            ],
          ),
        ],
      ),
    );
  }
}