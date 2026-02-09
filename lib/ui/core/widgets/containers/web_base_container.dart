// lib/ui/core/widgets/web_base_container.dart

import 'package:flutter/material.dart';
import 'package:flutter_application_1/ui/core/themes/app_theme.dart';
import '../../themes/web_colors.dart';
import '../../themes/web_text_styles.dart';

/// Wraps Scaffold + backgroundColor + SafeArea pattern used in all web views
class WebScaffoldContainer extends StatelessWidget {
  final Widget child;

  const WebScaffoldContainer({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(child: child),
    );
  }
}

/// Wraps the bordered container pattern: Padding → Container(border) → Padding
class WebContentContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsets? innerPadding;

  const WebContentContainer({
    super.key,
    required this.child,
    this.innerPadding,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: WebColors.primaryBorder, width: 1.5),
        ),
        child: Padding(
          padding: innerPadding ?? const EdgeInsets.all(12),
          child: child,
        ),
      ),
    );
  }
}

/// Wraps the Column layout: StatsRow + SizedBox + Expanded(Table)
class WebStatsTableLayout extends StatelessWidget {
  final Widget statsRow;
  final Widget table;

  const WebStatsTableLayout({
    super.key,
    required this.statsRow,
    required this.table,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        statsRow,
        const SizedBox(height: 12),
        Expanded(child: table),
      ],
    );
  }
}

/// Standard error state display with optional retry button
class WebErrorState extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const WebErrorState({super.key, required this.message, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: WebColors.error),
          const SizedBox(height: 16),
          Text(
            'Error',
            style: WebTextStyles.h3.copyWith(color: WebColors.textSecondary),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: WebTextStyles.bodyMediumGray,
            textAlign: TextAlign.center,
          ),
          if (onRetry != null) ...[
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: WebColors.buttonsPrimary,
                foregroundColor: WebColors.buttonText,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Retry',
                style: WebTextStyles.bodyMedium.copyWith(
                  color: WebColors.buttonText,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Standard login required state display
class WebLoginRequired extends StatelessWidget {
  final String? message;

  const WebLoginRequired({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.lock_outline, size: 64, color: WebColors.textMuted),
          const SizedBox(height: 16),
          Text(
            message ?? 'Please log in to view this content',
            style: WebTextStyles.bodyMedium.copyWith(
              fontSize: 16,
              color: WebColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Wrapper for consistent dialog styling across the app
class WebDialogWrapper {
  /// Shows a dialog with consistent styling
  static Future<T?> show<T>({
    required BuildContext context,
    required Widget child,
    Color? backgroundColor,
    EdgeInsets? insetPadding,
    BoxConstraints? constraints,
  }) {
    return showDialog<T>(
      context: context,
      barrierColor: WebColors.dialogBarrier,
      builder: (context) {
        Widget dialogChild = child;

        if (constraints != null) {
          dialogChild = ConstrainedBox(
            constraints: constraints,
            child: dialogChild,
          );
        }

        return Dialog(
          backgroundColor: backgroundColor ?? WebColors.dialogBackground,
          insetPadding: insetPadding ?? const EdgeInsets.all(40),
          child: dialogChild,
        );
      },
    );
  }
}
