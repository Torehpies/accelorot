import 'package:flutter/material.dart';

/// Data model for stat card
class StatCardData {
  final String label;
  final String count;
  final String change;
  final String subtext;
  final Color color;
  final Color lightColor;
  final IconData icon;

  const StatCardData({
    required this.label,
    required this.count,
    required this.change,
    required this.subtext,
    required this.color,
    required this.lightColor,
    required this.icon,
  });
}

/// Fully Responsive stat card widget - optimized for row layout
class StatCardWidget extends StatelessWidget {
  final StatCardData data;

  const StatCardWidget({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Determine the screen breakpoints
        final screenWidth = MediaQuery.of(context).size.width;
        final isDesktop = screenWidth > 1200;
        final isTablet = screenWidth > 768 && screenWidth <= 1200;
        final isMobile = screenWidth <= 768;
        
        // Adjust sizes based on screen size and card width
        final cardWidth = constraints.maxWidth;
        final isNarrow = cardWidth < 180;
        
        final cardPadding = isDesktop ? 20.0 : (isTablet ? 16.0 : (isNarrow ? 12.0 : 14.0));
        final iconContainerSize = isDesktop ? 40.0 : (isTablet ? 36.0 : (isNarrow ? 28.0 : 32.0));
        final iconSize = isDesktop ? 20.0 : (isTablet ? 18.0 : (isNarrow ? 14.0 : 16.0));
        final countFontSize = isDesktop ? 32.0 : (isTablet ? 28.0 : (isNarrow ? 22.0 : 24.0));
        final labelFontSize = isDesktop ? 13.0 : (isTablet ? 12.0 : (isNarrow ? 10.0 : 11.0));
        final subtextFontSize = isDesktop ? 11.0 : (isTablet ? 10.0 : (isNarrow ? 9.0 : 10.0));
        final changeFontSize = isDesktop ? 11.0 : (isTablet ? 10.0 : (isNarrow ? 9.0 : 10.0));
        
        final isPositive = data.change.startsWith('+');

        return Container(
          padding: EdgeInsets.all(cardPadding),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(isDesktop ? 16 : (isTablet ? 14 : 12)),
            border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha((0.04 * 255).toInt()),
                blurRadius: isDesktop ? 20 : (isTablet ? 16 : 12),
                offset: Offset(0, isDesktop ? 4 : 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header row with label and icon
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      data.label,
                      style: TextStyle(
                        fontSize: labelFontSize,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF6B7280),
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(width: isNarrow ? 6 : 8),
                  Container(
                    width: iconContainerSize,
                    height: iconContainerSize,
                    decoration: BoxDecoration(
                      color: data.lightColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      data.icon,
                      size: iconSize,
                      color: data.color,
                    ),
                  ),
                ],
              ),
              
              SizedBox(height: isDesktop ? 14 : (isTablet ? 12 : 10)),
              
              // Count - with better scaling
              LayoutBuilder(
                builder: (context, constraints) {
                  return FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      data.count,
                      style: TextStyle(
                        fontSize: countFontSize,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1F2937),
                        height: 1,
                        letterSpacing: -0.5,
                      ),
                    ),
                  );
                },
              ),
              
              SizedBox(height: isDesktop ? 10 : (isTablet ? 9 : 8)),
              
              // Change and subtext - optimized for narrow cards
              if (isNarrow)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: isPositive
                            ? const Color(0xFFD1FAE5)
                            : const Color(0xFFFEE2E2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        data.change,
                        style: TextStyle(
                          fontSize: changeFontSize,
                          fontWeight: FontWeight.w600,
                          color: isPositive
                              ? const Color(0xFF065F46)
                              : const Color(0xFF991B1B),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      data.subtext,
                      style: TextStyle(
                        fontSize: subtextFontSize,
                        color: const Color(0xFF9CA3AF),
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                )
              else
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: isMobile ? 6 : 8,
                        vertical: isMobile ? 3 : 4,
                      ),
                      decoration: BoxDecoration(
                        color: isPositive
                            ? const Color(0xFFD1FAE5)
                            : const Color(0xFFFEE2E2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        data.change,
                        style: TextStyle(
                          fontSize: changeFontSize,
                          fontWeight: FontWeight.w600,
                          color: isPositive
                              ? const Color(0xFF065F46)
                              : const Color(0xFF991B1B),
                        ),
                      ),
                    ),
                    Flexible(
                      child: Text(
                        data.subtext,
                        style: TextStyle(
                          fontSize: subtextFontSize,
                          color: const Color(0xFF9CA3AF),
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }
}