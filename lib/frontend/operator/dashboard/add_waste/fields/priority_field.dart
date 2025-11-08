// lib/frontend/operator/dashboard/add_waste/fields/priority_field.dart

import 'package:flutter/material.dart';


class PriorityField extends StatelessWidget {
  final String? selectedPriority;
  final Function(String?) onChanged;
  final String? errorText;  // ADDED


  const PriorityField({
    super.key,
    required this.selectedPriority,
    required this.onChanged,
    this.errorText,  // ADDED
  });


  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: selectedPriority,
      isExpanded: true,
      decoration: InputDecoration(  // CHANGED: const to non-const
        labelText: 'Select priority',
        prefixIcon: const Icon(Icons.priority_high, size: 18),
        errorText: errorText,  // ADDED
      ),
      items: const [
        DropdownMenuItem(
          value: 'low',
          child: Row(
            children: [
              Icon(Icons.circle, size: 10, color: Color(0xFF4CAF50)),
              SizedBox(width: 8),
              Text('Low', style: TextStyle(fontSize: 14)),
            ],
          ),
        ),
        DropdownMenuItem(
          value: 'medium',
          child: Row(
            children: [
              Icon(Icons.circle, size: 10, color: Color(0xFFFFC107)),
              SizedBox(width: 8),
              Text('Medium', style: TextStyle(fontSize: 14)),
            ],
          ),
        ),
        DropdownMenuItem(
          value: 'high',
          child: Row(
            children: [
              Icon(Icons.circle, size: 10, color: Color(0xFFFF9800)),
              SizedBox(width: 8),
              Text('High', style: TextStyle(fontSize: 14)),
            ],
          ),
        ),
      ],
      onChanged: onChanged,
    );
  }
}
