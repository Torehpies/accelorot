// lib/ui/landing_page/models/feature_model.dart

import 'package:flutter/material.dart';

class FeatureModel {
  final String title;
  final String description;
  final IconData icon;
  final Color iconColor;
  final Color backgroundColor;

  FeatureModel({
    required this.title,
    required this.description,
    required this.icon,
    required this.iconColor,
    required this.backgroundColor,
  });
}