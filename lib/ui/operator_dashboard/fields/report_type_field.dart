// lib/ui/operator_dashboard/fields/report_type_field.dart

import 'package:flutter/material.dart';
import '../../core/widgets/bottom_sheets/fields/mobile_dropdown_field.dart';

class ReportTypeField extends StatelessWidget {
  final String? selectedReportType;
  final Function(String?) onChanged;
  final String? errorText;

  const ReportTypeField({
    super.key,
    required this.selectedReportType,
    required this.onChanged,
    this.errorText,
  });

  static const List<MobileDropdownItem<String>> _reportTypeItems = [
    MobileDropdownItem(value: 'maintenance_issue', label: 'Maintenance Issue'),
    MobileDropdownItem(value: 'observation', label: 'Observation'),
    MobileDropdownItem(value: 'safety_concern', label: 'Safety Concern'),
  ];

  @override
  Widget build(BuildContext context) {
    return MobileDropdownField<String>(
      label: 'Report Type',
      value: selectedReportType,
      items: _reportTypeItems,
      required: true,
      onChanged: onChanged,
      errorText: errorText,
      hintText: 'Select report type',
    );
  }
}