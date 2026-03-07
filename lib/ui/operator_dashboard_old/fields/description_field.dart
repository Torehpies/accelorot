// lib/ui/operator_dashboard/fields/description_field.dart

import 'package:flutter/material.dart';
import '../../core/widgets/bottom_sheets/fields/mobile_input_field.dart';

class DescriptionField extends StatelessWidget {
  final TextEditingController controller;
  final int maxLength;
  final bool isRequired;

  const DescriptionField({
    super.key,
    required this.controller,
    this.maxLength = 200,
    this.isRequired = false,
  });

  @override
  Widget build(BuildContext context) {
    return MobileInputField(
      label: isRequired ? 'Description' : 'Description (Optional)',
      controller: controller,
      maxLines: 3,
      maxLength: maxLength,
      showCounter: true,
      hintText: isRequired 
          ? 'Describe the issue or observation...'
          : 'Add any additional notes...',
      prefixIcon: const Icon(Icons.description_outlined, size: 18),
      required: isRequired,
    );
  }
}