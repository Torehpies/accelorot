// lib/ui/operator_dashboard/fields/plant_type_section.dart
import 'package:flutter/material.dart';
import '../../core/widgets/bottom_sheets/fields/mobile_input_field.dart';

class PlantTypeSection extends StatefulWidget {
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

  @override
  State<PlantTypeSection> createState() => _PlantTypeSectionState();
}

class _PlantTypeSectionState extends State<PlantTypeSection> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.selectedPlantType ?? '');
  }

  @override
  void didUpdateWidget(PlantTypeSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update controller if plant type changed externally (e.g., category changed and cleared it)
    if (widget.selectedPlantType != oldWidget.selectedPlantType) {
      _controller.text = widget.selectedPlantType ?? '';
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEnabled = widget.selectedWasteCategory != null;

    return MobileInputField(
      label: 'Target Plant Type',
      controller: _controller,
      required: true,
      enabled: isEnabled,
      onChanged: isEnabled ? widget.onPlantTypeChanged : null,
      errorText: widget.errorText,
      hintText: widget.selectedWasteCategory == null 
          ? 'Select category first' 
          : 'Enter plant type',
      maxLength: 50,
    );
  }
}