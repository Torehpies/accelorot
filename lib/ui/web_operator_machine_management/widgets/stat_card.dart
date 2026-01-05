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
        
        // 👇 Reduced padding to save space
        final cardPadding = isDesktop ? 16.0 : (isTablet ? 14.0 : (isNarrow ? 10.0 : 12.0));
        
        // 👇 Smaller icon sizes
        final iconContainerSize = isDesktop ? 36.0 : (isTablet ? 32.0 : (isNarrow ? 26.0 : 28.0));
        final iconSize = isDesktop ? 18.0 : (isTablet ? 16.0 : (isNarrow ? 13.0 : 14.0));
        
        // 👇 Reduced font sizes
        final countFontSize = isDesktop ? 28.0 : (isTablet ? 24.0 : (isNarrow ? 20.0 : 22.0));
        final labelFontSize = isDesktop ? 12.0 : (isTablet ? 11.0 : (isNarrow ? 9.5 : 10.0));
        final subtextFontSize = isDesktop ? 10.0 : (isTablet ? 9.5 : (isNarrow ? 8.5 : 9.0));
        final changeFontSize = isDesktop ? 10.0 : (isTablet ? 9.5 : (isNarrow ? 8.5 : 9.0));
        
        final isPositive = data.change.startsWith('+');
        
        // 👇 Decreased card height
        final cardHeight = isDesktop ? 130.0 : (isTablet ? 120.0 : (isNarrow ? 105.0 : 90.0));

        return SizedBox(
          height: cardHeight,
          child: Container(
            padding: EdgeInsets.all(cardPadding),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(isDesktop ? 14 : (isTablet ? 12 : 10)),
              border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha((0.04 * 255).toInt()),
                  blurRadius: isDesktop ? 16 : (isTablet ? 12 : 10),
                  offset: Offset(0, isDesktop ? 3 : 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF6B7280),
                          height: 1.2,
                        ),
                        maxLines: 1, // 👈 Single line to save space
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(width: isNarrow ? 4 : 6), // 👈 Reduced spacing
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
                
                // 👇 Reduced spacing
                SizedBox(height: isDesktop ? 6 : (isTablet ? 5 : 4)),
                
                // Count - with better scaling
                FittedBox(
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
                ),
                
                // 👇 Reduced spacing
                SizedBox(height: isDesktop ? 6 : (isTablet ? 5 : 4)),
                
                // Change and subtext - optimized for narrow cards
                if (isNarrow)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min, // 👈 Don't take extra space
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), // 👈 Reduced padding
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
                      const SizedBox(height: 3), // 👈 Reduced spacing
                      Text(
                        data.subtext,
                        style: TextStyle(
                          fontSize: subtextFontSize,
                          color: const Color(0xFF9CA3AF),
                          height: 1.2,
                        ),
                        maxLines: 1, // 👈 Single line
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  )
                else
                  Wrap(
                    spacing: 6,
                    runSpacing: 3, // 👈 Reduced spacing
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: isMobile ? 6 : 8,
                          vertical: isMobile ? 2 : 3, // 👈 Reduced padding
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
                            height: 1.2,
                          ),
                          maxLines: 1, // 👈 Single line
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}