import 'package:flutter/material.dart';
import 'package:flutter_application_1/ui/core/themes/app_theme.dart';
import 'package:flutter_application_1/ui/core/themes/web_colors.dart';

class SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color iconBackgroundColor;
  final Color iconForegroundColor;

  const SummaryCard({
    super.key,
    required this.title,
    required this.value,
    required this.iconBackgroundColor,
    required this.iconForegroundColor,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.background2,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: WebColors.cardBorder, width: 1),
          boxShadow: [
            BoxShadow(
              color: WebColors.cardShadow,
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: WebColors.textLabel,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: iconBackgroundColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, size: 20, color: iconForegroundColor),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.w700,
                color: WebColors.textHeading,
                height: 1.1,
              ),
            ),
            const SizedBox(height: 5),
            // const Divider(height: 1, color: WebColors.dividerLight),
            // const SizedBox(height: 5),
          ],
        ),
      ),
    );
  }
}
