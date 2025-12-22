import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; 
import 'package:firebase_auth/firebase_auth.dart';
import '../../fields/report_type_field.dart';
import '../../fields/report_title_field.dart';
import '../../fields/machine_selection_field.dart';
import '../../fields/priority_field.dart';
import '../../fields/description_field.dart';
import '../../fields/submit_button.dart';
import '../../../../data/providers/report_providers.dart'; 
import '../../../../data/models/report.dart'; 
import '../../fields/batch_selection_field.dart'; 

class SubmitReport extends ConsumerStatefulWidget {
  final String? preSelectedMachineId;
  final String? preSelectedBatchId; 

  const SubmitReport({super.key, this.preSelectedMachineId, this.preSelectedBatchId});

  @override
  ConsumerState<SubmitReport> createState() => _SubmitReportState();
}

class _SubmitReportState extends ConsumerState<SubmitReport> {
  String? _selectedReportType;
  String? _selectedMachineId;
  String? _selectedBatchId;
  String? _selectedPriority;
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  String? _titleError;
  String? _reportTypeError;
  String? _machineError;
  String? _priorityError;

  @override
  void initState() {
    super.initState();
    _selectedMachineId = widget.preSelectedMachineId;
    _selectedBatchId = widget.preSelectedBatchId; 
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
      _reportTypeError = null;
      _machineError = null;
      _priorityError = null;
      _titleError = null;

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

    final reportRequest = CreateReportRequest(
      machineId: _selectedMachineId!,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      reportType: _selectedReportType!,
      priority: _selectedPriority!,
      userName: user.displayName ?? user.email ?? 'Unknown',
      userId: user.uid,
    );

    try {
      final reportRepo = ref.read(reportRepositoryProvider);
      await reportRepo.createReport(_selectedMachineId!, reportRequest);
      
      await Future.delayed(const Duration(milliseconds: 500));
      if (!mounted) return;
      
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to submit report: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
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
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Submit Report',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
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

     
              MachineSelectionField(
                selectedMachineId: _selectedMachineId,
                onChanged: (value) {
                  setState(() {
                    _selectedMachineId = value;
                    
                    if (widget.preSelectedMachineId == null) {
                      _selectedBatchId = null;
                    }
                    _machineError = null;
                  });
                },
                isLocked: widget.preSelectedMachineId != null,
                errorText: _machineError,
              ),
              const SizedBox(height: 16),

              BatchSelectionField(
                selectedBatchId: _selectedBatchId,
                selectedMachineId: _selectedMachineId,
                onChanged: (value) {
                  setState(() => _selectedBatchId = value);
                },
                isLocked: widget.preSelectedBatchId != null, 
              ),
              const SizedBox(height: 16),


              // Report Type
              ReportTypeField(
                selectedReportType: _selectedReportType,
                onChanged: (value) {
                  setState(() {
                    _selectedReportType = value;
                    _reportTypeError = null;
                  });
                },
                errorText: _reportTypeError,
              ),
              const SizedBox(height: 16),

              // Title
              ReportTitleField(
                controller: _titleController,
                errorText: _titleError,
                onChanged: (value) => setState(() => _titleError = null),
              ),
              const SizedBox(height: 16),

              // Priority
              PriorityField(
                selectedPriority: _selectedPriority,
                onChanged: (value) {
                  setState(() {
                    _selectedPriority = value;
                    _priorityError = null;
                  });
                },
                errorText: _priorityError,
              ),
              const SizedBox(height: 16),

              // Description
              DescriptionField(controller: _descriptionController),
              const SizedBox(height: 24),

              // Submit Button
              SubmitButton(
                onPressed: _handleSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D32),
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}