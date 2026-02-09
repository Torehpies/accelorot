// lib/ui/operator_dashboard/fields/waste_category_section.dart

import 'package:flutter/material.dart';
import '../../core/bottom_sheet/fields/mobile_dropdown_field.dart';
import 'waste_config.dart';
import 'info_box.dart';

class WasteCategorySection extends StatelessWidget {
  final String? selectedWasteCategory;
  final Function(String?) onCategoryChanged;
  final String? errorText;

  const WasteCategorySection({
    super.key,
    required this.selectedWasteCategory,
    required this.onCategoryChanged,
    this.errorText,
  });

  static const List<MobileDropdownItem<String>> _wasteCategoryItems = [
    MobileDropdownItem(value: 'greens', label: 'Greens (Nitrogen)'),
    MobileDropdownItem(value: 'browns', label: 'Browns (Carbon)'),
    MobileDropdownItem(value: 'compost', label: 'Compost'),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        MobileDropdownField<String>(
          label: 'Waste Category',
          value: selectedWasteCategory,
          items: _wasteCategoryItems,
          required: true,
          onChanged: onCategoryChanged,
          errorText: errorText,
          hintText: 'Select category',
        ),
        if (selectedWasteCategory != null) ...[
          const SizedBox(height: 12),
          InfoBox(
            text: wasteCategoryInfo[selectedWasteCategory]!,
            color: Colors.green,
            emoji: '',
          ),
        ],
      ],
    );
  }
}