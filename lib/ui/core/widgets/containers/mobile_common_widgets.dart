// lib/ui/core/widgets/containers/mobile_common_widgets.dart

import 'package:flutter/material.dart';
import '../../themes/app_theme.dart';
import '../../themes/app_text_styles.dart';

/// Wrapper for scaffold with keyboard dismissal and centralized background
/// All screens MUST use this to enforce consistent styling
class MobileScaffoldContainer extends StatelessWidget {
  final Widget body;
  final VoidCallback? onTap;

  const MobileScaffoldContainer({
    super.key,
    required this.body,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap ?? () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: AppColors.background1,
        body: body,
      ),
    );
  }
}

/// Loading state with shimmer animation
class MobileLoadingState extends StatefulWidget {
  final int itemCount;
  final Widget Function(BuildContext, int) skeletonBuilder;

  const MobileLoadingState({
    super.key,
    this.itemCount = 3,
    required this.skeletonBuilder,
  });

  @override
  State<MobileLoadingState> createState() => _MobileLoadingStateState();
}

class _MobileLoadingStateState extends State<MobileLoadingState>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _pulseAnimation = CurvedAnimation(
      parent: _shimmerController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: widget.itemCount,
      itemBuilder: (context, index) {
        return AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            return widget.skeletonBuilder(context, index);
          },
        );
      },
    );
  }
}

/// Error state with retry button
class MobileErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const MobileErrorState({
    super.key,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: AppColors.error),
            const SizedBox(height: 16),
            Text(
              message,
              style: AppTextStyles.body.copyWith(color: AppColors.error),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh, size: 18),
              label: Text('Retry', style: AppTextStyles.button),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.green100,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Empty state with optional action button
class MobileEmptyState extends StatelessWidget {
  final IconData icon;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  const MobileEmptyState({
    super.key,
    required this.icon,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: AppColors.textSecondary),
            const SizedBox(height: 16),
            Text(
              message,
              style: AppTextStyles.body.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 16),
              TextButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.clear_all),
                label: Text(actionLabel!),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.green100,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Load more button for pagination
class MobileLoadMoreButton extends StatelessWidget {
  final int remainingCount;
  final VoidCallback onPressed;

  const MobileLoadMoreButton({
    super.key,
    required this.remainingCount,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: const Icon(Icons.expand_more),
        label: Text(
          'Load More ($remainingCount remaining)',
          style: AppTextStyles.button,
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.green100,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
      ),
    );
  }
}