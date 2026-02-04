// lib/ui/landing_page/widgets/impact_section.dart

import 'package:flutter/material.dart';
import '../../core/constants/spacing.dart';
import '../../core/themes/web_text_styles.dart';
import '../../core/themes/web_colors.dart';
import '../models/impact_stat_model.dart';
import 'dart:math' as math;

class ImpactSection extends StatefulWidget {
  final List<ImpactStatModel> stats;
  const ImpactSection({
    super.key,
    required this.stats,
  });

  @override
  State<ImpactSection> createState() => _ImpactSectionState();
}

class _ImpactSectionState extends State<ImpactSection> with SingleTickerProviderStateMixin {
  int? _expandedIndex;
  int _currentExpandedInfo = 0;
  late AnimationController _swipeAnimationController;
  late Animation<double> _swipeAnimation;
  final Map<String, bool> _impactItemHover = {};

  // Map for impact item descriptions
  final Map<String, String> _impactDescriptions = {
    'Reduces landfill waste': 'Addresses the pressing environmental concern in the Philippines where over 50% of municipal solid waste is organic. Prevents methane emissions from landfills that contribute to climate change.',
    'Produces nutrient-rich compost': 'Transforms organic waste into high-quality compost through accelerated decomposition. Improves soil health and reduces need for chemical fertilizers in agriculture.',
    'Empowers communities': 'Supports Republic Act 9003 implementation by providing accessible composting technology. Reduces manual labor and makes sustainable waste management practical for households and communities.',
  };

  @override
  void initState() {
    super.initState();
    _swipeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _swipeAnimation = CurvedAnimation(
      parent: _swipeAnimationController,
      curve: Curves.easeInOut,
    );
    // Initialize hover states
    _impactItemHover['Reduces landfill waste'] = false;
    _impactItemHover['Produces nutrient-rich compost'] = false;
    _impactItemHover['Empowers communities'] = false;
  }

  @override
  void dispose() {
    _swipeAnimationController.dispose();
    super.dispose();
  }

  void _swipeToNext() {
    if (_expandedIndex == null) return;
    _swipeAnimationController.forward(from: 0).then((_) {
      setState(() {
        _currentExpandedInfo = (_currentExpandedInfo + 1) % 4;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: _getResponsivePadding(context),
      color: Colors.white,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final screenWidth = constraints.maxWidth;
          if (widget.stats.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (screenWidth < 600) {
            return _buildMobileLayout(context, screenWidth);
          } else if (screenWidth < 1024) {
            return _buildTabletLayout(context, screenWidth);
          } else {
            return _buildDesktopLayout(context, screenWidth);
          }
        },
      ),
    );
  }

  EdgeInsets _getResponsivePadding(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < 600) {
      return const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xl,
      );
    } else if (screenWidth < 1024) {
      return const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.xxl,
      );
    } else {
      return const EdgeInsets.symmetric(
        horizontal: AppSpacing.xxl,
        vertical: AppSpacing.xxxl,
      );
    }
  }

  // ===================== MOBILE LAYOUT (<600px) =====================
  Widget _buildMobileLayout(BuildContext context, double screenWidth) {
    final isSmallMobile = screenWidth < 400;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'MAKING A SUSTAINABLE IMPACT',
          textAlign: TextAlign.left,
          style: WebTextStyles.h2.copyWith(
            fontSize: isSmallMobile ? 26 : 28,
            fontWeight: FontWeight.w700,
            color: WebColors.textTitle,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          'In the Philippines, over 50% of municipal solid waste is organic.\nAccel-O-Rot helps manage waste responsibly.',
          textAlign: TextAlign.left,
          style: WebTextStyles.sectionSubtitle.copyWith(
            fontSize: isSmallMobile ? 14 : 15,
            height: 1.4,
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        // Impact items with variable height
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildMobileImpactItem(Icons.delete_outline, 'Reduces landfill waste', screenWidth),
            const SizedBox(height: AppSpacing.md),
            _buildMobileImpactItem(Icons.restaurant_outlined, 'Produces nutrient-rich compost', screenWidth),
            const SizedBox(height: AppSpacing.md),
            _buildMobileImpactItem(Icons.eco_outlined, 'Empowers communities', screenWidth),
          ],
        ),
        const SizedBox(height: AppSpacing.xl),
        // Grid for mobile
        _buildMobileGrid(screenWidth),
      ],
    );
  }

  Widget _buildMobileImpactItem(IconData icon, String text, double screenWidth) {
    final isHovered = _impactItemHover[text] ?? false;
    final isSmallMobile = screenWidth < 400;
    
    // Calculate text height for description
    final textPainter = TextPainter(
      text: TextSpan(
        text: _impactDescriptions[text],
        style: TextStyle(
          fontSize: isSmallMobile ? 12 : 13,
          height: 1.4,
        ),
      ),
      textDirection: TextDirection.ltr,
      maxLines: 3,
    );
    textPainter.layout(maxWidth: screenWidth - AppSpacing.md * 2);
    final descriptionHeight = textPainter.size.height;
    
    // Base height + description height when expanded
    final baseHeight = isSmallMobile ? 70.0 : 80.0;
    final expandedHeight = baseHeight + descriptionHeight + AppSpacing.md - 8;

    return MouseRegion(
      onEnter: (_) => setState(() => _impactItemHover[text] = true),
      onExit: (_) => setState(() => _impactItemHover[text] = false),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: AnimatedSize(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          alignment: Alignment.topCenter,
          child: Container(
            width: double.infinity,
            constraints: BoxConstraints(
              minHeight: baseHeight,
              maxHeight: isHovered ? expandedHeight : baseHeight,
            ),
            padding: EdgeInsets.symmetric(
              vertical: AppSpacing.md,
              horizontal: AppSpacing.md,
            ),
            decoration: BoxDecoration(
              color: isHovered
                  ? const Color.fromARGB(20, 118, 230, 207)
                  : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isHovered
                    ? WebColors.greenLight
                    : const Color(0xFFE8F5E9),
                width: isHovered ? 2 : 1,
              ),
              boxShadow: isHovered
                  ? [
                      BoxShadow(
                        color: const Color.fromARGB(25, 118, 230, 207),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                        spreadRadius: 1,
                      ),
                    ]
                  : [
                      BoxShadow(
                        color: const Color.fromARGB(10, 0, 0, 0),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: isHovered ? 36 : 32,
                      height: isHovered ? 36 : 32,
                      decoration: BoxDecoration(
                        color: isHovered
                            ? WebColors.greenLight
                            : const Color.fromARGB(38, 40, 168, 90),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        icon,
                        size: isHovered ? 18 : 16,
                        color: isHovered
                            ? Colors.white
                            : const Color(0xFF28A85A),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 300),
                        style: TextStyle(
                          fontSize: isHovered ? 16 : 15,
                          fontWeight: isHovered ? FontWeight.w700 : FontWeight.w600,
                          color: isHovered
                              ? WebColors.textTitle
                              : const Color(0xFF444444),
                        ),
                        child: Text(text),
                      ),
                    ),
                  ],
                ),
                // Description expands downward with full content + fade
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  switchInCurve: Curves.easeOut,
                  switchOutCurve: Curves.easeIn,
                  transitionBuilder: (child, animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: child,
                    );
                  },
                  child: (isHovered && _impactDescriptions.containsKey(text))
                      ? Padding(
                          key: ValueKey<String>('mobile_impact_$text'),
                          padding: const EdgeInsets.only(top: AppSpacing.sm, left: 44.0),
                          child: Text(
                            _impactDescriptions[text]!,
                            style: TextStyle(
                              fontSize: isSmallMobile ? 12 : 13,
                              color: const Color(0xFF666666),
                              height: 1.4,
                            ),
                            maxLines: 3,
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMobileGrid(double screenWidth) {
    if (widget.stats.length < 4) {
      return const SizedBox();
    }
    final isSmallMobile = screenWidth < 400;
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: AppSpacing.md,
        crossAxisSpacing: AppSpacing.md,
        childAspectRatio: isSmallMobile ? 1.1 : 1.2,
      ),
      itemCount: widget.stats.length,
      itemBuilder: (context, index) {
        return _buildMobileStatCard(index, widget.stats[index], screenWidth);
      },
    );
  }

  Widget _buildMobileStatCard(int index, ImpactStatModel stat, double screenWidth) {
    final isSmallMobile = screenWidth < 400;
    final row = index ~/ 2;
    final col = index % 2;
    final isGreen = (row == 0 && col == 0) || (row == 1 && col == 1);
    final isHovered = _expandedIndex == index;
    final displayValue = _displayValue(stat);
    final isWeekStat = _isWeekStat(stat);
    final weekNumber = _weekNumber(stat);
    final weekLabel = _weekLabel(stat);
    
    // Calculate extra height needed for hover description
    final hoverDescription = _getMobileStatDescription(index, stat);

    return MouseRegion(
      onEnter: (_) => setState(() => _expandedIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: isGreen
              ? const Color.fromARGB(255, 74, 211, 126)
              : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isHovered
                ? (isGreen ? Colors.transparent : WebColors.greenLight)
                : (isGreen ? Colors.transparent : const Color(0xFFE0E0E0)),
            width: isHovered ? 2 : 1,
          ),
          boxShadow: isHovered
              ? [
                  BoxShadow(
                    color: const Color.fromARGB(25, 0, 0, 0),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [
                  BoxShadow(
                    color: const Color.fromARGB(10, 0, 0, 0),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isWeekStat)
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          weekNumber,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: isSmallMobile ? 32 : 36,
                            fontWeight: FontWeight.w800,
                            color: isGreen ? Colors.white : WebColors.textTitle,
                            height: 0.9,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          weekLabel,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: isSmallMobile ? 24 : 26,
                            fontWeight: FontWeight.w600,
                            color: isGreen ? Colors.white : WebColors.textTitle,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Composting Time',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: isSmallMobile ? 13 : 14,
                        fontWeight: FontWeight.w500,
                        color: isGreen ? Colors.white : const Color(0xFF666666),
                      ),
                    ),
                    // Additional info on hover for mobile with fade
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      switchInCurve: Curves.easeOut,
                      switchOutCurve: Curves.easeIn,
                      transitionBuilder: (child, animation) {
                        return FadeTransition(
                          opacity: animation,
                          child: child,
                        );
                      },
                      child: isHovered
                          ? Padding(
                              key: const ValueKey<String>('mobile_stat_week_hover'),
                              padding: const EdgeInsets.only(top: 8),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
                                child: Text(
                                  hoverDescription,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: isSmallMobile ? 11 : 12,
                                    color: isGreen ? Colors.white : const Color(0xFF888888),
                                    height: 1.3,
                                  ),
                                  maxLines: 2,
                                ),
                              ),
                            )
                          : const SizedBox.shrink(),
                    ),
                  ],
                )
              else
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      displayValue,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: isSmallMobile ? 28 : 32,
                        fontWeight: FontWeight.w800,
                        color: isGreen ? Colors.white : WebColors.textTitle,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
                      child: Text(
                        stat.label,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: isSmallMobile ? 13 : 14,
                          fontWeight: FontWeight.w600,
                          color: isGreen ? Colors.white : const Color(0xFF666666),
                          height: 1.1,
                        ),
                      ),
                    ),
                    // Additional info on hover for mobile with fade
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      switchInCurve: Curves.easeOut,
                      switchOutCurve: Curves.easeIn,
                      transitionBuilder: (child, animation) {
                        return FadeTransition(
                          opacity: animation,
                          child: child,
                        );
                      },
                      child: isHovered
                          ? Padding(
                              key: const ValueKey<String>('mobile_stat_label_hover'),
                              padding: const EdgeInsets.only(top: 8),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
                                child: Text(
                                  hoverDescription,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: isSmallMobile ? 11 : 12,
                                    color: isGreen ? Colors.white : const Color(0xFF888888),
                                    height: 1.3,
                                  ),
                                  maxLines: 2,
                                ),
                              ),
                            )
                          : const SizedBox.shrink(),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  // ===================== TABLET LAYOUT (600-1024px) =====================
  Widget _buildTabletLayout(BuildContext context, double screenWidth) {
    final isSmallTablet = screenWidth < 800;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'MAKING A SUSTAINABLE IMPACT',
          style: WebTextStyles.h2.copyWith(
            fontSize: isSmallTablet ? 32 : 36,
            fontWeight: FontWeight.w700,
            color: WebColors.textTitle,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          'In the Philippines, over 50% of municipal solid waste is organic.\nAccel-O-Rot helps manage waste responsibly.',
          style: WebTextStyles.sectionSubtitle.copyWith(
            fontSize: isSmallTablet ? 16 : 18,
            height: 1.5,
          ),
        ),
        const SizedBox(height: AppSpacing.xl * 1.5),
        // Impact items
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildTabletImpactItem(Icons.delete_outline, 'Reduces landfill waste', screenWidth),
            const SizedBox(height: AppSpacing.lg),
            _buildTabletImpactItem(Icons.restaurant_outlined, 'Produces nutrient-rich compost', screenWidth),
            const SizedBox(height: AppSpacing.lg),
            _buildTabletImpactItem(Icons.eco_outlined, 'Empowers communities', screenWidth),
          ],
        ),
        const SizedBox(height: AppSpacing.xl * 1.5),
        // Grid for tablet
        _buildTabletGrid(screenWidth),
      ],
    );
  }

  Widget _buildTabletImpactItem(IconData icon, String text, double screenWidth) {
    final isHovered = _impactItemHover[text] ?? false;
    final isSmallTablet = screenWidth < 800;
    
    // Calculate text height for description
    final textPainter = TextPainter(
      text: TextSpan(
        text: _impactDescriptions[text],
        style: TextStyle(
          fontSize: isSmallTablet ? 14 : 15,
          height: 1.5,
        ),
      ),
      textDirection: TextDirection.ltr,
      maxLines: 3,
    );
    textPainter.layout(maxWidth: screenWidth - AppSpacing.xl * 2);
    final descriptionHeight = textPainter.size.height;
    
    // Base height + description height when expanded
    final baseHeight = isSmallTablet ? 90.0 : 100.0;
    final expandedHeight = baseHeight + descriptionHeight + AppSpacing.lg - 8;

    return MouseRegion(
      onEnter: (_) => setState(() => _impactItemHover[text] = true),
      onExit: (_) => setState(() => _impactItemHover[text] = false),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: AnimatedSize(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          alignment: Alignment.topCenter,
          child: Container(
            width: double.infinity,
            constraints: BoxConstraints(
              minHeight: baseHeight,
              maxHeight: isHovered ? expandedHeight : baseHeight,
            ),
            padding: EdgeInsets.symmetric(
              vertical: AppSpacing.lg,
              horizontal: AppSpacing.lg,
            ),
            decoration: BoxDecoration(
              color: isHovered
                  ? const Color.fromARGB(20, 118, 230, 207)
                  : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isHovered
                    ? WebColors.greenLight
                    : const Color(0xFFE8F5E9),
                width: isHovered ? 2.5 : 1.5,
              ),
              boxShadow: isHovered
                  ? [
                      BoxShadow(
                        color: const Color.fromARGB(30, 118, 230, 207),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                        spreadRadius: 1,
                      ),
                    ]
                  : [
                      BoxShadow(
                        color: const Color.fromARGB(12, 0, 0, 0),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: isHovered ? 44 : 40,
                      height: isHovered ? 44 : 40,
                      decoration: BoxDecoration(
                        color: isHovered
                            ? WebColors.greenLight
                            : const Color.fromARGB(51, 40, 168, 90),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        icon,
                        size: isHovered ? 22 : 20,
                        color: isHovered
                            ? Colors.white
                            : const Color(0xFF28A85A),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 300),
                        style: TextStyle(
                          fontSize: isHovered ? 18 : 17,
                          fontWeight: isHovered ? FontWeight.w700 : FontWeight.w600,
                          color: isHovered
                              ? WebColors.textTitle
                              : const Color(0xFF444444),
                        ),
                        child: Text(text),
                      ),
                    ),
                  ],
                ),
                // Description expands downward within expanding container + fade
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  switchInCurve: Curves.easeOut,
                  switchOutCurve: Curves.easeIn,
                  transitionBuilder: (child, animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: child,
                    );
                  },
                  child: (isHovered && _impactDescriptions.containsKey(text))
                      ? Padding(
                          key: ValueKey<String>('tablet_impact_$text'),
                          padding: const EdgeInsets.only(top: AppSpacing.md, left: 56.0),
                          child: Text(
                            _impactDescriptions[text]!,
                            style: TextStyle(
                              fontSize: isSmallTablet ? 14 : 15,
                              color: const Color(0xFF666666),
                              height: 1.5,
                            ),
                            maxLines: 3,
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabletGrid(double screenWidth) {
    if (widget.stats.length < 4) {
      return const SizedBox();
    }
    final isSmallTablet = screenWidth < 800;
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: AppSpacing.lg,
        crossAxisSpacing: AppSpacing.lg,
        childAspectRatio: isSmallTablet ? 1.3 : 1.4,
      ),
      itemCount: widget.stats.length,
      itemBuilder: (context, index) {
        return _buildTabletStatCard(index, widget.stats[index], screenWidth);
      },
    );
  }

  Widget _buildTabletStatCard(int index, ImpactStatModel stat, double screenWidth) {
    final isSmallTablet = screenWidth < 800;
    final row = index ~/ 2;
    final col = index % 2;
    final isGreen = (row == 0 && col == 0) || (row == 1 && col == 1);
    final isHovered = _expandedIndex == index;
    final displayValue = _displayValue(stat);
    final isWeekStat = _isWeekStat(stat);
    final weekNumber = _weekNumber(stat);
    final weekLabel = _weekLabel(stat);
    
    // Calculate extra height needed for hover description
    final hoverDescription = _getTabletStatDescription(index, stat);

    return MouseRegion(
      onEnter: (_) => setState(() => _expandedIndex = index),
      onExit: (_) => setState(() => _expandedIndex = null),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: isGreen
              ? const Color.fromARGB(255, 74, 211, 126)
              : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isHovered
                ? (isGreen ? Colors.transparent : WebColors.greenLight)
                : (isGreen ? Colors.transparent : const Color(0xFFE0E0E0)),
            width: isHovered ? 2.5 : 1.5,
          ),
          boxShadow: isHovered
              ? [
                  BoxShadow(
                    color: const Color.fromARGB(30, 0, 0, 0),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ]
              : [
                  BoxShadow(
                    color: const Color.fromARGB(15, 0, 0, 0),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isWeekStat)
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          weekNumber,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: isSmallTablet ? 42 : 48,
                            fontWeight: FontWeight.w800,
                            color: isGreen ? Colors.white : WebColors.textTitle,
                            height: 0.9,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          weekLabel,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: isSmallTablet ? 32 : 36,
                            fontWeight: FontWeight.w600,
                            color: isGreen ? Colors.white : WebColors.textTitle,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Composting Time',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: isSmallTablet ? 16 : 18,
                        fontWeight: FontWeight.w500,
                        color: isGreen ? Colors.white : const Color(0xFF666666),
                      ),
                    ),
                    // Additional info on hover for tablet with fade
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      switchInCurve: Curves.easeOut,
                      switchOutCurve: Curves.easeIn,
                      transitionBuilder: (child, animation) {
                        return FadeTransition(
                          opacity: animation,
                          child: child,
                        );
                      },
                      child: isHovered
                          ? Padding(
                              key: const ValueKey<String>('tablet_week_hover'),
                              padding: const EdgeInsets.only(top: 12),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                                child: Text(
                                  hoverDescription,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: isSmallTablet ? 14 : 15,
                                    color: isGreen ? Colors.white : const Color(0xFF888888),
                                    height: 1.4,
                                  ),
                                  maxLines: 3,
                                ),
                              ),
                            )
                          : const SizedBox.shrink(),
                    ),
                  ],
                )
              else
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      displayValue,
                      style: TextStyle(
                        fontSize: isSmallTablet ? 40 : 44,
                        fontWeight: FontWeight.w800,
                        color: isGreen ? Colors.white : WebColors.textTitle,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                      child: Text(
                        stat.label,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: isSmallTablet ? 16 : 18,
                          fontWeight: FontWeight.w600,
                          color: isGreen ? Colors.white : const Color(0xFF666666),
                          height: 1.1,
                        ),
                      ),
                    ),
                    // Additional info on hover for tablet with fade
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      switchInCurve: Curves.easeOut,
                      switchOutCurve: Curves.easeIn,
                      transitionBuilder: (child, animation) {
                        return FadeTransition(
                          opacity: animation,
                          child: child,
                        );
                      },
                      child: isHovered
                          ? Padding(
                              key: const ValueKey<String>('tablet_label_hover'),
                              padding: const EdgeInsets.only(top: 12),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                                child: Text(
                                  hoverDescription,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: isSmallTablet ? 14 : 15,
                                    color: isGreen ? Colors.white : const Color(0xFF888888),
                                    height: 1.4,
                                  ),
                                  maxLines: 3,
                                ),
                              ),
                            )
                          : const SizedBox.shrink(),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  // ===================== DESKTOP LAYOUT (>1024px) =====================
  Widget _buildDesktopLayout(BuildContext context, double screenWidth) {
    final isLargeDesktop = screenWidth > 1440;
    final impactListOffset = isLargeDesktop ? 126.0 : 114.0;
    if (widget.stats.length < 4) {
      return const Center(child: CircularProgressIndicator());
    }
    
    return Container(
      constraints: BoxConstraints(
        minHeight: 600, // Minimum height for desktop
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left side: Title and 3 impact items
          Expanded(
            flex: isLargeDesktop ? 4 : 3,
            child: Padding(
              padding: EdgeInsets.only(
                right: isLargeDesktop ? AppSpacing.xl * 2 : AppSpacing.xl,
                left: isLargeDesktop ? AppSpacing.xxxl : AppSpacing.xxl,
                top: AppSpacing.xxl,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'MAKING A SUSTAINABLE IMPACT',
                    style: WebTextStyles.h2.copyWith(
                      fontSize: isLargeDesktop ? 40 : 36,
                      fontWeight: FontWeight.w700,
                      color: WebColors.textTitle,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  SizedBox(
                    width: double.infinity,
                    child: Text(
                      'In the Philippines, over 50% of municipal solid waste is organic.\nAccel-O-Rot helps manage waste responsibly.',
                      style: WebTextStyles.sectionSubtitle.copyWith(
                        fontSize: isLargeDesktop ? 16 : 15,
                        height: 1.6,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl * 2),
                  // Impact items with expanded height
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDesktopImpactItem(Icons.delete_outline, 'Reduces landfill waste', screenWidth),
                      const SizedBox(height: AppSpacing.lg),
                      _buildDesktopImpactItem(Icons.restaurant_outlined, 'Produces nutrient-rich compost', screenWidth),
                      const SizedBox(height: AppSpacing.lg),
                      _buildDesktopImpactItem(Icons.eco_outlined, 'Empowers communities', screenWidth),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                ],
              ),
            ),
          ),
          // Right side: 4 stat cards
          Expanded(
            flex: isLargeDesktop ? 5 : 4,
            child: Padding(
              padding: EdgeInsets.only(
                left: AppSpacing.xl,
                right: isLargeDesktop ? AppSpacing.xxxl * 2 : AppSpacing.xxxl,
                top: AppSpacing.xxl,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: impactListOffset),
                  Align(
                    alignment: Alignment.topCenter,
                    child: MouseRegion(
                      onExit: (_) => setState(() {
                        _expandedIndex = null;
                        _currentExpandedInfo = 0;
                      }),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: isLargeDesktop ? 620 : 520,
                        ),
                        child: SizedBox(
                          width: double.infinity,
                          height: 400,
                          child: Stack(
                            alignment: Alignment.center,
                          children: [
                            IgnorePointer(
                              ignoring: _expandedIndex != null,
                              child: AnimatedOpacity(
                                duration: const Duration(milliseconds: 1000),
                                curve: Curves.easeInOut,
                                opacity: _expandedIndex == null ? 1.0 : 0.0,
                                child: _buildDesktopGrid(screenWidth),
                              ),
                            ),
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 600),
                                reverseDuration: const Duration(milliseconds: 600),
                                switchInCurve: Curves.easeOutCubic,
                                switchOutCurve: Curves.easeInCubic,
                                transitionBuilder: (child, animation) {
                                  final fade = CurvedAnimation(
                                    parent: animation,
                                    curve: Curves.easeOutCubic,
                                  );
                                  final scale = Tween<double>(begin: 0.98, end: 1.0).animate(fade);
                                  return FadeTransition(
                                    opacity: fade,
                                    child: ScaleTransition(
                                      scale: scale,
                                      child: child,
                                    ),
                                  );
                                },
                                child: (_expandedIndex != null && _expandedIndex! < widget.stats.length)
                                    ? KeyedSubtree(
                                        key: ValueKey<int>(_expandedIndex!),
                                        child: _buildExpandedDesktopCard(_expandedIndex!, screenWidth),
                                      )
                                    : const SizedBox.shrink(),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopImpactItem(IconData icon, String text, double screenWidth) {
    final isHovered = _impactItemHover[text] ?? false;
    final maxItemWidth = screenWidth > 1440 ? 420.0 : 360.0;
    
    // Base height for the collapsed state
    final baseHeight = 66.0;

    return MouseRegion(
      onEnter: (_) => setState(() => _impactItemHover[text] = true),
      onExit: (_) => setState(() => _impactItemHover[text] = false),
      child: Align(
        alignment: Alignment.centerLeft,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxItemWidth),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              alignment: Alignment.topCenter,
              child: Container(
                width: double.infinity,
                constraints: BoxConstraints(minHeight: baseHeight),
                padding: EdgeInsets.symmetric(
                  vertical: AppSpacing.sm,
                  horizontal: AppSpacing.md,
                ),
                decoration: BoxDecoration(
                  color: isHovered
                      ? const Color.fromARGB(20, 118, 230, 207)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isHovered
                        ? WebColors.greenLight
                        : const Color(0xFFE8F5E9),
                    width: isHovered ? 2.0 : 1.25,
                  ),
                  boxShadow: isHovered
                      ? [
                          BoxShadow(
                            color: const Color.fromARGB(26, 118, 230, 207),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                            spreadRadius: 1,
                          ),
                        ]
                      : [
                          BoxShadow(
                            color: const Color.fromARGB(10, 0, 0, 0),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: isHovered ? 34 : 30,
                          height: isHovered ? 34 : 30,
                          decoration: BoxDecoration(
                            color: isHovered
                                ? WebColors.greenLight
                                : const Color.fromARGB(51, 40, 168, 90),
                            borderRadius: BorderRadius.circular(9),
                          ),
                          child: Icon(
                            icon,
                            size: isHovered ? 17 : 15,
                            color: isHovered
                                ? Colors.white
                                : const Color(0xFF28A85A),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Expanded(
                          child: AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 300),
                            style: TextStyle(
                              fontSize: isHovered
                                  ? (screenWidth > 1440 ? 14 : 13)
                                  : (screenWidth > 1440 ? 13 : 12),
                              fontWeight: isHovered ? FontWeight.w700 : FontWeight.w600,
                              color: isHovered
                                  ? WebColors.textTitle
                                  : const Color(0xFF444444),
                            ),
                            child: Text(text),
                          ),
                        ),
                      ],
                    ),
                    // Description expands downward within expanding container + fade
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      switchInCurve: Curves.easeOut,
                      switchOutCurve: Curves.easeIn,
                      transitionBuilder: (child, animation) {
                        return FadeTransition(
                          opacity: animation,
                          child: child,
                        );
                      },
                      child: (isHovered && _impactDescriptions.containsKey(text))
                          ? Padding(
                              key: ValueKey<String>('desktop_impact_$text'),
                              padding: const EdgeInsets.only(top: AppSpacing.xs, left: 40.0),
                              child: Text(
                                _impactDescriptions[text]!,
                                style: TextStyle(
                                  fontSize: screenWidth > 1440 ? 12 : 11,
                                  color: const Color(0xFF666666),
                                  height: 1.5,
                                ),
                                maxLines: 3,
                              ),
                            )
                          : const SizedBox.shrink(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopGrid(double screenWidth) {
    final isLargeDesktop = screenWidth > 1440;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          children: [
            Expanded(
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                onEnter: (_) => setState(() => _expandedIndex = 0),
                child: _buildDesktopStatCard(0, widget.stats[0], screenWidth),
              ),
            ),
            SizedBox(width: isLargeDesktop ? AppSpacing.lg : AppSpacing.md),
            Expanded(
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                onEnter: (_) => setState(() => _expandedIndex = 1),
                child: _buildDesktopStatCard(1, widget.stats[1], screenWidth),
              ),
            ),
          ],
        ),
        SizedBox(height: isLargeDesktop ? AppSpacing.lg : AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                onEnter: (_) => setState(() => _expandedIndex = 2),
                child: _buildDesktopStatCard(2, widget.stats[2], screenWidth),
              ),
            ),
            SizedBox(width: isLargeDesktop ? AppSpacing.lg : AppSpacing.md),
            Expanded(
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                onEnter: (_) => setState(() => _expandedIndex = 3),
                child: _buildDesktopStatCard(3, widget.stats[3], screenWidth),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDesktopStatCard(int index, ImpactStatModel stat, double screenWidth) {
    final row = index ~/ 2;
    final col = index % 2;
    final isGreen = (row == 0 && col == 0) || (row == 1 && col == 1);
    final displayValue = _displayValue(stat);
    final isWeekStat = _isWeekStat(stat);
    final weekNumber = _weekNumber(stat);
    final weekLabel = _weekLabel(stat);
    return MouseRegion(
      onEnter: (_) => setState(() => _expandedIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        height: 150,
        decoration: BoxDecoration(
          color: isGreen
              ? const Color.fromARGB(255, 74, 211, 126)
              : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isGreen ? Colors.transparent : const Color(0xFFE0E0E0),
            width: 2.0,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color.fromARGB(30, 0, 0, 0),
              blurRadius: 15,
              spreadRadius: 1,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isWeekStat)
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              weekNumber,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 36,
                              fontWeight: FontWeight.w800,
                              color: isGreen ? Colors.white : WebColors.textTitle,
                              height: 0.9,
                            ),
                          ),
                          const SizedBox(width: 6),
                            Text(
                              weekLabel,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 28,
                              fontWeight: FontWeight.w600,
                              color: isGreen ? Colors.white : WebColors.textTitle,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),
                      Text(
                        'Composting Time',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: isGreen ? Colors.white : const Color(0xFF666666),
                        ),
                      ),
                    ],
                  )
                else
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      FittedBox(
                        fit: BoxFit.scaleDown,
                      child: Text(
                        displayValue,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 34,
                            fontWeight: FontWeight.w800,
                            color: isGreen ? Colors.white : WebColors.textTitle,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                        child: Text(
                          stat.label,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isGreen ? Colors.white : const Color(0xFF666666),
                            height: 1.1,
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildExpandedDesktopCard(int index, double screenWidth) {
    if (index >= widget.stats.length) {
      return _buildDesktopGrid(screenWidth);
    }
    final stat = widget.stats[index];
    final isLargeDesktop = screenWidth > 1440;
    final row = index ~/ 2;
    final col = index % 2;
    final isGreen = (row == 0 && col == 0) || (row == 1 && col == 1);
    final displayValue = _displayValue(stat);
    final isWeekStat = _isWeekStat(stat);
    final weekNumber = _weekNumber(stat);
    final weekLabel = _weekLabel(stat);
    final List<Map<String, dynamic>> expandedInfos = [
      {
        'icon': Icons.analytics_outlined,
        'title': 'Environmental Impact',
        'description': 'Biodegradable materials account for more than 50% of total municipal solid waste annually. This significant portion highlights the urgent need for effective organic waste management solutions in the Philippines.'
      },
      {
        'icon': Icons.timer_outlined,
        'title': 'Fast Processing',
        'description': 'Accel-O-Rot reduces composting time from months to just 2 weeks through optimized conditions, temperature control, and efficient aeration systems, ensuring faster waste transformation.'
      },
      {
        'icon': Icons.settings_outlined,
        'title': 'Smart Technology',
        'description': 'Our IoT-enabled system operates 24/7 with minimal human intervention, providing real-time monitoring and automated adjustments for optimal composting conditions and efficiency.'
      },
      {
        'icon': Icons.security_outlined,
        'title': 'Safe & Quality Container',
        'description': 'Our containers are designed with food-grade materials that prevent contamination and ensure hygienic composting conditions. Built with durable, corrosion-resistant components that maintain structural integrity while containing odors and pathogens effectively.'
      },
    ];
    return GestureDetector(
      onTap: _swipeToNext,
      child: AnimatedBuilder(
        animation: _swipeAnimation,
        builder: (context, child) {
          final currentInfo = expandedInfos[_currentExpandedInfo];
          return Transform.translate(
            offset: Offset(0, -8 * math.sin(_swipeAnimation.value * math.pi)),
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              opacity: 1.0,
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: isLargeDesktop ? 620 : 520,
                  ),
                  child: Container(
                    width: double.infinity,
                    height: 400,
                decoration: BoxDecoration(
                  color: isGreen
                      ? const Color.fromARGB(255, 74, 211, 126)
                      : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isGreen ? Colors.transparent : WebColors.greenLight,
                      width: 2.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color.fromARGB(40, 0, 0, 0),
                        blurRadius: 20,
                        spreadRadius: 1,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                      // Icon section
                      Padding(
                        padding: const EdgeInsets.only(top: AppSpacing.lg),
                        child: Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: isGreen
                                ? const Color.fromARGB(90, 255, 255, 255)
                                : const Color.fromARGB(45, 118, 230, 207),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isGreen ? Colors.white : WebColors.greenLight,
                              width: 2.0,
                            ),
                          ),
                          child: Icon(
                            currentInfo['icon'] as IconData,
                            size: 24,
                            color: isGreen ? Colors.white : WebColors.greenLight,
                          ),
                        ),
                      ),
                      // Stat value section
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            if (isWeekStat)
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.baseline,
                                      textBaseline: TextBaseline.alphabetic,
                                      children: [
                                        Text(
                                          weekNumber,
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: isLargeDesktop ? 36 : 32,
                                            fontWeight: FontWeight.w800,
                                            color: isGreen ? Colors.white : WebColors.textTitle,
                                            height: 0.9,
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          weekLabel,
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: isLargeDesktop ? 28 : 24,
                                            fontWeight: FontWeight.w600,
                                            color: isGreen ? Colors.white : WebColors.textTitle,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'Composting Time',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: isLargeDesktop ? 16 : 15,
                                      fontWeight: FontWeight.w600,
                                      color: isGreen ? Colors.white : WebColors.textTitle,
                                    ),
                                  ),
                                ],
                              )
                            else
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      displayValue,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: isLargeDesktop ? 36 : 32,
                                        fontWeight: FontWeight.w800,
                                        color: isGreen ? Colors.white : WebColors.textTitle,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    stat.label,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: isLargeDesktop ? 16 : 15,
                                      fontWeight: FontWeight.w600,
                                      color: isGreen ? Colors.white : WebColors.textTitle,
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                      // Divider
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
                        child: Divider(
                          color: isGreen
                              ? const Color.fromARGB(120, 255, 255, 255)
                              : const Color(0xFFE0E0E0),
                          thickness: 1.0,
                        ),
                      ),
                      // Title section
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                        child: Text(
                          currentInfo['title'],
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: isLargeDesktop ? 18 : 17,
                            fontWeight: FontWeight.w700,
                            color: isGreen ? Colors.white : WebColors.textTitle,
                          ),
                        ),
                      ),
                      // Description section
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
                        child: Text(
                          currentInfo['description'],
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: isLargeDesktop ? 13 : 12,
                            fontWeight: FontWeight.normal,
                            color: isGreen ? Colors.white : const Color(0xFF2E2E2E),
                            height: 1.5,
                          ),
                        ),
                      ),
                    ),
                      // Navigation dots and instruction
                      Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(4, (i) {
                                return Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 3),
                                  width: i == _currentExpandedInfo ? 18 : 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: i == _currentExpandedInfo
                                        ? (isGreen ? Colors.white : WebColors.greenLight)
                                        : (isGreen
                                            ? const Color.fromARGB(100, 255, 255, 255)
                                            : const Color(0xFFE0E0E0)),
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                );
                              }),
                            ),
                            const SizedBox(height: 6),
                          ],
                        ),
                      ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
          },
        ),
      );
  }

  // Helper method to get mobile stat description
  String _getMobileStatDescription(int index, ImpactStatModel stat) {
    if (stat.label.toLowerCase().contains('week') || stat.value == '2') {
      return 'Traditional composting takes months. Our technology accelerates the process significantly.';
    } else if (stat.label.toLowerCase().contains('waste') || stat.value.contains('50%')) {
      return 'Biodegradable waste makes up over half of all municipal solid waste in the Philippines.';
    } else if (stat.label.toLowerCase().contains('operation') || stat.label.toLowerCase().contains('24/7')) {
      return 'Our system operates with minimal human intervention, automating the composting process.';
    } else if (stat.label.toLowerCase().contains('efficiency') || stat.value.contains('100%')) {
      return 'IoT technology provides real-time monitoring and adjustments for optimal composting.';
    }
    switch (index) {
      case 0:
        return 'Biodegradable waste makes up over half of all municipal solid waste in the Philippines.';
      case 1:
        return 'Traditional composting takes months. Our technology accelerates the process significantly.';
      case 2:
        return 'Our system operates with minimal human intervention, automating the composting process.';
      case 3:
        return 'IoT technology provides real-time monitoring and adjustments for optimal composting.';
      default:
        return 'Sustainable waste management solution for communities.';
    }
  }

  // Helpers for consistent stat formatting
  bool _isWeekStat(ImpactStatModel stat) {
    final label = stat.label.toLowerCase();
    final value = stat.value.toLowerCase();
    return label.contains('week') || value.contains('week');
  }

  String _displayValue(ImpactStatModel stat) {
    final value = stat.value.trim();
    return value == '50%+' ? '+50%' : value;
  }

  String _weekNumber(ImpactStatModel stat) {
    final value = stat.value.trim();
    if (value.contains('\n')) {
      return value.split('\n').first.trim();
    }
    if (value.contains(' ')) {
      return value.split(' ').first.trim();
    }
    return value;
  }

  String _weekLabel(ImpactStatModel stat) {
    final value = stat.value.trim();
    if (value.contains('\n')) {
      final parts = value.split('\n');
      if (parts.length > 1) {
        return parts[1].trim();
      }
    }
    final parts = value.split(' ');
    if (parts.length > 1) {
      return parts.sublist(1).join(' ').trim();
    }
    return 'weeks';
  }

  // Helper method to get tablet stat description
  String _getTabletStatDescription(int index, ImpactStatModel stat) {
    if (stat.label.toLowerCase().contains('week') || stat.value == '2') {
      return 'Traditional composting takes 3-6 months. Our technology reduces this to just 2 weeks through optimized conditions.';
    } else if (stat.label.toLowerCase().contains('waste') || stat.value.contains('50%')) {
      return 'Over 50% of municipal solid waste is organic material that can be composted instead of going to landfills.';
    } else if (stat.label.toLowerCase().contains('operation') || stat.label.toLowerCase().contains('24/7')) {
      return 'IoT-enabled system operates 24/7 with minimal human intervention, providing real-time monitoring.';
    } else if (stat.label.toLowerCase().contains('efficiency') || stat.value.contains('100%')) {
      return 'Smart technology automates temperature, moisture, and aeration for optimal composting conditions.';
    }
    switch (index) {
      case 0:
        return 'Over 50% of municipal solid waste is organic material that can be composted instead of going to landfills.';
      case 1:
        return 'Traditional composting takes 3-6 months. Our technology reduces this to just 2 weeks through optimized conditions.';
      case 2:
        return 'IoT-enabled system operates 24/7 with minimal human intervention, providing real-time monitoring.';
      case 3:
        return 'Smart technology automates temperature, moisture, and aeration for optimal composting conditions.';
      default:
        return 'Sustainable waste management solution that empowers communities and reduces environmental impact.';
    }
  }

}
