// lib/components/add-waste-product.dart
import 'package:flutter/material.dart';

class AddWasteProduct extends StatefulWidget {
  const AddWasteProduct({Key? key}) : super(key: key);

  @override
  State<AddWasteProduct> createState() => _AddWasteProductState();
}

class _AddWasteProductState extends State<AddWasteProduct> {
  String? _selectedWasteCategory;
  String? _selectedPlantType;
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String? _quantityError; // Added to hold quantity validation error

  final Map<String, String> _wasteCategoryInfo = {
    'greens': 'Nitrogen source (fast decomposition)',
    'browns': 'Carbon source (slow decomposition)',
  };

  final Map<String, List<Map<String, String>>> _plantTypeOptions = {
    'greens': [
      {'value': 'leafy_vegetables', 'label': 'Leafy Vegetables', 'needs': 'Needs nitrogen'},
      {'value': 'herbs', 'label': 'Herbs', 'needs': 'Needs nitrogen'},
    ],
    'browns': [
      {'value': 'fruiting_vegetables', 'label': 'Fruiting Vegetables', 'needs': 'Needs carbon'},
      {'value': 'fruit_trees', 'label': 'Fruit Trees', 'needs': 'Needs carbon'},
      {'value': 'root_crops', 'label': 'Root Crops', 'needs': 'Needs carbon'},
    ],
  };

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
    if (num < 5) return 'Min: 5kg';
    if (num > 25) return 'Max: 25kg';
    return null;
  }

  String _getPlantLabel(String? value) {
    if (value == null) return '';
    for (var category in _plantTypeOptions.values) {
      for (var plant in category) {
        if (plant['value'] == value) return plant['label']!;
      }
    }
    return '';
  }

  String _getPlantNeedsInfo() {
    if (_selectedWasteCategory == null || _selectedPlantType == null) return '';
    final options = _plantTypeOptions[_selectedWasteCategory] ?? [];
    final plant = options.firstWhere(
      (option) => option['value'] == _selectedPlantType,
      orElse: () => {'needs': 'Nutritional needs'},
    );
    return plant['needs'] ?? 'Nutritional needs';
  }

  List<DropdownMenuItem<String>> _getPlantTypeItems() {
    if (_selectedWasteCategory == null) {
      return [
        const DropdownMenuItem(
          value: null,
          child: Text('Select waste category first'),
        )
      ];
    }

    final options = _plantTypeOptions[_selectedWasteCategory] ?? [];
    return options.map((option) {
      return DropdownMenuItem(
        value: option['value'],
        child: Tooltip(
          message: '${option['label']} - ${option['needs']}',
          child: Text(
            option['label']!,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 14),
          ),
        ),
      );
    }).toList();
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
            borderRadius: BorderRadius.circular(16.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
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

              // Waste Category Info
              if (_selectedWasteCategory != null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.green[100]!),
                  ),
                  child: Text(
                    '💡 ${_wasteCategoryInfo[_selectedWasteCategory]!}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.green[800],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              if (_selectedWasteCategory != null) const SizedBox(height: 12),

              // Waste Category
              DropdownButtonFormField<String>(
                value: _selectedWasteCategory,
                isExpanded: true,
                decoration: InputDecoration(
                  labelText: 'Select Waste Category',
                  prefixIcon: const Icon(Icons.category_outlined, size: 18),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.teal.shade700),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                ),
                items: const [
                  DropdownMenuItem(value: 'greens', child: Text('Greens (Nitrogen)')),
                  DropdownMenuItem(value: 'browns', child: Text('Browns (Carbon)')),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedWasteCategory = value;
                    _selectedPlantType = null;
                  });
                },
              ),
              const SizedBox(height: 16),

              // Plant Type Info
              if (_selectedWasteCategory != null && _selectedPlantType != null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.blue[100]!),
                  ),
                  child: Text(
                    '🌱 ${_getPlantNeedsInfo()}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.blue[800],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              if (_selectedWasteCategory != null && _selectedPlantType != null)
                const SizedBox(height: 12),

              // Target Plant Type
              DropdownButtonFormField<String>(
                value: _selectedPlantType,
                isExpanded: true,
                decoration: InputDecoration(
                  labelText: 'Select Target Plant Type',
                  prefixIcon: const Icon(Icons.local_florist_outlined, size: 18),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.teal.shade700),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                ),
                items: _getPlantTypeItems(),
                onChanged: _selectedWasteCategory == null
                    ? null
                    : (value) {
                        setState(() {
                          _selectedPlantType = value;
                        });
                      },
              ),
              const SizedBox(height: 16),

              // Quantity
             TextField(
  controller: _quantityController,
  decoration: InputDecoration(
    labelText: 'Enter Quantity (5-25 kg)',
    prefixIcon: const Icon(Icons.scale, size: 18),
    suffixText: 'kg',
    suffixStyle: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w500),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8.0),
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.teal.shade700),
      borderRadius: BorderRadius.circular(8.0),
    ),
    contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
    errorText: _quantityError, // ✅ Show error here
  ),
  keyboardType: TextInputType.numberWithOptions(decimal: true),
  onChanged: (value) {
    setState(() {
      _quantityError = _validateQuantity(value); // ✅ Validate as user types
    });
  },
),
              const SizedBox(height: 16),

              // Description
              TextField(
                controller: _descriptionController,
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: 'Description',
                  prefixIcon: const Icon(Icons.description_outlined, size: 18),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.teal.shade700),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                ),
              ),
              const SizedBox(height: 24),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    final qtyError = _validateQuantity(_quantityController.text);
                    if (_selectedWasteCategory == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Select waste category')),
                      );
                      return;
                    }
                    if (_selectedPlantType == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Select target plant type')),
                      );
                      return;
                    }
                    if (qtyError != null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(qtyError)),
                      );
                      return;
                    }

                    final wasteEntry = {
                      'category': _selectedWasteCategory!,
                      'plantType': _selectedPlantType!,
                      'plantTypeLabel': _getPlantLabel(_selectedPlantType),
                      'quantity': double.parse(_quantityController.text),
                      'description': _descriptionController.text,
                      'timestamp': DateTime.now(),
                    };

                    // Return data and close
                    Navigator.pop(context, wasteEntry);

                    // Show success message
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          '✅ ${_selectedWasteCategory == 'greens' ? 'Greens' : 'Browns'} waste assigned to ${_getPlantLabel(_selectedPlantType)}!',
                        ),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E7D32),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    elevation: 0,
                    textStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  child: const Text('Log Waste Product'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}