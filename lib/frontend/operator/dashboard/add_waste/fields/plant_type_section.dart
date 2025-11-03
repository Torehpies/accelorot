// plant_type_section.dart
import 'package:flutter/material.dart';
import 'waste_config.dart';
import 'info_box.dart';


class PlantTypeSection extends StatelessWidget {
  final String? selectedWasteCategory;
  final String? selectedPlantType;
  final Function(String?) onPlantTypeChanged;
  final String? errorText;


  const PlantTypeSection({
    super.key,
    required this.selectedWasteCategory,
    required this.selectedPlantType,
    required this.onPlantTypeChanged,
    this.errorText,
  });


  String _getPlantNeedsInfo() {
    if (selectedWasteCategory == null || selectedPlantType == null) return '';
    final options = plantTypeOptions[selectedWasteCategory] ?? [];
    final plant = options.firstWhere(
      (option) => option['value'] == selectedPlantType,
      orElse: () => {'needs': ''},
    );
    return plant['needs'] ?? '';
  }


  List<DropdownMenuItem<String>> _getPlantTypeItems() {
    if (selectedWasteCategory == null) {
      return const [
        DropdownMenuItem(
          value: null,
          enabled: false,
          child: Text('Select category first'),
        ),
      ];
    }
    final options = plantTypeOptions[selectedWasteCategory] ?? [];
    return options.map((option) {
      return DropdownMenuItem(
        value: option['value'],
        child: Text(option['label']!, style: const TextStyle(fontSize: 14)),
      );
    }).toList();
  }


  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (selectedWasteCategory != null && selectedPlantType != null)
          ...[
            InfoBox(
              text: _getPlantNeedsInfo(),
              color: Colors.blue,
              emoji: '',
            ),
            const SizedBox(height: 12),
          ],
        DropdownButtonFormField<String>(
          initialValue: selectedPlantType,
          isExpanded: true,
          decoration: InputDecoration(
            labelText: 'Select target type',
            prefixIcon: const Icon(Icons.local_florist_outlined, size: 18),
            errorText: errorText,
          ),
          items: _getPlantTypeItems(),
          onChanged: selectedWasteCategory == null ? null : onPlantTypeChanged,
        ),
      ],
    );
  }
}
