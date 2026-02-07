// lib/ui/operator_dashboard/fields/plant_type_section.dart

import 'package:flutter/material.dart';
import '../../core/bottom_sheet/fields/mobile_dropdown_field.dart';
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

  List<MobileDropdownItem<String>> _getPlantTypeItems() {
    if (selectedWasteCategory == null) {
      return [];
    }
    final options = plantTypeOptions[selectedWasteCategory] ?? [];
    return options.map((option) {
      return MobileDropdownItem<String>(
        value: option['value']!,
        label: option['label']!,
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final items = _getPlantTypeItems();
    final isEnabled = selectedWasteCategory != null && items.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        MobileDropdownField<String>(
          label: 'Target Plant Type',
          value: selectedPlantType,
          items: items.isEmpty
              ? [const MobileDropdownItem(value: '', label: 'Select category first')]
              : items,
          required: true,
          enabled: isEnabled,
          onChanged: isEnabled ? onPlantTypeChanged : null,
          errorText: errorText,
          hintText: selectedWasteCategory == null 
              ? 'Select category first' 
              : 'Select target type',
        ),
        if (selectedWasteCategory != null && selectedPlantType != null) ...[
          const SizedBox(height: 12),
          InfoBox(
            text: _getPlantNeedsInfo(),
            color: Colors.blue,
            emoji: '',
          ),
        ],
      ],
    );
  }
}