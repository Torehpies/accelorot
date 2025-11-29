// lib/ui/activity_logs/models/filter_config.dart
import 'package:flutter/material.dart';

/// Configuration data for a filter box
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