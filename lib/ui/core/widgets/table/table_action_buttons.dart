// lib/ui/core/widgets/table/table_action_buttons.dart

import 'package:flutter/material.dart';
import '../../themes/web_colors.dart';

/// Defines a single action button for table rows
class TableActionButton {
  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;
  final Color? color;
  final double? iconSize;

  const TableActionButton({
    required this.icon,
    required this.tooltip,
    this.onPressed,
    this.color,
    this.iconSize,
  });
}

/// Reusable action buttons widget for table rows
/// Uses 30x30 button size with InkWell pattern for consistent sizing
class TableActionButtons extends StatelessWidget {
  final List<TableActionButton> actions;
  final double spacing;

  const TableActionButtons({
    super.key,
    required this.actions,
    this.spacing = 4,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int i = 0; i < actions.length; i++) ...[
          _buildActionButton(actions[i]),
          if (i < actions.length - 1) SizedBox(width: spacing),
        ],
      ],
    );
  }

  Widget _buildActionButton(TableActionButton action) {
    return Tooltip(
      message: action.tooltip,
      child: SizedBox.square(
        dimension: 30,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: action.onPressed,
            child: Icon(
              action.icon,
              size: action.iconSize ?? 18,
              color: action.color ?? WebColors.textLabel,
            ),
          ),
        ),
      ),
    );
  }
}