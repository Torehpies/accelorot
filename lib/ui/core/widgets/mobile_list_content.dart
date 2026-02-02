// lib/ui/core/widgets/mobile_list_content.dart

import 'package:flutter/material.dart';
import 'mobile_common_widgets.dart';
import '../themes/app_theme.dart';

/// Configuration for empty state display
class EmptyStateConfig {
  final IconData icon;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  const EmptyStateConfig({
    required this.icon,
    required this.message,
    this.actionLabel,
    this.onAction,
  });
}

/// Generic list content handler with pull-to-refresh and pagination
class MobileListContent<T> extends StatelessWidget {
  final bool isLoading;
  final bool isInitialLoad;
  final bool hasError;
  final String? errorMessage;
  final List<T> items;
  final List<T> displayedItems;
  final bool hasMoreToLoad;
  final int remainingCount;
  final EmptyStateConfig emptyStateConfig;
  final Future<void> Function() onRefresh;
  final VoidCallback onLoadMore;
  final VoidCallback onRetry;
  final Widget Function(BuildContext, T, int) itemBuilder;
  final Widget Function(BuildContext, int) skeletonBuilder;

  const MobileListContent({
    super.key,
    required this.isLoading,
    required this.isInitialLoad,
    required this.hasError,
    this.errorMessage,
    required this.items,
    required this.displayedItems,
    required this.hasMoreToLoad,
    required this.remainingCount,
    required this.emptyStateConfig,
    required this.onRefresh,
    required this.onLoadMore,
    required this.onRetry,
    required this.itemBuilder,
    required this.skeletonBuilder,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading && isInitialLoad) {
      return MobileLoadingState(
        itemCount: 5,
        skeletonBuilder: skeletonBuilder,
      );
    }

    if (isLoading && !isInitialLoad) {
      return Center(
        child: CircularProgressIndicator(color: AppColors.green100),
      );
    }

    if (hasError) {
      return MobileErrorState(
        message: errorMessage ?? 'An error occurred',
        onRetry: onRetry,
      );
    }

    if (displayedItems.isEmpty) {
      return MobileEmptyState(
        icon: emptyStateConfig.icon,
        message: emptyStateConfig.message,
        actionLabel: emptyStateConfig.actionLabel,
        onAction: emptyStateConfig.onAction,
      );
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      color: AppColors.green100,
      child: ListView.builder(
        padding: EdgeInsets.zero,
        itemCount: displayedItems.length + (hasMoreToLoad ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == displayedItems.length) {
            return MobileLoadMoreButton(
              remainingCount: remainingCount,
              onPressed: onLoadMore,
            );
          }

          return itemBuilder(context, displayedItems[index], index);
        },
      ),
    );
  }
}