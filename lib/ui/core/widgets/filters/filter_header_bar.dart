// lib/ui/core/widgets/filters/filter_header_bar.dart

import 'package:flutter/material.dart';

/// Generic filter header bar with configurable left and right sections
/// Used at the top of table containers
class FilterHeaderBar extends StatelessWidget {
  /// Left section widget (title, filter dropdowns, etc.)
  final Widget? leftWidget;

  /// Right section widgets (search bar, date filter, etc.)
  final List<Widget>? rightWidgets;

  /// Spacing between right widgets
  final double rightWidgetSpacing;

  const FilterHeaderBar({
    super.key,
    this.leftWidget,
    this.rightWidgets,
    this.rightWidgetSpacing = 12.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Left section
          if (leftWidget != null) Expanded(child: leftWidget!),

          // Spacer
          if (leftWidget != null && rightWidgets != null) const Spacer(),

          // Right section widgets with spacing
          if (rightWidgets != null)
            ...rightWidgets!.map((widget) {
              final index = rightWidgets!.indexOf(widget);
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (index > 0) SizedBox(width: rightWidgetSpacing),
                  widget,
                ],
              );
            }),
        ],
      ),
    );
  }
}
