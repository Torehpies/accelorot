// lib/ui/landing_page/models/step_model.dart
import 'package:flutter/material.dart';

class StepModel {
  final int number;
  final String title;
  final String description;
  final IconData icon;
  final Color accentColor;

  StepModel({
    required this.number,
    required this.title,
    required this.description,
    required this.icon,
    required this.accentColor,
  });
}
