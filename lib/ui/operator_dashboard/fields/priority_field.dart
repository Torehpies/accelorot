// lib/ui/operator_dashboard/fields/priority_field.dart

import 'package:flutter/material.dart';
import '../../core/bottom_sheet/fields/mobile_dropdown_field.dart';

class PriorityField extends StatelessWidget {
  final String? selectedPriority;
  final Function(String?) onChanged;
  final String? errorText;

  const PriorityField({
    super.key,
    required this.selectedPriority,
    required this.onChanged,
    this.errorText,
  });

  static const List<MobileDropdownItem<String>> _priorityItems = [
    MobileDropdownItem(value: 'low', label: 'Low'),
    MobileDropdownItem(value: 'medium', label: 'Medium'),
    MobileDropdownItem(value: 'high', label: 'High'),
  ];

  @override
  Widget build(BuildContext context) {
    return MobileDropdownField<String>(
      label: 'Priority',
      value: selectedPriority,
      items: _priorityItems,
      required: true,
      onChanged: onChanged,
      errorText: errorText,
      hintText: 'Select priority',
    );
  }
}