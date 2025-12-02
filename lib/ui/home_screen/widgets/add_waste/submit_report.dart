// lib/frontend/operator/dashboard/add_waste/submit_report.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../frontend/operator/dashboard/add_waste/fields/report_type_field.dart';
import '../../../../frontend/operator/dashboard/add_waste/fields/report_title_field.dart';
import '../../../../frontend/operator/dashboard/add_waste/fields/machine_selection_field.dart';
import '../../../../frontend/operator/dashboard/add_waste/fields/priority_field.dart';
import '../../../../frontend/operator/dashboard/add_waste/fields/description_field.dart';
import '../../../../frontend/operator/dashboard/add_waste/fields/submit_button.dart';
import 'package:flutter_application_1/services/firestore_activity_service.dart';

class SubmitReport extends StatefulWidget {
  final String? preSelectedMachineId;

  const SubmitReport({super.key, this.preSelectedMachineId});

  @override
  State<SubmitReport> createState() => _SubmitReportState();
}

class _SubmitReportState extends State<SubmitReport> {
  String? _selectedReportType;
  String? _selectedMachineId;
  String? _selectedPriority;
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  // Error state variables for each field
  String? _titleError;
  String? _reportTypeError;
  String? _machineError;
  String? _priorityError;

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
    setState(() {
      // Clear all errors first
      _reportTypeError = null;
      _machineError = null;
      _priorityError = null;
      _titleError = null;

      // Validate each field and set error messages
      if (_selectedReportType == null) {
        _reportTypeError = 'Please select a report type';
      }
      if (_selectedMachineId == null) {
        _machineError = 'Please select a machine';
      }
      if (_selectedPriority == null) {
        _priorityError = 'Please select a priority level';
      }
      _titleError = _validateTitle(_titleController.text);
    });

    // Return true only if all errors are null
    return _reportTypeError == null &&
        _machineError == null &&
        _priorityError == null &&
        _titleError == null;
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
                onChanged: (value) => setState(() {
                  _selectedReportType = value;
                  _reportTypeError = null;
                }),
                errorText: _reportTypeError,
              ),
              const SizedBox(height: 16),

              // Title
              ReportTitleField(
                controller: _titleController,
                errorText: _titleError,
                onChanged: (value) {
                  setState(() {
                    _titleError = null;
                  });
                },
              ),
              const SizedBox(height: 16),

              // Machine Selection
              MachineSelectionField(
                selectedMachineId: _selectedMachineId,
                onChanged: widget.preSelectedMachineId == null
                    ? (value) => setState(() {
                        _selectedMachineId = value;
                        _machineError = null;
                      })
                    : null,
                isLocked: widget.preSelectedMachineId != null,
                errorText: _machineError,
              ),
              const SizedBox(height: 16),

              // Priority
              PriorityField(
                selectedPriority: _selectedPriority,
                onChanged: (value) => setState(() {
                  _selectedPriority = value;
                  _priorityError = null;
                }),
                errorText: _priorityError,
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
