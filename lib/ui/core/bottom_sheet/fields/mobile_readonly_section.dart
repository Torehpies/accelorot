// lib/ui/core/bottom_sheet/fields/mobile_readonly_section.dart

import 'package:flutter/material.dart';
import '../../themes/web_colors.dart';
import '../../themes/web_text_styles.dart';

class MobileReadOnlySection extends StatelessWidget {
  final List<Widget> fields;
  final String? sectionTitle;

  const MobileReadOnlySection({
    super.key,
    required this.fields,
    this.sectionTitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: WebColors.badgeBackground,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (sectionTitle != null) ...[
            Text(
              sectionTitle!,
              style: WebTextStyles.label.copyWith(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: WebColors.textSecondary,
              ),
            ),
            const SizedBox(height: 10),
          ],
          // Fields with thin dividers between them
          for (int i = 0; i < fields.length; i++) ...[
            fields[i],
            if (i < fields.length - 1)
              const Divider(
                height: 1,
                color: WebColors.cardBorder,
                indent: 4,
                endIndent: 4,
              ),
          ],
        ],
      ),
    );
  }
}