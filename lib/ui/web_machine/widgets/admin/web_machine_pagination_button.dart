// lib/ui/machine_management/widgets/shared/machine_pagination_button.dart
import 'package:flutter/material.dart';

class MachinePaginationButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final bool iconRight;
  final bool isActive;
  final VoidCallback onPressed;
  final bool enabled;

  const MachinePaginationButton({
    super.key,
    required this.label,
    this.icon,
    this.iconRight = false,
    this.isActive = false,
    required this.onPressed,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: enabled ? onPressed : null,
      style: TextButton.styleFrom(
        backgroundColor: isActive
            ? const Color(0xFF10B981)
            : (enabled ? Colors.transparent : const Color(0xFFF3F4F6)),
        foregroundColor: isActive
            ? Colors.white
            : (enabled ? const Color(0xFF6B7280) : const Color(0xFF9CA3AF)),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        minimumSize: const Size(40, 36),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null && !iconRight) Icon(icon, size: 16),
          if (icon != null && !iconRight) const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          if (icon != null && iconRight) const SizedBox(width: 4),
          if (icon != null && iconRight) Icon(icon, size: 16),
        ],
      ),
    );
  }
}