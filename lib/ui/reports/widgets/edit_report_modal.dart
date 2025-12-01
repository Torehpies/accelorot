import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../data/models/report_model.dart';
import '../view_model/reports_notifier.dart';

class EditReportModal extends ConsumerStatefulWidget {
  final ReportModel report;

  const EditReportModal({
    super.key,
    required this.report,
  });

  @override
  ConsumerState<EditReportModal> createState() => _EditReportModalState();
}

class _EditReportModalState extends ConsumerState<EditReportModal> {
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late String _selectedStatus;
  late String _selectedPriority;
  bool _isSubmitting = false;

  final List<Map<String, String>> _statusOptions = [
    {'value': 'open', 'label': 'Open'},
    {'value': 'in_progress', 'label': 'In Progress'},
    {'value': 'closed', 'label': 'Closed'},
  ];

  final List<Map<String, String>> _priorityOptions = [
    {'value': 'high', 'label': 'High'},
    {'value': 'medium', 'label': 'Medium'},
    {'value': 'low', 'label': 'Low'},
  ];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.report.title);
    _descriptionController = TextEditingController(
      text: widget.report.description,
    );
    _selectedStatus = widget.report.status;
    _selectedPriority = widget.report.priority;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  InputDecoration _buildInputDecoration(String labelText, {bool readOnly = false}) {
    return InputDecoration(
      labelText: labelText,
      labelStyle: TextStyle(color: readOnly ? Colors.grey[400] : Colors.grey),
      floatingLabelStyle: TextStyle(
        color: readOnly ? Colors.grey[400] : Colors.teal,
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: readOnly ? Colors.grey[300]! : Colors.teal,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: readOnly ? Colors.grey[300]! : Colors.grey,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      filled: readOnly,
      fillColor: readOnly ? Colors.grey[100] : null,
    );
  }

  Future<void> _handleSubmit() async {
    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();

    if (title.isEmpty) {
      _showSnackBar('Title is required', Colors.orange);
      return;
    }

    if (description.isEmpty) {
      _showSnackBar('Description is required', Colors.orange);
      return;
    }

    // Check if anything changed
    if (title == widget.report.title &&
        description == widget.report.description &&
        _selectedStatus == widget.report.status &&
        _selectedPriority == widget.report.priority) {
      _showSnackBar('No changes detected', Colors.blue);
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      await ref.read(reportsProvider.notifier).updateReport(
            machineId: widget.report.machineId,
            reportId: widget.report.reportId,
            title: title,
            description: description,
            status: _selectedStatus,
            priority: _selectedPriority,
          );

      if (!mounted) return;
      Navigator.of(context).pop();
      _showSnackBar('Report updated successfully', Colors.green);
    } catch (e) {
      if (!mounted) return;
      _showSnackBar('Failed to update report: $e', Colors.red);
      setState(() => _isSubmitting = false);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        20,
        20,
        MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Edit Report',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const Text(
              'Update report details',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 20),

            // Title
            TextField(
              controller: _titleController,
              decoration: _buildInputDecoration('Title *'),
              enabled: !_isSubmitting,
            ),
            const SizedBox(height: 16),

            // Description
            TextField(
              controller: _descriptionController,
              decoration: _buildInputDecoration('Description *'),
              enabled: !_isSubmitting,
              maxLines: 3,
            ),
            const SizedBox(height: 16),

            // Status
            DropdownButtonFormField<String>(
              value: _selectedStatus,
              decoration: _buildInputDecoration('Status *'),
              items: _statusOptions.map((option) {
                return DropdownMenuItem(
                  value: option['value'],
                  child: Text(option['label']!),
                );
              }).toList(),
              onChanged: _isSubmitting
                  ? null
                  : (value) => setState(() => _selectedStatus = value!),
            ),
            const SizedBox(height: 16),

            // Priority
            DropdownButtonFormField<String>(
              value: _selectedPriority,
              decoration: _buildInputDecoration('Priority *'),
              items: _priorityOptions.map((option) {
                return DropdownMenuItem(
                  value: option['value'],
                  child: Text(option['label']!),
                );
              }).toList(),
              onChanged: _isSubmitting
                  ? null
                  : (value) => setState(() => _selectedPriority = value!),
            ),
            const SizedBox(height: 16),

            // Machine (Read-only)
            TextField(
              controller: TextEditingController(
                text: widget.report.machineName ?? widget.report.machineId,
              ),
              decoration: _buildInputDecoration('Machine', readOnly: true),
              enabled: false,
            ),
            const SizedBox(height: 16),

            // Reported By (Read-only)
            TextField(
              controller: TextEditingController(text: widget.report.userName),
              decoration: _buildInputDecoration('Reported By', readOnly: true),
              enabled: false,
            ),
            const SizedBox(height: 16),

            // Created At (Read-only)
            TextField(
              controller: TextEditingController(
                text: DateFormat('MM/dd/yyyy, hh:mm a')
                    .format(widget.report.createdAt),
              ),
              decoration: _buildInputDecoration('Created At', readOnly: true),
              enabled: false,
            ),
            const SizedBox(height: 24),

            // Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isSubmitting
                        ? null
                        : () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[300],
                      foregroundColor: Colors.teal,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _handleSubmit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text('Update Report'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}