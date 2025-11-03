// lib/frontend/operator/dashboard/add_waste/submit_report.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'fields/report_type_field.dart';
import 'fields/report_title_field.dart';
import 'fields/machine_selection_field.dart';
import 'fields/priority_field.dart';
import 'fields/description_field.dart';
import 'fields/submit_button.dart';
import 'package:flutter_application_1/services/firestore_activity_service.dart';

class SubmitReport extends StatefulWidget {
  final String? preSelectedMachineId;

  const SubmitReport({
    super.key,
    this.preSelectedMachineId,
  });

  @override
  State<SubmitReport> createState() => _SubmitReportState();
}

class _SubmitReportState extends State<SubmitReport> {
  String? _selectedReportType;
  String? _selectedMachineId;
  String? _selectedPriority;
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  String? _titleError;

  @override
  void initState() {
    super.initState();
    _selectedMachineId = widget.preSelectedMachineId;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  String? _validateTitle(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Title is required';
    }
    if (value.trim().length < 5) {
      return 'Title must be at least 5 characters';
    }
    return null;
  }

  bool _validateForm() {
    if (_selectedReportType == null) {
      _showError('Please select a report type');
      return false;
    }
    if (_selectedMachineId == null) {
      _showError('Please select a machine');
      return false;
    }
    if (_selectedPriority == null) {
      _showError('Please select a priority level');
      return false;
    }
    final titleError = _validateTitle(_titleController.text);
    if (titleError != null) {
      _showError(titleError);
      return false;
    }
    return true;
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _handleSubmit() async {
    if (!_validateForm()) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please log in to submit a report.'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    final report = {
      'reportType': _selectedReportType!,
      'title': _titleController.text.trim(),
      'machineId': _selectedMachineId!,
      'priority': _selectedPriority!,
      'description': _descriptionController.text.trim(),
      'timestamp': DateTime.now(),
      'userId': user.uid,
    };

    try {
      await FirestoreActivityService.submitReport(report);
      await Future.delayed(const Duration(milliseconds: 1000));
      if (!mounted) return;
      Navigator.pop(context, report);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to submit report: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(20),
      child: SingleChildScrollView(
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(maxWidth: 400),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(25),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Submit Report',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () => Navigator.pop(context),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Report Type
              ReportTypeField(
                selectedReportType: _selectedReportType,
                onChanged: (value) => setState(() => _selectedReportType = value),
              ),
              const SizedBox(height: 16),

              // Title
              ReportTitleField(
                controller: _titleController,
                errorText: _titleError,
              ),
              const SizedBox(height: 16),

              // Machine Selection
              MachineSelectionField(
                selectedMachineId: _selectedMachineId,
                onChanged: widget.preSelectedMachineId == null
                    ? (value) => setState(() => _selectedMachineId = value)
                    : null,
                isLocked: widget.preSelectedMachineId != null,
              ),
              const SizedBox(height: 16),

              // Priority
              PriorityField(
                selectedPriority: _selectedPriority,
                onChanged: (value) => setState(() => _selectedPriority = value),
              ),
              const SizedBox(height: 16),

              // Description
              DescriptionField(controller: _descriptionController),
              const SizedBox(height: 24),

              // Submit Button
              SubmitButton(
                onPressed: _handleSubmit,
                style: ElevatedButton.styleFrom(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}