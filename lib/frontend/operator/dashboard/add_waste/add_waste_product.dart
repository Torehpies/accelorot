import 'package:flutter/material.dart';
import 'fields/waste_category_section.dart';
import 'fields/plant_type_section.dart';
import 'fields/quantity_field.dart';
import 'fields/description_field.dart';
import 'fields/submit_button.dart';
import 'fields/waste_config.dart';
import 'package:flutter_application_1/services/firestore_activity_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddWasteProduct extends StatefulWidget {
  const AddWasteProduct({super.key});
  
  @override
  State<AddWasteProduct> createState() => _AddWasteProductState();
}

class _AddWasteProductState extends State<AddWasteProduct> {
  static const double _minQuantity = 5.0;
  static const double _maxQuantity = 25.0;

  String? _selectedWasteCategory;
  String? _selectedPlantType;
  final _quantityController = TextEditingController();
  final _descriptionController = TextEditingController();
  String? _quantityError;

  @override
  void dispose() {
    _quantityController.dispose();
    _descriptionController.dispose();
    super.dispose();
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
    if (_selectedWasteCategory == null) {
      _showError('Please select waste category');
      return false;
    }
    if (_selectedPlantType == null) {
      _showError('Please select target plant type');
      return false;
    }
    final qtyError = _validateQuantity(_quantityController.text);
    if (qtyError != null) {
      _showError(qtyError);
      return false;
    }
    return true;
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
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
    // Validate form first
    if (!_validateForm()) return;

    // Check if user is logged in
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      // Show snackbar and keep dialog open
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please log in to add waste log.'),
          duration: Duration(seconds: 2),
        ),
      );
      return; // Dialog stays open
    }

    // User is logged in - proceed with submission
    final wasteEntry = {
      'category': _selectedWasteCategory!,
      'plantType': _selectedPlantType!,
      'plantTypeLabel': getPlantLabel(_selectedPlantType),
      'quantity': double.parse(_quantityController.text),
      'description': _descriptionController.text.trim(),
      'timestamp': DateTime.now(),
    };

    try {
      await FirestoreActivityService.addWasteProduct(wasteEntry);
      
      if (!mounted) return;
      
      // Close dialog and return the waste entry
      Navigator.pop(context, wasteEntry);
    } catch (e) {
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error adding waste: $e'),
          duration: const Duration(seconds: 2),
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
                }),
              ),
              const SizedBox(height: 16),
              PlantTypeSection(
                selectedWasteCategory: _selectedWasteCategory,
                selectedPlantType: _selectedPlantType,
                onPlantTypeChanged: (value) => setState(() => _selectedPlantType = value),
              ),
              const SizedBox(height: 16),
              QuantityField(
                controller: _quantityController,
                minQuantity: _minQuantity,
                maxQuantity: _maxQuantity,
                errorText: _quantityError,
                onChanged: (value) => setState(() => _quantityError = _validateQuantity(value)),
              ),
              const SizedBox(height: 16),
              DescriptionField(controller: _descriptionController),
              const SizedBox(height: 24),
              SubmitButton(onPressed: _handleSubmit),
            ],
          ),
        ),
      ),
    );
  }
}