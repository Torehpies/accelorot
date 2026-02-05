// lib/ui/core/toast/toast_type.dart

import 'package:flutter/material.dart';

/// Toast variant types with associated colors and icons
enum ToastType {
  success(
    color: Color(0xFF22C55E),      // AppColors.green100
    bgColor: Color(0xFFf0FDF4),
    borderColor: Color(0xFF86EFAC),
    icon: Icons.check_circle_outlined,
    label: 'Success',
  ),
  error(
    color: Color(0xFFEF4444),
    bgColor: Color(0xFFFEF2F2),
    borderColor: Color(0xFFFCA5A5),
    icon: Icons.error_outline,
    label: 'Error',
  ),
  info(
    color: Color(0xFF3B82F6),
    bgColor: Color(0xFFEFF6FF),
    borderColor: Color(0xFF93C5FD),
    icon: Icons.info_outline,
    label: 'Info',
  );

  const ToastType({
    required this.color,
    required this.bgColor,
    required this.borderColor,
    required this.icon,
    required this.label,
  });

  final Color color;
  final Color bgColor;
  final Color borderColor;
  final IconData icon;
  final String label;
}