// lib/ui/web_landing_page/widgets/breadcrumb_trail.dart

import 'package:flutter/material.dart';
import '../../core/constants/spacing.dart';
import '../../core/themes/web_colors.dart';
import '../../core/themes/web_text_styles.dart';

class BreadcrumbTrail extends StatelessWidget {
  final List<String> items;
  final Function(String) onTap;

  const BreadcrumbTrail({
    super.key,
    required this.items,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xxxl,
        vertical: AppSpacing.sm,
      ),
      child: SizedBox(
        height: 24,
        child: ListView(
          scrollDirection: Axis.horizontal,
          physics: const NeverScrollableScrollPhysics(),
          children: List.generate(items.length, (index) {
            final isLast = index == items.length - 1;
            final item = items[index];
            final id = item.toLowerCase().replaceAll(' ', '-');

            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: () => onTap(id),
                  child: Text(
                    item,
                    style: isLast
                        ? WebTextStyles.bodyMedium.copyWith(
                            color: WebColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          )
                        : WebTextStyles.bodyMedium.copyWith(
                            color: WebColors.textMuted,
                            fontWeight: FontWeight.w500,
                          ),
                  ),
                ),
                if (index < items.length - 1)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      '>',
                      style: WebTextStyles.bodyMedium.copyWith(
                        color: WebColors.textMuted,
                        fontSize: 16,
                      ),
                    ),
                  ),
              ],
            );
          }),
        ),
      ),
    );
  }
}