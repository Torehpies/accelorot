// lib/ui/activity_logs/view_model/activity_filter_model.dart
import 'package:flutter/material.dart';

class FilterConfig {
  final IconData icon;
  final String label;
  final String filterValue;
  final String route;
  final String? initialFilterArg;

  const FilterConfig({
    required this.icon,
    required this.label,
    required this.filterValue,
    required this.route,
    this.initialFilterArg,
  });
}
