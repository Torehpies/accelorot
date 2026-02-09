// lib/ui/core/widgets/shared/detail_field.dart

import 'package:flutter/material.dart';
import '../../themes/web_text_styles.dart';
import '../../themes/web_colors.dart';

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
          style: WebTextStyles.label.copyWith(color: WebColors.textSecondary),
        ),
        const SizedBox(height: 6),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: WebColors.inputBackground,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: WebColors.cardBorder),
          ),
          child: Text(
            value,
            style: WebTextStyles.bodyMediumGray,
            maxLines: isMultiline ? null : 1,
          ),
        ),
      ],
    );
  }
}
