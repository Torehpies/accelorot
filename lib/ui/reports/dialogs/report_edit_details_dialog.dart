// lib/ui/reports/dialogs/report_edit_details_dialog.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../data/models/report.dart';
import '../../core/dialog/base_dialog.dart';
import '../../core/dialog/dialog_action.dart';
import '../../core/dialog/dialog_fields.dart';
import '../../core/dialog/toast_service.dart';

class ReportEditDetailsDialog extends StatefulWidget {
  final Report report;
  final Future<void> Function({
    required String machineId,
    required String reportId,
    String? title,
    String? description,
    String? status,
    String? priority,
  })
  onUpdate;

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
    _descriptionController = TextEditingController(
      text: widget.report.description,
    );
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

  void _validateTitle() {
    setState(() {
      final title = _titleController.text.trim();
      if (title.isEmpty) {
        _titleError = 'Title is required';
      } else {
        _titleError = null;
      }
    });
  }

  void _validateDescription() {
    setState(() {
      final description = _descriptionController.text.trim();
      if (description.isEmpty) {
        _descriptionError = 'Description is required';
      } else {
        _descriptionError = null;
      }
    });
  }

  Future<void> _handleSubmit() async {
    // Validate both fields
    _validateTitle();
    _validateDescription();

    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();

    // Stop if validation errors
    if (_titleError != null || _descriptionError != null) {
      return;
    }

    // Check if anything changed
    if (title == widget.report.title &&
        description == widget.report.description &&
        _selectedStatus == widget.report.status &&
        _selectedPriority == widget.report.priority) {
      if (!mounted) return;
      ToastService.show(context, message: 'No changes detected');
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      await widget.onUpdate(
        machineId: widget.report.machineId,
        reportId: widget.report.id,
        title: title,
        description: description,
        status: _selectedStatus,
        priority: _selectedPriority,
      );

      if (!mounted) return;
      Navigator.of(context).pop();
      ToastService.show(context, message: 'Report updated successfully');
    } catch (e) {
      if (!mounted) return;
      ToastService.show(context, message: 'Failed to update: $e');
      setState(() => _isSubmitting = false);
    }
  }

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
          // Editable: Title
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

          // Editable: Description
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

          // Editable: Status
          DropdownField<String>(
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

          // Editable: Priority
          DropdownField<String>(
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

          // Read-only section
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
                value: DateFormat(
                  'MM/dd/yyyy, hh:mm a',
                ).format(widget.report.createdAt),
              ),
            ],
          ),
        ],
      ),
      actions: [
        DialogAction.secondary(
          label: 'Cancel',
          onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
        ),
        DialogAction.primary(
          label: 'Update Report',
          onPressed:
              _titleError == null && _descriptionError == null && !_isSubmitting
              ? _handleSubmit
              : null,
          isLoading: _isSubmitting,
        ),
      ],
    );
  }
}
