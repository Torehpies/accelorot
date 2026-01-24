// lib/frontend/operator/dashboard/add_waste/fields/report_type_field.dart

import 'package:flutter/material.dart';

class ReportTypeField extends StatelessWidget {
  final String? selectedReportType;
  final Function(String?) onChanged;
  final String? errorText; // ADDED

  const ReportTypeField({
    super.key,
    required this.selectedReportType,
    required this.onChanged,
    this.errorText, // ADDED
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: selectedReportType,
      isExpanded: true,
      decoration: InputDecoration(
        // CHANGED: const to non-const
        labelText: 'Select report type',
        prefixIcon: const Icon(Icons.report_outlined, size: 18),
        errorText: errorText, // ADDED
      ),
      items: const [
        DropdownMenuItem(
          value: 'maintenance_issue',
          child: Text('Maintenance Issue', style: TextStyle(fontSize: 14)),
        ),
        DropdownMenuItem(
          value: 'observation',
          child: Text('Observation', style: TextStyle(fontSize: 14)),
        ),
        DropdownMenuItem(
          value: 'safety_concern',
          child: Text('Safety Concern', style: TextStyle(fontSize: 14)),
        ),
      ],
      onChanged: onChanged,
    );
  }
}
