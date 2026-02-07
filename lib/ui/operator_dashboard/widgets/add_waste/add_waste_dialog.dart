// lib/ui/operator_dashboard/widgets/add_waste/add_waste_dialog.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/dialog/base_dialog.dart';
import '../../../core/dialog/dialog_action.dart';
import '../../../core/dialog/dialog_fields.dart';
import '../../../core/dialog/toast_service.dart';
import '../../../../data/providers/substrate_providers.dart';
import '../../../../data/models/substrate.dart';
import '../../../../data/models/machine_model.dart';
import '../../../../data/models/batch_model.dart';
import '../../../../data/services/firebase/firebase_machine_service.dart';
import '../../../../data/services/firebase/firebase_batch_service.dart';
import '../../../../data/repositories/machine_repository/machine_repository_remote.dart';
import '../../../../data/repositories/batch_repository/batch_repository_remote.dart';
import '../../../../services/sess_service.dart';

class AddWasteDialog extends ConsumerStatefulWidget {
  final String? preSelectedMachineId;
  final String? preSelectedBatchId;

  const AddWasteDialog({
    super.key,
    this.preSelectedMachineId,
    this.preSelectedBatchId,
  });

  @override
  ConsumerState<AddWasteDialog> createState() => _AddWasteDialogState();
}

class _AddWasteDialogState extends ConsumerState<AddWasteDialog> {
  static const double _minQuantity = 5.0;
  static const double _maxQuantity = 25.0;

  String? _selectedWasteCategory;
  String? _selectedMachineId;
  String? _selectedBatchId;
  final _plantTypeController = TextEditingController();
  final _descriptionController = TextEditingController();
  double _quantity = 5.0;

  String? _quantityError;
  String? _wasteCategoryError;
  String? _plantTypeError;
  String? _machineError;

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
    _plantTypeController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  String _capitalizeCategory(String category) {
    if (category.isEmpty) return category;
    return category[0].toUpperCase() + category.substring(1);
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

  String? _validateQuantity(double value) {
    if (value < _minQuantity) return 'Min: ${_minQuantity}kg';
    if (value > _maxQuantity) return 'Max: ${_maxQuantity}kg';
    return null;
  }

  String? _validatePlantType(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter plant type';
    }
    if (value.trim().length > 50) {
      return 'Max 50 characters';
    }
    return null;
  }

  bool _validateForm() {
    setState(() {
      _wasteCategoryError = null;
      _plantTypeError = null;
      _machineError = null;
      _quantityError = null;

      if (_selectedWasteCategory == null) {
        _wasteCategoryError = 'Please select waste category';
      }
      
      _plantTypeError = _validatePlantType(_plantTypeController.text);
      
      if (_selectedMachineId == null) {
        _machineError = 'Please select a machine';
      }
      
      _quantityError = _validateQuantity(_quantity);
    });

    return _wasteCategoryError == null &&
        _plantTypeError == null &&
        _machineError == null &&
        _quantityError == null;
  }

  Future<void> _handleSubmit() async {
    if (!_validateForm()) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (!mounted) return;
      ToastService.show(
        context,
        message: 'Please log in to add waste log',
      );
      return;
    }

    setState(() => _isLoading = true);

    final plantTypeValue = _plantTypeController.text.trim();

    final substrateData = CreateSubstrateRequest(
      category: _capitalizeCategory(_selectedWasteCategory!),
      plantType: plantTypeValue,
      plantTypeLabel: plantTypeValue,
      quantity: _quantity,
      description: _descriptionController.text.trim(),
      machineId: _selectedMachineId!,
      operatorName: user.displayName ?? user.email ?? 'Operator',
      userId: user.uid,
    );

    try {
      final substrateRepo = ref.read(substrateRepositoryProvider);
      await substrateRepo.addSubstrate(substrateData);

      if (mounted) {
        ToastService.show(
          context,
          message: 'Waste entry added successfully',
        );
        await Future.delayed(const Duration(milliseconds: 600));
        if (mounted) Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ToastService.show(
          context,
          message: 'Failed to add waste: ${e.toString()}',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BaseDialog(
      title: 'Add Waste Product',
      subtitle: 'Log waste material for composting',
      maxHeightFactor: 0.8,
      canClose: !_isLoading,
      actions: [
        DialogAction.secondary(
          label: 'Cancel',
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
        ),
        DialogAction.primary(
          label: 'Add Waste',
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
                return DropdownField<String>(
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
                return DropdownField<String>(
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

              return DropdownField<String>(
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
                return DropdownField<String>(
                  label: 'Batch (Optional)',
                  value: null,
                  items: const [],
                  hintText: 'Loading batches...',
                  enabled: false,
                  onChanged: null,
                );
              }

              if (snapshot.hasError) {
                return DropdownField<String>(
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

              return DropdownField<String>(
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

          // Waste Category
          DropdownField<String>(
            label: 'Waste Category',
            value: _selectedWasteCategory,
            items: const [
              DropdownItem(value: 'greens', label: 'Greens (Nitrogen)'),
              DropdownItem(value: 'browns', label: 'Browns (Carbon)'),
              DropdownItem(value: 'compost', label: 'Compost'),
            ],
            hintText: 'Select waste category',
            errorText: _wasteCategoryError,
            enabled: !_isLoading,
            required: true,
            onChanged: (value) {
              setState(() {
                _selectedWasteCategory = value;
                _plantTypeController.clear();
                _wasteCategoryError = null;
              });
            },
          ),
          const SizedBox(height: 16),

          // Plant Type
          InputField(
            label: 'Target Plant Type',
            controller: _plantTypeController,
            hintText: _selectedWasteCategory == null
                ? 'Select category first'
                : 'Enter plant type',
            errorText: _plantTypeError,
            enabled: _selectedWasteCategory != null && !_isLoading,
            required: true,
            maxLength: 50,
            onChanged: (value) => setState(() => _plantTypeError = null),
          ),
          const SizedBox(height: 16),

          // Quantity
          NumberStepperField(
            label: 'Quantity',
            value: _quantity,
            min: _minQuantity,
            max: _maxQuantity,
            step: 0.5,
            decimalPlaces: 1,
            unit: 'kg',
            errorText: _quantityError,
            helperText: 'Enter quantity ($_minQuantity-$_maxQuantity kg)',
            enabled: !_isLoading,
            required: true,
            onChanged: (value) {
              setState(() {
                _quantity = value;
                _quantityError = null;
              });
            },
          ),
          const SizedBox(height: 16),

          // Description
          InputField(
            label: 'Description (Optional)',
            controller: _descriptionController,
            hintText: 'Add any additional notes...',
            enabled: !_isLoading,
            maxLines: 3,
            maxLength: 200,
          ),
        ],
      ),
    );
  }
}