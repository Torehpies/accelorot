// lib/ui/operator_dashboard/fields/quantity_field.dart

import 'package:flutter/material.dart';

class QuantityField extends StatelessWidget {
  final TextEditingController controller;
  final double minQuantity;
  final double maxQuantity;
  final String? errorText;
  final Function(String) onChanged;

  const QuantityField({
    super.key,
    required this.controller,
    required this.minQuantity,
    required this.maxQuantity,
    required this.errorText,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: 'Enter quantity ($minQuantity-$maxQuantity kg)',
        prefixIcon: Icon(Icons.scale, size: 18),
        suffixText: 'kg',
        errorText: errorText,
      ),
      onChanged: onChanged,
    );
  }
}
