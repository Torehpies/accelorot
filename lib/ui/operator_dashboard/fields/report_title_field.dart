// lib/ui/operator_dashboard/fields/report_title_field.dart

import 'package:flutter/material.dart';
import '../../core/widgets/bottom_sheets/fields/mobile_input_field.dart';

class ReportTitleField extends StatelessWidget {
  final TextEditingController controller;
  final String? errorText;
  final ValueChanged<String>? onChanged;

  const ReportTitleField({
    super.key,
    required this.controller,
    this.errorText,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return MobileInputField(
      label: 'Report Title',
      controller: controller,
      hintText: 'Enter a descriptive title',
      prefixIcon: const Icon(Icons.title, size: 18),
      errorText: errorText,
      onChanged: onChanged,
      required: true,
      maxLength: 100,
      showCounter: true,
    );
  }
}