import 'package:flutter/material.dart';
import 'package:flutter_application_1/ui/core/themes/app_theme.dart';
import 'package:flutter_application_1/ui/core/themes/web_colors.dart';
import 'package:shimmer/shimmer.dart';

class SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color iconBackgroundColor;
  final Color iconForegroundColor;
  final bool isLoading;
  final bool isExpanded;

  const SummaryCard({
    super.key,
    required this.title,
    required this.value,
    required this.iconBackgroundColor,
    required this.iconForegroundColor,
    required this.icon,
    this.isLoading = false,
    this.isExpanded = true,
  });

  @override
  Widget build(BuildContext context) {
    final isTablet =
        MediaQuery.of(context).size.width >= kTabletBreakpoint &&
        MediaQuery.of(context).size.width < kDesktopBreakpoint;

    final card = isLoading
        ? _buildShimmerCard(isTablet)
        : Tooltip(
            message: "$title: $value",
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.background2,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: WebColors.cardBorder, width: 1),
                boxShadow: [
                  BoxShadow(
                    color: WebColors.cardShadow,
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!isTablet) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [_buildTitle(), _buildIcon()],
                    ),
                  ],
                  const SizedBox(height: 4),
                  !isTablet
                      ? _buildValue()
                      : Row(
                          children: [
                            _buildTitle(),
                            SizedBox(width: 10),
                            _buildValue(),
                          ],
                        ),
                  const SizedBox(height: 5),
                ],
              ),
            ),
          );

    return isExpanded ? Expanded(child: card) : card;
  }

  Widget _buildShimmerCard(bool isTablet) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.background2,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: WebColors.cardBorder, width: 1),
        boxShadow: [
          BoxShadow(
            color: WebColors.cardShadow,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isTablet) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _shimmerTitle(width: 120, height: 16),
                  _shimmerIcon(),
                ],
              ),
            ],
            const SizedBox(height: 4),
            !isTablet
                ? _shimmerValue()
                : Row(
                    children: [
                      _shimmerTitle(width: 100, height: 14),
                      const SizedBox(width: 10),
                      _shimmerValue(),
                    ],
                  ),
          ],
        ),
      ),
    );
  }

  // Shimmer blocks matching your real content
  Widget _shimmerTitle({required double width, required double height}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  Widget _shimmerIcon() {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }

  Widget _shimmerValue() {
    return Container(
      width: 60,
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  Widget _buildIcon() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: iconBackgroundColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, size: 20, color: iconForegroundColor),
    );
  }

  Widget _buildValue() {
    return Text(
      value,
      style: const TextStyle(
        fontSize: 48,
        fontWeight: FontWeight.w700,
        color: WebColors.textHeading,
        height: 1.1,
      ),
    );
  }

  Widget _buildTitle() {
    return Expanded(
      child: Text(
        title,
        style: TextStyle(
          color: WebColors.textLabel,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
