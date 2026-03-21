// lib/ui/reports/dialogs/report_edit_details_dialog.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../data/models/report.dart';
import '../../core/widgets/dialog/base_dialog.dart';
import '../../core/widgets/dialog/dialog_action.dart';
import '../../core/widgets/dialog/dialog_fields.dart';
import '../../core/widgets/dialog/web_confirmation_dialog.dart';
import '../../core/ui/app_snackbar.dart';

class ReportEditDetailsDialog extends StatefulWidget {
  final Report report;
  final Future<void> Function({
    required String machineId,
    required String reportId,
    String? title,
    String? description,
    String? status,
    String? priority,
  }) onUpdate;

  const ReportEditDetailsDialog({
    super.key,
    required this.report,
    required this.onUpdate,
  });

  @override
  State<ReportEditDetailsDialog> createState() =>
      _ReportEditDetailsDialogState();
}

class _ReportEditDetailsDialogState extends State<ReportEditDetailsDialog> {
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late String _selectedStatus;
  late String _selectedPriority;

  bool _isSubmitting = false;
  String? _titleError;
  String? _descriptionError;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.report.title);
    _descriptionController = TextEditingController(text: widget.report.description);
    _selectedStatus = widget.report.status;
    _selectedPriority = widget.report.priority;

    _titleController.addListener(_validateTitle);
    _descriptionController.addListener(_validateDescription);
  }

  @override
  void dispose() {
    _titleController.removeListener(_validateTitle);
    _descriptionController.removeListener(_validateDescription);
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // ── Derived helpers
  bool get _hasChanges =>
      _titleController.text.trim() != widget.report.title ||
      _descriptionController.text.trim() != widget.report.description ||
      _selectedStatus != widget.report.status ||
      _selectedPriority != widget.report.priority;

  // ── Live validation listeners
  void _validateTitle() {
    setState(() {
      _titleError = _titleController.text.trim().isEmpty ? 'Title is required' : null;
    });
  }

  void _validateDescription() {
    setState(() {
      _descriptionError = _descriptionController.text.trim().isEmpty
          ? 'Description is required'
          : null;
    });
  }

  // ── Cancel handler
  Future<void> _handleCancel() async {
    if (_hasChanges) {
      final result = await WebConfirmationDialog.show(
        context,
        title: 'Discard Changes',
        message: 'You have unsaved changes. Are you sure you want to discard them?',
        confirmLabel: 'Discard',
        cancelLabel: 'Keep Editing',
        confirmIsDestructive: true,
      );
      if (result == ConfirmResult.confirmed && context.mounted) {
        Navigator.of(context).pop();
      }
    } else {
      Navigator.of(context).pop();
    }
  }

  // ── Submit handler
  Future<void> _handleSubmit() async {
    _validateTitle();
    _validateDescription();

    if (_titleError != null || _descriptionError != null) return;

    final result = await WebConfirmationDialog.show(
      context,
      title: 'Update Report',
      message: 'Are you sure you want to save these changes?',
      confirmLabel: 'Update Report',
      cancelLabel: 'Go Back',
      confirmIsDestructive: false,
    );

    if (result != ConfirmResult.confirmed) return;
    if (!context.mounted) return;

    setState(() => _isSubmitting = true);

    try {
      await widget.onUpdate(
        machineId: widget.report.machineId,
        reportId: widget.report.id,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        status: _selectedStatus,
        priority: _selectedPriority,
      );

      if (!mounted) return;
      Navigator.of(context).pop();
      AppSnackbar.success(context, 'Report updated successfully');
    } catch (e) {
      if (!mounted) return;
      AppSnackbar.error(context, 'Failed to update: $e');
      setState(() => _isSubmitting = false);
    }
  }

  // ── Build
  @override
  Widget build(BuildContext context) {
    return BaseDialog(
      title: 'Edit Report',
      subtitle: 'Update report details',
      maxHeightFactor: 0.75,
      canClose: !_isSubmitting,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Title
          InputField(
            label: 'Title',
            controller: _titleController,
            hintText: 'Enter report title',
            errorText: _titleError,
            enabled: !_isSubmitting,
            required: true,
            maxLength: 100,
          ),
          const SizedBox(height: 16),

          // ── Description
          InputField(
            label: 'Description',
            controller: _descriptionController,
            hintText: 'Enter report description',
            errorText: _descriptionError,
            enabled: !_isSubmitting,
            required: true,
            maxLines: 4,
            maxLength: 500,
          ),
          const SizedBox(height: 16),

          // ── Status
          WebDropdownField<String>(
            label: 'Status',
            value: _selectedStatus,
            items: const [
              DropdownItem(value: 'open', label: 'Open'),
              DropdownItem(value: 'in_progress', label: 'In Progress'),
              DropdownItem(value: 'completed', label: 'Completed'),
              DropdownItem(value: 'on_hold', label: 'On Hold'),
            ],
            enabled: !_isSubmitting,
            required: true,
            onChanged: (value) => setState(() => _selectedStatus = value!),
          ),
          const SizedBox(height: 16),

          // ── Priority
          WebDropdownField<String>(
            label: 'Priority',
            value: _selectedPriority,
            items: const [
              DropdownItem(value: 'high', label: 'High'),
              DropdownItem(value: 'medium', label: 'Medium'),
              DropdownItem(value: 'low', label: 'Low'),
            ],
            enabled: !_isSubmitting,
            required: true,
            onChanged: (value) => setState(() => _selectedPriority = value!),
          ),
          const SizedBox(height: 24),

          // ── Read-only info
          ReadOnlySection(
            sectionTitle: 'Additional Information',
            fields: [
              ReadOnlyField(
                label: 'Category',
                value: widget.report.reportTypeLabel,
              ),
              ReadOnlyField(
                label: 'Machine Name',
                value: widget.report.machineName,
              ),
              ReadOnlyField(
                label: 'Submitted By',
                value: widget.report.userName,
              ),
              ReadOnlyField(
                label: 'Date Added',
                value: DateFormat('MM/dd/yyyy, hh:mm a').format(widget.report.createdAt),
              ),
            ],
          ),
        ],
      ),
      actions: [
        // ── Cancel
        DialogAction.secondary(
          label: 'Cancel',
          onPressed: _isSubmitting ? null : _handleCancel,
        ),

        // ── Submit
        DialogAction.primary(
          label: 'Update Report',
          onPressed: _handleSubmit,
          isLoading: _isSubmitting,
          isDisabled: !_hasChanges || _titleError != null || _descriptionError != null,
        ),
      ],
    );
  }
}