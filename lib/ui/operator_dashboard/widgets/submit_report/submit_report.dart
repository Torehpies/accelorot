import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../fields/report_type_field.dart';
import '../../fields/report_title_field.dart';
import '../../fields/machine_selection_field.dart';
import '../../fields/priority_field.dart';
import '../../fields/description_field.dart';
import '../../../../data/providers/report_providers.dart';
import '../../../../data/models/report.dart';
import '../../fields/batch_selection_field.dart';
import '../../../core/bottom_sheet/mobile_bottom_sheet_base.dart';
import '../../../core/bottom_sheet/mobile_bottom_sheet_buttons.dart';
import '../../../core/toast/mobile_toast_service.dart';
import '../../../core/toast/toast_type.dart';

class SubmitReport extends ConsumerStatefulWidget {
  final String? preSelectedMachineId;
  final String? preSelectedBatchId;

  const SubmitReport({
    super.key,
    this.preSelectedMachineId,
    this.preSelectedBatchId,
  });

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

  bool _isLoading = false;

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

  Future<void> _handleSubmit() async {
    if (!_validateForm()) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (!mounted) return;
      MobileToastService.show(
        context,
        message: 'Please log in to submit a report',
        type: ToastType.error,
      );
      return;
    }

    setState(() => _isLoading = true);

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

      if (mounted) {
        MobileToastService.show(
          context,
          message: 'Report submitted successfully',
          type: ToastType.success,
        );
        await Future.delayed(const Duration(milliseconds: 600));
        if (mounted) Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        MobileToastService.show(
          context,
          message: 'Failed to submit report: ${e.toString()}',
          type: ToastType.error,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MobileBottomSheetBase(
      title: 'Submit Report',
      subtitle: 'Create maintenance or observation report',
      showCloseButton: false,
      actions: [
        BottomSheetAction.secondary(
          label: 'Cancel',
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
        ),
        BottomSheetAction.primary(
          label: 'Submit Report',
          onPressed: _handleSubmit,
          isLoading: _isLoading,
        ),
      ],
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
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
        ],
      ),
    );
  }
}