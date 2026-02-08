// lib/ui/operator_dashboard/widgets/submit_report/submit_report_dialog.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/dialog/base_dialog.dart';
import '../../../core/dialog/dialog_action.dart';
import '../../../core/dialog/dialog_fields.dart';
import '../../../core/ui/app_snackbar.dart';
import '../../../../data/providers/report_providers.dart';
import '../../../../data/models/report.dart';
import '../../../../data/models/machine_model.dart';
import '../../../../data/models/batch_model.dart';
import '../../../../data/services/firebase/firebase_machine_service.dart';
import '../../../../data/services/firebase/firebase_batch_service.dart';
import '../../../../data/repositories/machine_repository/machine_repository_remote.dart';
import '../../../../data/repositories/batch_repository/batch_repository_remote.dart';
import '../../../../services/sess_service.dart';

class SubmitReportDialog extends ConsumerStatefulWidget {
  final String? preSelectedMachineId;
  final String? preSelectedBatchId;

  const SubmitReportDialog({
    super.key,
    this.preSelectedMachineId,
    this.preSelectedBatchId,
  });

  @override
  ConsumerState<SubmitReportDialog> createState() => _SubmitReportDialogState();
}

class _SubmitReportDialogState extends ConsumerState<SubmitReportDialog> {
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

  late final _machineRepository = MachineRepositoryRemote(FirebaseMachineService());
  late final _batchRepository = BatchRepositoryRemote(
    FirestoreBatchService(FirebaseFirestore.instance),
  );

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

  Future<List<MachineModel>> _fetchTeamMachines() async {
    final sessionService = SessionService();
    final userData = await sessionService.getCurrentUserData();

    if (userData == null) {
      throw Exception('User not authenticated');
    }

    final teamId = userData['teamId'] as String?;
    if (teamId == null || teamId.isEmpty) {
      throw Exception('User not assigned to a team');
    }

    return await _machineRepository.getMachinesByTeam(teamId);
  }

  Future<List<BatchModel>> _fetchMachineBatches() async {
    if (_selectedMachineId == null || _selectedMachineId!.isEmpty) {
      return [];
    }

    try {
      final batches = await _batchRepository.getBatchesForMachines([
        _selectedMachineId!,
      ]);
      return batches.where((batch) => batch.isActive).toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } catch (e) {
      throw Exception('Failed to fetch batches: $e');
    }
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
      AppSnackbar.error(context, 'Please log in to submit a report');
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
        AppSnackbar.success(context, 'Report submitted successfully');
        await Future.delayed(const Duration(milliseconds: 600));
        if (mounted) Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        AppSnackbar.error(context, 'Failed to submit report: ${e.toString()}');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BaseDialog(
      title: 'Submit Report',
      subtitle: 'Create maintenance or observation report',
      maxHeightFactor: 0.8,
      canClose: !_isLoading,
      actions: [
        DialogAction.secondary(
          label: 'Cancel',
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
        ),
        DialogAction.primary(
          label: 'Submit Report',
          onPressed: _handleSubmit,
          isLoading: _isLoading,
        ),
      ],
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Machine Selection
          FutureBuilder<List<MachineModel>>(
            future: _fetchTeamMachines(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return WebDropdownField<String>(
                  label: 'Machine',
                  value: null,
                  items: const [],
                  hintText: 'Loading machines...',
                  enabled: false,
                  required: true,
                  onChanged: null,
                );
              }

              if (snapshot.hasError) {
                return WebDropdownField<String>(
                  label: 'Machine',
                  value: null,
                  items: const [],
                  hintText: 'Error loading machines',
                  errorText: 'Failed to load machines',
                  enabled: false,
                  required: true,
                  onChanged: null,
                );
              }

              final machines = snapshot.data ?? [];
              final machineItems = machines
                  .map((m) => DropdownItem(
                        value: m.machineId,
                        label: m.machineName,
                      ))
                  .toList();

              return WebDropdownField<String>(
                label: 'Machine',
                value: _selectedMachineId,
                items: machineItems,
                hintText: 'Select a machine',
                errorText: _machineError,
                enabled: widget.preSelectedMachineId == null && !_isLoading,
                required: true,
                onChanged: (value) {
                  setState(() {
                    _selectedMachineId = value;
                    if (widget.preSelectedMachineId == null) {
                      _selectedBatchId = null;
                    }
                    _machineError = null;
                  });
                },
              );
            },
          ),
          const SizedBox(height: 16),

          // Batch Selection
          FutureBuilder<List<BatchModel>>(
            key: ValueKey(_selectedMachineId), // Rebuild when machine changes
            future: _fetchMachineBatches(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting &&
                  _selectedMachineId != null &&
                  _selectedMachineId!.isNotEmpty) {
                return WebDropdownField<String>(
                  label: 'Batch (Optional)',
                  value: null,
                  items: const [],
                  hintText: 'Loading batches...',
                  enabled: false,
                  onChanged: null,
                );
              }

              if (snapshot.hasError) {
                return WebDropdownField<String>(
                  label: 'Batch (Optional)',
                  value: null,
                  items: const [],
                  hintText: 'Error loading batches',
                  enabled: false,
                  onChanged: null,
                );
              }

              final batches = snapshot.data ?? [];
              final batchItems = batches
                  .map((b) => DropdownItem(
                        value: b.id,
                        label: b.displayName,
                      ))
                  .toList();

              return WebDropdownField<String>(
                label: 'Batch (Optional)',
                value: _selectedBatchId,
                items: batchItems,
                hintText: _selectedMachineId == null
                    ? 'Select a machine first'
                    : 'Select a batch',
                enabled: _selectedMachineId != null &&
                    widget.preSelectedBatchId == null &&
                    !_isLoading,
                onChanged: (value) {
                  setState(() => _selectedBatchId = value);
                },
              );
            },
          ),
          const SizedBox(height: 16),

          // Report Type
          WebDropdownField<String>(
            label: 'Report Type',
            value: _selectedReportType,
            items: const [
              DropdownItem(
                value: 'maintenance_issue',
                label: 'Maintenance Issue',
              ),
              DropdownItem(
                value: 'safety_concern',
                label: 'Safety Concern',
              ),
              DropdownItem(value: 'observation', label: 'Observation'),
            ],
            hintText: 'Select report type',
            errorText: _reportTypeError,
            enabled: !_isLoading,
            required: true,
            onChanged: (value) {
              setState(() {
                _selectedReportType = value;
                _reportTypeError = null;
              });
            },
          ),
          const SizedBox(height: 16),

          // Title
          InputField(
            label: 'Report Title',
            controller: _titleController,
            hintText: 'Enter a descriptive title',
            errorText: _titleError,
            enabled: !_isLoading,
            required: true,
            maxLength: 100,
            onChanged: (value) => setState(() => _titleError = null),
          ),
          const SizedBox(height: 16),

          // Priority
          WebDropdownField<String>(
            label: 'Priority',
            value: _selectedPriority,
            items: const [
              DropdownItem(value: 'low', label: 'Low'),
              DropdownItem(value: 'medium', label: 'Medium'),
              DropdownItem(value: 'high', label: 'High'),
            ],
            hintText: 'Select priority level',
            errorText: _priorityError,
            enabled: !_isLoading,
            required: true,
            onChanged: (value) {
              setState(() {
                _selectedPriority = value;
                _priorityError = null;
              });
            },
          ),
          const SizedBox(height: 16),

          // Description
          InputField(
            label: 'Description',
            controller: _descriptionController,
            hintText: 'Describe the issue or observation...',
            enabled: !_isLoading,
            required: true,
            maxLines: 5,
            maxLength: 500,
          ),
        ],
      ),
    );
  }
}