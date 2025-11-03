// lib/frontend/operator/machine_management/reports/widgets/edit_report_modal.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../controllers/reports_controller.dart';
import '../models/report_model.dart';

class EditReportModal extends StatefulWidget {
  final ReportsController controller;
  final ReportModel report;

  const EditReportModal({
    super.key,
    required this.controller,
    required this.report,
  });

  @override
  State<EditReportModal> createState() => _EditReportModalState();
}

class _EditReportModalState extends State<EditReportModal> {
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
    _descriptionController = TextEditingController(text: widget.report.description);
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
      floatingLabelStyle: TextStyle(color: readOnly ? Colors.grey[400] : Colors.teal),
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
    // Check authentication first
    if (!widget.controller.isAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠️ You must be logged in to edit reports'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();

    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Title is required')),
      );
      return;
    }

    if (description.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Description is required')),
      );
      return;
    }

    // Check if anything changed
    if (title == widget.report.title &&
        description == widget.report.description &&
        _selectedStatus == widget.report.status &&
        _selectedPriority == widget.report.priority) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No changes detected')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      await widget.controller.updateReport(
        machineId: widget.report.machineId,
        reportId: widget.report.reportId,
        title: title,
        description: description,
        status: _selectedStatus,
        priority: _selectedPriority,
      );

      if (!mounted) return;
      Navigator.of(context).pop(); // Close modal
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ Report "$title" updated successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      
      final errorMessage = e.toString().contains('logged in')
          ? 'You must be logged in to edit reports'
          : 'Failed to update report: $e';
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
      
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAuthenticated = widget.controller.isAuthenticated;

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
            Text(
              isAuthenticated
                  ? 'Update report details'
                  : 'You can preview the form, but must be logged in to save changes',
              style: TextStyle(
                color: isAuthenticated ? Colors.grey : Colors.orange.shade700,
                fontWeight: isAuthenticated ? FontWeight.normal : FontWeight.w500,
              ),
            ),
            const SizedBox(height: 20),
            
            // Title (Editable)
            TextField(
              controller: _titleController,
              style: const TextStyle(color: Colors.black),
              cursorColor: Colors.teal,
              decoration: _buildInputDecoration('Title *'),
              enabled: !_isSubmitting,
            ),
            const SizedBox(height: 16),
            
            // Description (Editable)
            TextField(
              controller: _descriptionController,
              style: const TextStyle(color: Colors.black),
              cursorColor: Colors.teal,
              decoration: _buildInputDecoration('Description *'),
              enabled: !_isSubmitting,
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            
            // Status Dropdown (Editable)
            DropdownButtonFormField<String>(
              value: _selectedStatus,
              decoration: _buildInputDecoration('Status *'),
              items: _statusOptions.map((option) {
                return DropdownMenuItem(
                  value: option['value'],
                  child: Text(option['label']!),
                );
              }).toList(),
              onChanged: _isSubmitting ? null : (value) {
                setState(() => _selectedStatus = value!);
              },
            ),
            const SizedBox(height: 16),
            
            // Priority Dropdown (Editable)
            DropdownButtonFormField<String>(
              value: _selectedPriority,
              decoration: _buildInputDecoration('Priority *'),
              items: _priorityOptions.map((option) {
                return DropdownMenuItem(
                  value: option['value'],
                  child: Text(option['label']!),
                );
              }).toList(),
              onChanged: _isSubmitting ? null : (value) {
                setState(() => _selectedPriority = value!);
              },
            ),
            const SizedBox(height: 16),
            
            // Machine ID (Read-only)
            TextField(
              controller: TextEditingController(
                text: widget.report.machineName ?? widget.report.machineId,
              ),
              style: TextStyle(color: Colors.grey[600]),
              decoration: _buildInputDecoration('Machine', readOnly: true),
              enabled: false,
              readOnly: true,
            ),
            const SizedBox(height: 16),
            
            // User Name (Read-only)
            TextField(
              controller: TextEditingController(text: widget.report.userName),
              decoration: _buildInputDecoration('Reported By', readOnly: true),
              enabled: false,
              readOnly: true,
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            
            // Created At (Read-only)
            TextField(
              controller: TextEditingController(
                text: DateFormat('MM/dd/yyyy, hh:mm a').format(widget.report.createdAt),
              ),
              decoration: _buildInputDecoration('Created At', readOnly: true),
              enabled: false,
              readOnly: true,
              style: TextStyle(color: Colors.grey[600]),
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
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _handleSubmit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isAuthenticated ? Colors.teal : Colors.orange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
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
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (!isAuthenticated)
                                const Padding(
                                  padding: EdgeInsets.only(right: 6),
                                  child: Icon(Icons.lock_outline, size: 16),
                                ),
                              Text(isAuthenticated ? 'Update Report' : 'Login Required'),
                            ],
                          ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}