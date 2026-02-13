// lib/ui/operator_dashboard/fields/quantity_field.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/widgets/bottom_sheets/fields/mobile_input_field.dart';

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
    return MobileInputField(
      label: 'Quantity (kg)',
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
      ],
      hintText: 'Enter quantity in kg',
      prefixIcon: const Icon(Icons.scale, size: 18),
      suffix: 'kg',
      errorText: errorText,
      onChanged: onChanged,
      required: true,
      maxLength: 3,
    );
  }
}