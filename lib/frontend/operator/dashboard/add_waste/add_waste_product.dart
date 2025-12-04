//add_waste_product.dart
import 'package:flutter/material.dart';
import 'fields/waste_category_section.dart';
import 'fields/plant_type_section.dart';
import 'fields/quantity_field.dart';
import 'fields/description_field.dart';
import 'fields/submit_button.dart';
import 'fields/waste_config.dart';
import 'fields/machine_selection_field.dart';
import 'package:flutter_application_1/services/firestore_activity_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddWasteProduct extends StatefulWidget {
  final String? preSelectedMachineId;

  const AddWasteProduct({super.key, this.preSelectedMachineId});

  // Builds and displays the Add Waste Product dialog.
  @override
  State<AddWasteProduct> createState() => _AddWasteProductState();
}

class _AddWasteProductState extends State<AddWasteProduct> {
  static const double _minQuantity = 5.0;
  static const double _maxQuantity = 25.0;

  String? _selectedWasteCategory;
  String? _selectedPlantType;
  String? _selectedMachineId;
  final _quantityController = TextEditingController();
  final _descriptionController = TextEditingController();

  // Error state variables
  String? _quantityError;
  String? _wasteCategoryError;
  String? _plantTypeError;
  String? _machineError;

  // Disposes controllers to free memory when widget is removed.
  @override
  void dispose() {
    _quantityController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    _selectedMachineId = widget.preSelectedMachineId;
  }

  // Capitalizes the first letter of a given category name.
  String _capitalizeCategory(String category) {
    if (category.isEmpty) return category;
    return category[0].toUpperCase() + category.substring(1);
  }

  // Validates the entered quantity and ensures it's within defined limits.
  String? _validateQuantity(String? value) {
    if (value == null || value.isEmpty) return 'Enter quantity';
    final num = double.tryParse(value);
    if (num == null) return 'Enter a valid number';
    if (num < _minQuantity) return 'Min: ${_minQuantity}kg';
    if (num > _maxQuantity) return 'Max: ${_maxQuantity}kg';
    return null;
  }

  // Ensures required fields are selected and valid before submission.
  bool _validateForm() {
    setState(() {
      // Clear all errors first
      _wasteCategoryError = null;
      _plantTypeError = null;
      _machineError = null;
      _quantityError = null;

      // Validate each field and set error messages
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

    // Return true only if all errors are null
    return _wasteCategoryError == null &&
        _plantTypeError == null &&
        _machineError == null &&
        _quantityError == null;
  }

  // Retrieves the display label for a given plant type value.
  String getPlantLabel(String? value) {
    if (value == null) return '';
    for (var options in plantTypeOptions.values) {
      for (var plant in options) {
        if (plant['value'] == value) return plant['label']!;
      }
    }
    return '';
  }

  // Handles form submission, validates input, and saves data to Firestore.
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

    final wasteEntry = {
      'category': _capitalizeCategory(_selectedWasteCategory!),
      'plantType': _selectedPlantType!,
      'plantTypeLabel': getPlantLabel(_selectedPlantType),
      'quantity': double.parse(_quantityController.text),
      'description': _descriptionController.text.trim(),
      'timestamp': DateTime.now(),
      'machineId': _selectedMachineId!,
      'operatorName': user.displayName ?? user.email ?? 'Operator',
      'userId': user.uid,
      // 'machineName': _selectedMachineName,
    };

    try {
      await FirestoreActivityService.addWasteProduct(wasteEntry);
      await Future.delayed(const Duration(milliseconds: 1000));
      if (!mounted) return;
      Navigator.pop(context, wasteEntry);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add waste: ${e.toString()}')),
      );
    }
  }

  // Builds the Add Waste Product dialog layout and structure.
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Add Waste Product',
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
              WasteCategorySection(
                selectedWasteCategory: _selectedWasteCategory,
                onCategoryChanged: (value) => setState(() {
                  _selectedWasteCategory = value;
                  _selectedPlantType = null;
                  _wasteCategoryError = null;
                }),
                errorText: _wasteCategoryError,
              ),
              const SizedBox(height: 16),
              PlantTypeSection(
                selectedWasteCategory: _selectedWasteCategory,
                selectedPlantType: _selectedPlantType,
                onPlantTypeChanged: (value) => setState(() {
                  _selectedPlantType = value;
                  _plantTypeError = null;
                }),
                errorText: _plantTypeError,
              ),
              const SizedBox(height: 16),
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
              QuantityField(
                controller: _quantityController,
                minQuantity: _minQuantity,
                maxQuantity: _maxQuantity,
                errorText: _quantityError,
                onChanged: (value) =>
                    setState(() => _quantityError = _validateQuantity(value)),
              ),
              const SizedBox(height: 16),
              DescriptionField(controller: _descriptionController),
              const SizedBox(height: 24),
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
