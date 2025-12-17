// lib/ui/core/widgets/shared/detail_field.dart

import 'package:flutter/material.dart';

/// Reusable field widget for detail views
/// Replaces all _buildField methods across detail views
class DetailField extends StatelessWidget {
  final String label;
  final String value;
  final bool isMultiline;

  const DetailField({
    super.key,
    required this.label,
    required this.value,
    this.isMultiline = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'DM Sans',
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 6),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Text(
            value,
            style: const TextStyle(
              fontFamily: 'DM Sans',
              fontSize: 13,
              color: Color(0xFF6B7280),
            ),
            maxLines: isMultiline ? null : 1,
          ),
        ),
      ],
    );
  }
}