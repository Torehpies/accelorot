// lib/ui/reports/bottom_sheets/report_edit_bottom_sheet.dart

import 'package:flutter/material.dart';
import '../../../data/models/report.dart';
import '../../core/widgets/bottom_sheets/mobile_bottom_sheet_base.dart';
import '../../core/widgets/bottom_sheets/mobile_bottom_sheet_buttons.dart';
import '../../core/widgets/bottom_sheets/fields/mobile_readonly_field.dart';
import '../../core/widgets/bottom_sheets/fields/mobile_readonly_section.dart';
import '../../core/widgets/bottom_sheets/fields/mobile_input_field.dart';
import '../../core/widgets/bottom_sheets/fields/mobile_dropdown_field.dart';
import '../../core/widgets/dialog/mobile_confirmation_dialog.dart';
import '../../core/ui/app_snackbar.dart';

typedef UpdateReportCallback = Future<void> Function({
  required String machineId,
  required String reportId,
  String? title,
  String? description,
  String? status,
  String? priority,
});

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
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late String _status;
  late String _priority;

  bool _isLoading = false;
  String? _titleError;

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

  bool get _hasChanges {
    return _titleController.text.trim() != widget.report.title.trim() ||
        _descriptionController.text.trim() != widget.report.description.trim() ||
        _status != widget.report.status ||
        _priority != widget.report.priority;
  }

  bool _validate() {
    setState(() => _titleError = null);

    if (_titleController.text.trim().isEmpty) {
      setState(() => _titleError = 'Title cannot be empty');
      return false;
    }
    return true;
  }

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
        AppSnackbar.success(context, 'Report updated successfully');
        // Small delay so the snackbar is visible before the sheet closes
        await Future.delayed(const Duration(milliseconds: 600));
        if (mounted) Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        AppSnackbar.error(context, 'Failed to update report');
      }
    }
  }

  Future<void> _cancel() async {
    if (_hasChanges) {
      final result = await MobileConfirmationDialog.show(context);
      if (result == ConfirmResult.confirmed && mounted) {
        Navigator.of(context).pop();
      }
    } else {
      Navigator.of(context).pop();
    }
  }

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

  @override
  Widget build(BuildContext context) {
    return MobileBottomSheetBase(
      title: widget.report.title,
      subtitle: 'Edit Report',
      showCloseButton: false,
      actions: [
        BottomSheetAction.secondary(
          label: 'Cancel',
          onPressed: _cancel,
        ),
        BottomSheetAction.primary(
          label: 'Save',
          onPressed: _save,
          isLoading: _isLoading,
          isDisabled: !_hasChanges,
        ),
      ],
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          MobileInputField(
            label: 'Title',
            controller: _titleController,
            required: true,
            errorText: _titleError,
            hintText: 'Enter report title',
          ),
          const SizedBox(height: 16),

          MobileInputField(
            label: 'Description',
            controller: _descriptionController,
            maxLines: 4,
            hintText: 'Describe the issue…',
          ),
          const SizedBox(height: 16),

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
          const SizedBox(height: 24),

          MobileReadOnlySection(
            sectionTitle: 'Additional Information',
            fields: [
              MobileReadOnlyField(label: 'Report ID', value: widget.report.id),
              MobileReadOnlyField(label: 'Machine', value: widget.report.machineName),
              MobileReadOnlyField(label: 'Type', value: widget.report.reportTypeLabel),
              MobileReadOnlyField(label: 'Created by', value: widget.report.userName),
            ],
          ),
        ],
      ),
    );
  }
}