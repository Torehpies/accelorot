// lib/ui/core/widgets/sample_cards/data_card_skeleton.dart
import 'package:flutter/material.dart';
import '../../themes/app_theme.dart';

/// Reusable skeleton loader for DataCard
/// Matches the exact layout and styling of DataCard using Card widget
/// Includes horizontal padding to match real card wrapper
class DataCardSkeleton extends StatelessWidget {
  final bool showDescription;
  final double bottomPadding;

  const DataCardSkeleton({
    super.key,
    this.showDescription = true,
    this.bottomPadding = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        bottom: bottomPadding,
      ),
      child: Card(
        color: AppColors.background2,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: AppColors.grey, width: 1.5),
        ),
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon skeleton - circular to match DataCard
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.grey,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title skeleton - original size
                    Container(
                      width: double.infinity,
                      height: 16,
                      decoration: BoxDecoration(
                        color: AppColors.grey,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    // Description skeleton - conditional
                    if (showDescription) ...[
                      const SizedBox(height: 8),
                      Container(
                        width: 200,
                        height: 14,
                        decoration: BoxDecoration(
                          color: AppColors.grey,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),
                    // Status pill skeleton - original size
                    Container(
                      width: 80,
                      height: 24,
                      decoration: BoxDecoration(
                        color: AppColors.grey,
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
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