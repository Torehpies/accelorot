// lib/frontend/operator/dashboard/add_waste/add_waste_product.dart

// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_application_1/data/services/contracts/waste/description_field.dart';
import 'package:flutter_application_1/data/services/contracts/waste/plant_type_section.dart';
import 'package:flutter_application_1/data/services/contracts/waste/quantity_field.dart';

import 'package:flutter_application_1/data/services/contracts/waste/waste_category_section.dart';
import 'package:flutter_application_1/data/services/contracts/waste/waste_config.dart';
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
    if (!mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.redAccent.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
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
    if (!_validateForm()) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (!mounted) return;
      _showError('Please log in to add waste log.');
      return;
    }

    final wasteEntry = {
      'category': _capitalizeCategory(_selectedWasteCategory!),
      'plantType': _selectedPlantType!,
      'plantTypeLabel': getPlantLabel(_selectedPlantType),
      'quantity': double.parse(_quantityController.text),
      'description': _descriptionController.text.trim(),
      'timestamp': DateTime.now(),
    };

    try {
      await FirestoreActivityService.addWasteProduct(wasteEntry);
      await Future.delayed(const Duration(milliseconds: 800));

      if (!mounted) return;
      Navigator.pop(context, wasteEntry);
    } catch (e) {
      if (!mounted) return;
      _showError('Failed to add waste: ${e.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isWeb =
        Theme.of(context).platform == TargetPlatform.macOS ||
        Theme.of(context).platform == TargetPlatform.windows ||
        Theme.of(context).platform == TargetPlatform.linux;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 32),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.12),
                blurRadius: 20,
                offset: const Offset(0, 8),
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
                    'Add Waste Product',
                    style: TextStyle(
                      fontSize: isWeb ? 22 : 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.grey[800],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 24, color: Colors.grey),
                    onPressed: () => Navigator.pop(context),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    splashRadius: 20,
                    hoverColor: Colors.grey[200]?.withOpacity(0.3),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Waste Category
              WasteCategorySection(
                selectedWasteCategory: _selectedWasteCategory,
                onCategoryChanged: (value) => setState(() {
                  _selectedWasteCategory = value;
                  _selectedPlantType = null;
                }),
              ),
              const SizedBox(height: 20),

              // Plant Type
              PlantTypeSection(
                selectedWasteCategory: _selectedWasteCategory,
                selectedPlantType: _selectedPlantType,
                onPlantTypeChanged: (value) =>
                    setState(() => _selectedPlantType = value),
              ),
              const SizedBox(height: 20),

              // Quantity
              QuantityField(
                controller: _quantityController,
                minQuantity: _minQuantity,
                maxQuantity: _maxQuantity,
                errorText: _validateQuantity(_quantityController.text),
                onChanged: (value) => setState(() {}),
              ),
              const SizedBox(height: 20),

              // Description
              DescriptionField(controller: _descriptionController),
              const SizedBox(height: 28),

              // ✅ DIRECT ELEVATED BUTTON (no SubmitButton wrapper)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _handleSubmit,
                  style:
                      ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        textStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ).copyWith(
                        overlayColor: MaterialStateProperty.resolveWith<Color?>(
                          (Set<MaterialState> states) {
                            if (states.contains(MaterialState.hovered)) {
                              return Colors.teal.withAlpha(25);
                            }
                            if (states.contains(MaterialState.pressed)) {
                              return Colors.teal.withAlpha(50);
                            }
                            return null;
                          },
                        ),
                      ),
                  child: const Text('Add Waste'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
