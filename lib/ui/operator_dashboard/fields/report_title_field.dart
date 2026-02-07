// lib/ui/operator_dashboard/fields/report_title_field.dart

import 'package:flutter/material.dart';

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
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: 'Report Title',
        hintText: 'Enter a descriptive title',
        prefixIcon: const Icon(Icons.title, size: 18),
        errorText: errorText,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
      onChanged: onChanged,
    );
  }
}
