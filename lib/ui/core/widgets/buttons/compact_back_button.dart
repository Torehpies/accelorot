// lib/ui/core/widgets/compact_back_button.dart

import 'package:flutter/material.dart';
import '../../themes/app_theme.dart';

/// Compact back button designed for tight spaces
/// Unlike Flutter's default BackButton, this is smaller and more space-efficient
class CompactBackButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Color? color;
  final double size;

  const CompactBackButton({
    super.key,
    this.onPressed,
    this.color,
    this.size = 20,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back, size: size),
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(
        minWidth: 30,
        minHeight: 30,
      ),
      onPressed: onPressed ?? () => Navigator.of(context).pop(),
      color: color ?? AppColors.textPrimary,
      splashRadius: 20,
      tooltip: 'Back',
    );
  }
}