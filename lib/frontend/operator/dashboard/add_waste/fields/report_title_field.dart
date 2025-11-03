// lib/frontend/operator/dashboard/add_waste/fields/report_title_field.dart

import 'package:flutter/material.dart';

class ReportTitleField extends StatelessWidget {
  final TextEditingController controller;
  final String? errorText;

  const ReportTitleField({
    super.key,
    required this.controller,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLength: 100,
      decoration: InputDecoration(
        labelText: 'Brief title for the report',
        prefixIcon: const Icon(Icons.title, size: 18),
        errorText: errorText,
        counterText: '',
        hintText: 'e.g., Motor making unusual noise',
      ),
    );
  }
}