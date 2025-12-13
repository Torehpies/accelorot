// waste_category_section.dart
import 'package:flutter/material.dart';
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

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (selectedWasteCategory != null) ...[
          InfoBox(
            text: wasteCategoryInfo[selectedWasteCategory]!,
            color: Colors.green,
            emoji: '',
          ),
          const SizedBox(height: 12),
        ],
        DropdownButtonFormField<String>(
          initialValue: selectedWasteCategory,
          isExpanded: true,
          decoration: InputDecoration(
            labelText: 'Select category',
            prefixIcon: const Icon(Icons.category_outlined, size: 18),
            errorText: errorText,
          ),
          items: const [
            DropdownMenuItem(value: 'greens', child: Text('Greens (Nitrogen)')),
            DropdownMenuItem(value: 'browns', child: Text('Browns (Carbon)')),
            DropdownMenuItem(value: 'compost', child: Text('Compost')),
          ],
          onChanged: onCategoryChanged,
        ),
      ],
    );
  }
}
