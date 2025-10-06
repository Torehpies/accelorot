// lib/screens/home_screen.dart

import 'package:flutter/material.dart';
import '../components/activity_logs.dart';
// ignore: unused_import
import '../components/add_waste_product.dart';  // (if you have this)
  
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Map<String, dynamic>> _wasteLogs = [];

  // State for the modal
  String? _selectedWasteCategory;
  String? _selectedPlantType;
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  // Example structure for your plant type options (customize this)
  final Map<String, List<Map<String, String>>> _plantTypeOptions = {
    'greens': [
      {'value': 'tomato', 'label': 'Tomato', 'needs': 'High nitrogen'},
      {'value': 'lettuce', 'label': 'Lettuce', 'needs': 'Moderate nitrogen'},
    ],
    'browns': [
      {'value': 'carrot', 'label': 'Carrot', 'needs': 'Low nitrogen'},
      {'value': 'potato', 'label': 'Potato', 'needs': 'Moderate nitrogen'},
    ],
  };

  @override
  void dispose() {
    _quantityController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  String? _validateQuantity(String? value) {
    if (value == null || value.isEmpty) {
      return 'Enter a quantity';
    }
    final num? parsed = num.tryParse(value);
    if (parsed == null) {
      return 'Enter a valid number';
    }
    if (parsed < 5 || parsed > 25) {
      return 'Quantity must be between 5 and 25 kg';
    }
    return null;
  }

  String _getPlantLabel(String? plantValue) {
    if (_selectedWasteCategory == null || plantValue == null) return '';
    final opts = _plantTypeOptions[_selectedWasteCategory] ?? [];
    final found = opts.firstWhere((opt) => opt['value'] == plantValue, orElse: () => {});
    return found['label'] ?? '';
  }

  String _getPlantNeedsInfo() {
    if (_selectedWasteCategory == null || _selectedPlantType == null) {
      return '';
    }
    final opts = _plantTypeOptions[_selectedWasteCategory] ?? [];
    final found = opts.firstWhere((opt) => opt['value'] == _selectedPlantType, orElse: () => {});
    return found['needs'] ?? '';
  }

  List<DropdownMenuItem<String>> _getPlantTypeItems() {
    if (_selectedWasteCategory == null) {
      return const [
        DropdownMenuItem(value: null, child: Text('Select waste category first')),
      ];
    }
    final options = _plantTypeOptions[_selectedWasteCategory] ?? [];
    return options.map((option) {
      return DropdownMenuItem<String>(
        value: option['value'],
        child: Tooltip(
          message: option['needs'] ?? '',
          child: Text(
            option['label'] ?? '',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      );
    }).toList();
  }

  void _showAddWasteProductModal(BuildContext context) async {
    // ignore: unused_local_variable
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (BuildContext context) {
        String? quantityError;

        return StatefulBuilder(
          builder: (context, setModalState) {
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
                        color: Colors.black.withAlpha((0.1 * 255).round()),
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
                            '💡 ${_plantTypeOptions[_selectedWasteCategory]?.firstWhere(
                                  (opt) => true,
                                  orElse: () => {'needs': ''})['needs'] ?? ''}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.green[800],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      if (_selectedWasteCategory != null) const SizedBox(height: 12),

                      // Waste Category Dropdown
                      DropdownButtonFormField<String>(
                        // ignore: deprecated_member_use
                        value: _selectedWasteCategory,
                        isExpanded: true,
                        decoration: InputDecoration(
                          labelText: 'Select Waste Category',
                          prefixIcon:
                              const Icon(Icons.category_outlined, size: 18),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.teal.shade700),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 12),
                        ),
                        items: const [
                          DropdownMenuItem(
                              value: 'greens',
                              child: Text('Greens (Nitrogen)')),
                          DropdownMenuItem(
                              value: 'browns',
                              child: Text('Browns (Carbon)')),
                        ],
                        onChanged: (value) {
                          setModalState(() {
                            _selectedWasteCategory = value;
                            _selectedPlantType = null;
                          });
                        },
                      ),
                      const SizedBox(height: 16),

                      // Plant Type Info
                      if (_selectedWasteCategory != null &&
                          _selectedPlantType != null)
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
                      if (_selectedWasteCategory != null &&
                          _selectedPlantType != null)
                        const SizedBox(height: 12),

                      // Plant Type Dropdown
                      DropdownButtonFormField<String>(
                        // ignore: deprecated_member_use
                        value: _selectedPlantType,
                        isExpanded: true,
                        decoration: InputDecoration(
                          labelText: 'Select Target Plant Type',
                          prefixIcon: const Icon(Icons.local_florist_outlined,
                              size: 18),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.teal.shade700),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 12),
                        ),
                        items: _getPlantTypeItems(),
                        onChanged: _selectedWasteCategory == null
                            ? null
                            : (value) {
                                setModalState(() {
                                  _selectedPlantType = value;
                                });
                              },
                      ),
                      const SizedBox(height: 16),

                      // Quantity TextField
                      TextField(
                        controller: _quantityController,
                        decoration: InputDecoration(
                          labelText: 'Enter Quantity (5-25 kg)',
                          prefixIcon: const Icon(Icons.scale, size: 18),
                          suffixText: 'kg',
                          suffixStyle: const TextStyle(
                              color: Colors.grey, fontWeight: FontWeight.w500),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.teal.shade700),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 12),
                          errorText: quantityError,
                        ),
                        keyboardType:
                            const TextInputType.numberWithOptions(decimal: true),
                        onChanged: (value) {
                          setModalState(() {
                            quantityError = _validateQuantity(value);
                          });
                        },
                      ),
                      const SizedBox(height: 16),

                      // Description TextField
                      TextField(
                        controller: _descriptionController,
                        maxLines: 2,
                        decoration: InputDecoration(
                          labelText: 'Description',
                          prefixIcon: const Icon(Icons.description_outlined,
                              size: 18),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.teal.shade700),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 12),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Submit Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            final qtyError =
                                _validateQuantity(_quantityController.text);
                            if (_selectedWasteCategory == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content:
                                        Text('Select waste category')),
                              );
                              return;
                            }
                            if (_selectedPlantType == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text(
                                        'Select target plant type')),
                              );
                              return;
                            }
                            if (qtyError != null) {
                              setModalState(() {
                                quantityError = qtyError;
                              });
                              return;
                            }

                            final quantity =
                                double.parse(_quantityController.text);
                            final plantLabel = _getPlantLabel(_selectedPlantType);

                            setState(() {
                              _wasteLogs.insert(
                                0,
                                {
                                  'category': _selectedWasteCategory,
                                  'plantType': _selectedPlantType,
                                  'plantTypeLabel': plantLabel,
                                  'quantity': quantity,
                                  'description': _descriptionController.text,
                                  'timestamp': DateTime.now(),
                                },
                              );
                            });

                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    '✅ ${( _selectedWasteCategory == 'greens' ? 'Greens' : 'Browns')} waste assigned to $plantLabel!'),
                                duration: const Duration(seconds: 2),
                              ),
                            );

                            // Clear inputs after use
                            _quantityController.clear();
                            _descriptionController.clear();
                            _selectedWasteCategory = null;
                            _selectedPlantType = null;
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
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: Colors.teal,
      ),
      body: SafeArea(
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 500),
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const Spacer(),
                CustomCard(title: "Activity Logs", logs: _wasteLogs),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddWasteProductModal(context);
        },
        backgroundColor: Colors.green,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
    );
  }
}
