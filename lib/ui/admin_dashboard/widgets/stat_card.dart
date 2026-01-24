// lib/ui/mobile_admin_home/widgets/stat_card.dart

import 'package:flutter/material.dart';

class StatCard extends StatelessWidget {
  final int count;
  final String label;
  final String? subtitle;
  final IconData? icon;
  final Color? iconColor;
  final Color? iconBackgroundColor;

  const StatCard({
    super.key,
    required this.count,
    required this.label,
    this.subtitle,
    this.icon,
    this.iconColor,
    this.iconBackgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      // changed: light gray/blue background
      color: const Color(0xFFF5F7FA),
      elevation: 2,
      // changed: increased border radius
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    count.toString(),
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal.shade600,
                      height: 1,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      subtitle!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        color: subtitle!.startsWith('+')
                            ? Colors.green
                            : Colors.black54,
                        fontWeight: subtitle!.startsWith('+')
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (icon != null) ...[
              const SizedBox(width: 16),
              // changed: smaller icon container (48x48) with rounded corners (radius 12) and smaller icon (24)
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: iconBackgroundColor ?? Colors.teal.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 24, color: iconColor ?? Colors.teal),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
