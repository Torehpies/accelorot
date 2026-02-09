// lib/ui/web_operator/widgets/operator_action_card.dart

import 'package:flutter/material.dart';
import '../../core/ui/theme_constants.dart';

class OperatorActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final int? count;
  final VoidCallback? onPressed;
  final bool showCountBelow;
  final Color? iconBackgroundColor;
  final Color? iconColor;
  final bool isActive;

  const OperatorActionCard({
    super.key,
    required this.icon,
    required this.label,
    required this.count,
    required this.onPressed,
    this.showCountBelow = false,
    this.iconBackgroundColor,
    this.iconColor,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ThemeConstants.borderRadius16),
        side: BorderSide(
          color: isActive
              ? ThemeConstants.tealShade600
              : ThemeConstants.greyShade200,
          width: isActive ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(ThemeConstants.borderRadius16),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: ThemeConstants.spacing16,
            vertical: ThemeConstants.spacing12,
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: iconBackgroundColor ?? ThemeConstants.tealShade50,
                  borderRadius: BorderRadius.circular(
                    ThemeConstants.borderRadius12,
                  ),
                ),
                child: Icon(
                  icon,
                  size: ThemeConstants.iconSize24,
                  color: iconColor ?? ThemeConstants.tealShade600,
                ),
              ),
              const SizedBox(width: ThemeConstants.spacing12),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: ThemeConstants.fontSize12,
                        fontWeight: FontWeight.w500,
                        color: ThemeConstants.greyShade600,
                        letterSpacing: 0.2,
                      ),
                    ),
                    if (showCountBelow && count != null) ...[
                      const SizedBox(height: ThemeConstants.spacing4),
                      Text(
                        count.toString(),
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                          height: 1.0,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
