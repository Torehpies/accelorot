// lib/ui/operator_dashboard/widgets/add_waste/add_waste_product.dart

import 'package:flutter/material.dart';
import 'package:flutter_application_1/ui/core/ui/app_snackbar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../operator_dashboard/fields/waste_category_section.dart';
import '../../../operator_dashboard/fields/plant_type_section.dart';
import '../../../operator_dashboard/fields/quantity_field.dart';
import '../../../operator_dashboard/fields/description_field.dart';
import '../../../operator_dashboard/fields/machine_selection_field.dart';
import '../../../../data/providers/substrate_providers.dart';
import '../../../../data/models/substrate.dart';
import '../../../operator_dashboard/fields/batch_selection_field.dart';
import 'package:flutter_application_1/ui/core/widgets/bottom_sheets/mobile_bottom_sheet_base.dart';
import 'package:flutter_application_1/ui/core/widgets/bottom_sheets/mobile_bottom_sheet_buttons.dart';

class AddWasteProduct extends ConsumerStatefulWidget {
  final String? preSelectedMachineId;
  final String? preSelectedBatchId;

  const AddWasteProduct({
    super.key,
    this.preSelectedMachineId,
    this.preSelectedBatchId,
  });

  @override
  ConsumerState<AddWasteProduct> createState() => _AddWasteProductState();
}

class _AddWasteProductState extends ConsumerState<AddWasteProduct> {
  static const double _minQuantity = 5.0;
  static const double _maxQuantity = 25.0;

  String? _selectedWasteCategory;
  String? _selectedPlantType;
  String? _selectedMachineId;
  String? _selectedBatchId;
  final _quantityController = TextEditingController();
  final _descriptionController = TextEditingController();

  String? _quantityError;
  String? _wasteCategoryError;
  String? _plantTypeError;
  String? _machineError;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedMachineId = widget.preSelectedMachineId;
    _selectedBatchId = widget.preSelectedBatchId;
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  String _capitalizeCategory(String category) {
    if (category.isEmpty) return category;
    return category[0].toUpperCase() + category.substring(1);
  }

  String? _validateQuantity(String? value) {
    if (value == null || value.isEmpty) return 'Enter quantity';
    final num = double.tryParse(value);
    if (num == null) return 'Enter a valid number';
    if (num < _minQuantity) return 'Min: ${_minQuantity}kg';
    if (num > _maxQuantity) return 'Max: ${_maxQuantity}kg';
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
      
      _plantTypeError = _validatePlantType(_selectedPlantType);
      
      if (_selectedMachineId == null) {
        _machineError = 'Please select a machine';
      }
      
      _quantityError = _validateQuantity(_quantityController.text);
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
      AppSnackbar.error(context, 'Please log in to add waste log');
      return;
    }

    setState(() => _isLoading = true);

    // Trim the plant type input
    final plantTypeValue = _selectedPlantType!.trim();

    final substrateData = CreateSubstrateRequest(
      category: _capitalizeCategory(_selectedWasteCategory!),
      plantType: plantTypeValue,        // Store the readable text
      plantTypeLabel: plantTypeValue,   // Same as plantType
      quantity: double.parse(_quantityController.text),
      description: _descriptionController.text.trim(),
      machineId: _selectedMachineId!,
      operatorName: user.displayName ?? user.email ?? 'Operator',
      userId: user.uid,
    );

    try {
      final substrateRepo = ref.read(substrateRepositoryProvider);
      await substrateRepo.addSubstrate(substrateData);

      if (mounted) {
        AppSnackbar.success(context, 'Waste entry added successfully');
        await Future.delayed(const Duration(milliseconds: 600));
        if (mounted) Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        AppSnackbar.error(context, 'Failed to add waste: ${e.toString()}');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MobileBottomSheetBase(
      title: 'Add Waste Product',
      subtitle: 'Log waste material for composting',
      showCloseButton: false,
      actions: [
        BottomSheetAction.secondary(
          label: 'Cancel',
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
        ),
        BottomSheetAction.primary(
          label: 'Add Waste',
          onPressed: _handleSubmit,
          isLoading: _isLoading,
        ),
      ],
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Machine Selection
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

          // Batch Selection
          BatchSelectionField(
            selectedBatchId: _selectedBatchId,
            selectedMachineId: _selectedMachineId,
            onChanged: (value) {
              setState(() => _selectedBatchId = value);
            },
            isLocked: widget.preSelectedBatchId != null,
          ),
          const SizedBox(height: 16),

          // Waste Category
          WasteCategorySection(
            selectedWasteCategory: _selectedWasteCategory,
            onCategoryChanged: (value) {
              setState(() {
                _selectedWasteCategory = value;
                _selectedPlantType = null; // Clear plant type when category changes
                _wasteCategoryError = null;
              });
            },
            errorText: _wasteCategoryError,
          ),
          const SizedBox(height: 16),

          // Plant Type
          PlantTypeSection(
            selectedWasteCategory: _selectedWasteCategory,
            selectedPlantType: _selectedPlantType,
            onPlantTypeChanged: (value) {
              setState(() {
                _selectedPlantType = value;
                _plantTypeError = null;
              });
            },
            errorText: _plantTypeError,
          ),
          const SizedBox(height: 16),

          // Quantity
          QuantityField(
            controller: _quantityController,
            minQuantity: _minQuantity,
            maxQuantity: _maxQuantity,
            errorText: _quantityError,
            onChanged: (value) => setState(() => _quantityError = null),
          ),
          const SizedBox(height: 16),

          // Description
          DescriptionField(controller: _descriptionController),
        ],
      ),
    );
  }
}