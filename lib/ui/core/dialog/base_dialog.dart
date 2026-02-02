// lib/ui/core/dialog/base_dialog.dart

import 'package:flutter/material.dart';
import 'dialog_action.dart';
import 'dialog_widgets.dart';
import '../themes/web_colors.dart';

/// Base reusable dialog wrapper with standard sizing and structure
class BaseDialog extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget content;
  final List<DialogAction> actions;
  final double maxHeightFactor;
  final bool canClose;

  const BaseDialog({
    super.key,
    required this.title,
    required this.subtitle,
    required this.content,
    required this.actions,
    this.maxHeightFactor = 0.8,
    this.canClose = true,
  });

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final maxHeight = screenHeight * maxHeightFactor;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(20),
      child: Container(
        constraints: BoxConstraints(maxWidth: 500, maxHeight: maxHeight),
        decoration: BoxDecoration(
          color: WebColors.cardBackground,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Headera
            DialogHeader(title: title, subtitle: subtitle, canClose: canClose),

            // Content (scrollable)
            Flexible(child: DialogContent(child: content)),

            // Footer
            DialogFooter(actions: actions),
          ],
        ),
      ),
    );
  }
}
