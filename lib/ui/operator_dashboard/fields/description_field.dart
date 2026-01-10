// lib/frontend/operator/dashboard/add_waste/fields/description_field.dart
import 'package:flutter/material.dart';

class DescriptionField extends StatelessWidget {
  final TextEditingController controller;

  const DescriptionField({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: 2,
      decoration: InputDecoration(
        labelText: 'Description (optional)',
        prefixIcon: Icon(Icons.description_outlined, size: 18),
      ),
    );
  }
}
