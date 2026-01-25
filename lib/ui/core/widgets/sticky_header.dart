import 'package:flutter/material.dart';
import 'package:flutter_application_1/ui/core/themes/app_theme.dart';

class StickyHeader extends StatelessWidget {
  final List<String> labels;
  final List<int> flexValues;
  final TextStyle? style;

  const StickyHeader({
    super.key,
    required this.labels,
    required this.flexValues,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    final defaultStyle = TextStyle(
      fontWeight: FontWeight.w500,
      color: AppColors.textSecondary,
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(color: Color(0xFFEFF7FF)),
      child: Row(
        children: List.generate(labels.length, (index) {
          return Expanded(
            flex: flexValues[index],
            child: Center(
              child: Text(labels[index], style: style ?? defaultStyle),
            ),
          );
        }),
      ),
    );
  }
}
