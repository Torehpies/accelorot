import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../operator_dashboard/fields/waste_category_section.dart';
import '../../../operator_dashboard/fields/plant_type_section.dart';
import '../../../operator_dashboard/fields/quantity_field.dart';
import '../../../operator_dashboard/fields/description_field.dart';
import '../../../operator_dashboard/fields/submit_button.dart';
import '../../../operator_dashboard/fields/waste_config.dart';
import '../../../operator_dashboard/fields/machine_selection_field.dart';
//import '../../../activity_logs/widgets/batch_selector.dart';
import '../../../../data/providers/substrate_providers.dart';
import '../../../../data/models/substrate.dart';
import '../../../operator_dashboard/fields/batch_selection_field.dart';

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

  bool _validateForm() {
    setState(() {
      _wasteCategoryError = null;
      _plantTypeError = null;
      _machineError = null;
      _quantityError = null;

      if (_selectedWasteCategory == null) {
        _wasteCategoryError = 'Please select waste category';
      }
      if (_selectedPlantType == null) {
        _plantTypeError = 'Please select target plant type';
      }
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

  String getPlantLabel(String? value) {
    if (value == null) return '';
    for (var options in plantTypeOptions.values) {
      for (var plant in options) {
        if (plant['value'] == value) return plant['label']!;
      }
    }
    return '';
  }

  void _handleSubmit() async {
    if (!_validateForm()) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please log in to add waste log.'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    final substrateData = CreateSubstrateRequest(
      category: _capitalizeCategory(_selectedWasteCategory!),
      plantType: _selectedPlantType!,
      plantTypeLabel: getPlantLabel(_selectedPlantType),
      quantity: double.parse(_quantityController.text),
      description: _descriptionController.text.trim(),
      machineId: _selectedMachineId!,
      operatorName: user.displayName ?? user.email ?? 'Operator',
      userId: user.uid,
    );

    try {
      final substrateRepo = ref.read(substrateRepositoryProvider);
      await substrateRepo.addSubstrate(substrateData);

      if (!mounted) return;

      Navigator.pop(context, true);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Waste entry added successfully!'),
          backgroundColor: Colors.teal,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to add waste: ${e.toString()}'),
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
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Add Waste Product',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
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
                    _selectedPlantType = null;
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
