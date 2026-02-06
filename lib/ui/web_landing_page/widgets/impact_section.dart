// lib/ui/landing_page/widgets/impact_section.dart

import 'package:flutter/material.dart';
import '../../core/constants/spacing.dart';
import '../../core/themes/web_colors.dart';
import '../models/impact_stat_model.dart';

class ImpactSection extends StatefulWidget {
  final List<ImpactStatModel> stats;
  const ImpactSection({
    super.key,
    required this.stats,
  });

  @override
  State<ImpactSection> createState() => _ImpactSectionState();
}

class _ImpactSectionState extends State<ImpactSection> {
  int? _expandedImpactIndex;

  // Map for impact item descriptions
  final Map<String, String> _impactDescriptions = {
    'Reduces landfill waste':
        'Addresses the pressing environmental concern in the Philippines where over 50% of municipal solid waste is organic. Prevents methane emissions from landfills that contribute to climate change.',
    'Produces nutrient-rich compost':
        'Transforms organic waste into high-quality compost through accelerated decomposition. Improves soil health and reduces need for chemical fertilizers in agriculture.',
    'Empowers communities':
        'Supports Republic Act 9003 implementation by providing accessible composting technology. Reduces manual labor and makes sustainable waste management practical for households and communities.',
  };

  final List<_ImpactCardData> _impactCards = const [
    _ImpactCardData(
      title: 'Reduces landfill waste',
      icon: Icons.delete_outline,
      backgroundColor:  WebColors.substratesBackground,
      textColor: WebColors.textPrimary,
    ),
    _ImpactCardData(
      title: 'Produces nutrient-rich compost',
      icon: Icons.compost,
      backgroundColor: WebColors.alertsBackground,
      textColor: WebColors.textPrimary,
    ),
    _ImpactCardData(
      title: 'Empowers communities',
      icon: Icons.groups,
      backgroundColor: WebColors.operationsBackground,
      textColor: WebColors.textPrimary,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final sectionHeight = _sectionHeight(context);
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(
        minHeight: sectionHeight,
      ),
      padding: _getResponsivePadding(context),
      color: Colors.white,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final screenWidth = constraints.maxWidth;
          if (widget.stats.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (screenWidth < 600) {
            return _buildMobileLayout(screenWidth);
          } else if (screenWidth < 1024) {
            return _buildTabletLayout(screenWidth);
          } else {
            return _buildDesktopLayout(screenWidth);
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
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.xl,
      );
    } else {
      return const EdgeInsets.symmetric(
        horizontal: AppSpacing.xxxl,
        vertical: AppSpacing.xxl,
      );
    }
  }

  // ===================== MOBILE LAYOUT (<600px) =====================
  Widget _buildMobileLayout(double screenWidth) {
    final cardsHeight = MediaQuery.of(context).size.height * 0.55;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildImpactIntroCard(screenWidth, isCompact: true),
        const SizedBox(height: AppSpacing.lg),
        _buildImpactCardsArea(
          screenWidth,
          height: cardsHeight,
          isCompact: true,
        ),
      ],
    );
  }

  // ===================== TABLET LAYOUT (600-1024px) =====================
  Widget _buildTabletLayout(double screenWidth) {
    final cardsHeight = _sectionHeight(context);
    final isSmallTablet = screenWidth < 800;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isSmallTablet) ...[
          _buildImpactIntroCard(screenWidth, isCompact: true),
          const SizedBox(height: AppSpacing.lg),
          _buildImpactCardsArea(
            screenWidth,
            height: cardsHeight,
            isCompact: true,
          ),
        ] else
          SizedBox(
            height: cardsHeight,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  flex: 5,
                  child: _buildImpactIntroCard(screenWidth),
                ),
                const SizedBox(width: AppSpacing.lg),
                Expanded(
                  flex: 4,
                  child: _buildImpactCardsArea(
                    screenWidth,
                    height: cardsHeight,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  // ===================== DESKTOP LAYOUT (>1024px) =====================
  Widget _buildDesktopLayout(double screenWidth) {
    final cardsHeight = _sectionHeight(context);
    return SizedBox(
      height: cardsHeight,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 5,
            child: _buildImpactIntroCard(screenWidth),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            flex: 6,
            child: _buildImpactCardsArea(
              screenWidth,
              height: cardsHeight,
            ),
          ),
        ],
      ),
    );
  }

  double _sectionHeight(BuildContext context) {
    return MediaQuery.of(context).size.height * 0.78;
  }

  double _impactDescriptionSize(double screenWidth) {
    if (screenWidth < 600) {
      return 10.0;
    } else if (screenWidth < 1024) {
      return 12.0;
    } else {
      return screenWidth > 1440 ? 17.0 : 16.0;
    }
  }

  Widget _buildImpactIntroCard(double screenWidth, {bool isCompact = false}) {
    final isMobile = screenWidth < 600;
    final isTablet = screenWidth >= 600 && screenWidth < 1024;
    final titleSize = isMobile
        ? 30.0
        : isTablet
            ? 34.0
            : (screenWidth > 1440 ? 64.0 : 58.0);
    final subtitleSize = _impactDescriptionSize(screenWidth) + (isMobile ? 1 : isTablet ? 1 : 0);
    return Container(
      constraints: isMobile
          ? const BoxConstraints(
              minHeight: 240,
            )
          : null,
      padding: EdgeInsets.all(
        isMobile
            ? AppSpacing.sm
            : isTablet
                ? AppSpacing.md
                : AppSpacing.xl,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF10B981),
            Color(0xFF22C55E),
          ],
        ),
      ),
      child: Stack(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.only(left: AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (isMobile) const SizedBox(height: AppSpacing.md),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: RichText(
                      textAlign: TextAlign.left,
                      text: TextSpan(
                        style: TextStyle(
                          fontSize: titleSize,
                          fontWeight: FontWeight.w800,
                          height: (titleSize + 10) / titleSize,
                        ),
                        children: const [
                          TextSpan(
                            text: 'MAKING A\n',
                            style: TextStyle(color: Colors.white),
                          ),
                          TextSpan(
                            text: 'SUSTAINABLE\n',
                            style: TextStyle(color: Color(0xFF1B5E20)),
                          ),
                          TextSpan(
                            text: 'IMPACT',
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: isMobile ? AppSpacing.md : isTablet ? AppSpacing.lg : AppSpacing.xxxl),
                  Text(
                    'In the Philippines, over 50% of Municipal Solid Waste is organic.\nAccel-O-Rot helps manage waste responsible',
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      fontSize: subtitleSize,
                      height: 1.35,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            right: isCompact ? 8 : 18,
            bottom: isCompact ? 8 : 18,
            child: Icon(
              Icons.eco,
              size: isCompact ? 24 : 36,
              color: const Color(0xFFB7E36C),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImpactCardsArea(double screenWidth, {required double height, bool isCompact = false}) {
    return MouseRegion(
      onExit: (_) => setState(() => _expandedImpactIndex = null),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: screenWidth),
        child: SizedBox(
          width: double.infinity,
          height: height,
          child: _buildImpactGrid(isCompact: isCompact),
        ),
      ),
    );
  }

  Widget _buildImpactGrid({bool isCompact = false}) {
    final hovered = _expandedImpactIndex;
    final topIndex = hovered == 1
        ? 1
        : hovered == 2
            ? 2
            : 0;
    final bottomLeftIndex = hovered == 1 ? 0 : 1;
    final bottomRightIndex = hovered == 2 ? 0 : 2;
    return Column(
      children: [
        Expanded(
          flex: 2,
          child: _buildImpactSmallCard(
            _impactCards[topIndex],
            0,
            displayIndex: topIndex,
            isCompact: isCompact,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Expanded(
          flex: 1,
          child: Row(
            children: [
              Expanded(
                child: _buildImpactSmallCard(
                  _impactCards[bottomLeftIndex],
                  1,
                  displayIndex: bottomLeftIndex,
                  isCompact: isCompact,
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: _buildImpactSmallCard(
                  _impactCards[bottomRightIndex],
                  2,
                  displayIndex: bottomRightIndex,
                  isCompact: isCompact,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildImpactSmallCard(
    _ImpactCardData data,
    int index, {
    required int displayIndex,
    bool isCompact = false,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final isTablet = screenWidth >= 600 && screenWidth < 1024;
    final descriptionSize = _impactDescriptionSize(screenWidth);
    final isHovered = _expandedImpactIndex == displayIndex;
    final isIllustration = index == 0;
    final hoverColor =
        Color.lerp(_impactCards.first.backgroundColor, Colors.white, 0.2)!;
    return MouseRegion(
      onEnter: (_) => setState(() {
        _expandedImpactIndex = displayIndex;
      }),
      onExit: (_) => setState(() {
        _expandedImpactIndex = null;
      }),
      child: GestureDetector(
        onTap: () => setState(() => _expandedImpactIndex = displayIndex),
        child: Container(
          padding: EdgeInsets.all(isCompact ? AppSpacing.md : AppSpacing.lg),
          decoration: BoxDecoration(
            color: isHovered ? hoverColor : data.backgroundColor,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Stack(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: isIllustration
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            flex: 5,
                            child: Center(
                              child: FractionallySizedBox(
                                widthFactor: isMobile
                                    ? 0.7
                                    : isTablet
                                        ? 0.75
                                        : 0.85,
                                heightFactor: isMobile
                                    ? 0.7
                                    : isTablet
                                        ? 0.75
                                        : 0.85,
                                child: LayoutBuilder(
                                  builder: (context, constraints) {
                                    final maxWidth = constraints.maxWidth;
                                    final maxHeight = constraints.maxHeight;
                                    final heightBounded =
                                        maxHeight != double.infinity && maxHeight > 0;
                                    final diameter =
                                        heightBounded ? (maxWidth < maxHeight ? maxWidth : maxHeight) : maxWidth;
                                    return Center(
                                      child: SizedBox.square(
                                        dimension: diameter,
                                        child: ClipOval(
                                          child: Image.asset(
                                            _imageForIndex(displayIndex),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: isMobile
                                ? AppSpacing.xs
                                : isTablet
                                    ? AppSpacing.sm
                                    : AppSpacing.lg,
                          ),
                          Expanded(
                            flex: 5,
                            child: Padding(
                              padding: EdgeInsets.only(
                                right: isCompact ? AppSpacing.md : AppSpacing.xl,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Align(
                                    alignment: index == 0
                                        ? Alignment.centerRight
                                        : Alignment.centerLeft,
                                    child: Text(
                                      data.title.toUpperCase(),
                                      textAlign: index == 0 ? TextAlign.right : TextAlign.left,
                                      style: TextStyle(
                                      fontSize: isMobile
                                          ? 16
                                          : isTablet
                                              ? 18
                                              : 26,
                                      fontWeight: FontWeight.w800,
                                      color: data.textColor,
                                    ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                if (index == 0)
                                  Padding(
                                    padding: const EdgeInsets.only(top: AppSpacing.sm),
                                    child: Text(
                                      _impactDescriptions[data.title] ?? '',
                                      textAlign: TextAlign.justify,
                                      style: TextStyle(
                                        fontSize: descriptionSize,
                                        height: 1.4,
                                        color: data.textColor.withValues(alpha: 0.9),
                                      ),
                                      maxLines: 5,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              )
                            ),
                          ),
                        ],

                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                width: isMobile
                                    ? 24
                                    : isTablet
                                        ? 28
                                        : 42,
                                height: isMobile
                                    ? 24
                                    : isTablet
                                        ? 28
                                        : 42,
                                decoration: BoxDecoration(
                                  color: Colors.transparent,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  data.icon ?? Icons.eco_outlined,
                                  size: isMobile
                                      ? 16
                                      : isTablet
                                          ? 20
                                          : 36,
                                  color: const Color(0xFF3F8E3F),
                                ),
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Expanded(
                                child: Text(
                                  data.title.toUpperCase(),
                                  style: TextStyle(
                                    fontSize: (() {
                                      final baseSize = isMobile
                                          ? 11.0
                                          : isTablet
                                              ? 13.0
                                              : ((data.title == 'Produces nutrient-rich compost' ||
                                                  data.title == 'Empowers communities')
                                              ? 16.0
                                              : data.title == 'Reduces landfill waste'
                                                  ? 18.0
                                                  : 20.0);
                                      if (index != 0 && isHovered) {
                                        return baseSize - 2.0;
                                      }
                                      return baseSize;
                                    })(),
                                    fontWeight: FontWeight.w800,
                                    color: data.textColor,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          if (index == 0)
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 200),
                              switchInCurve: Curves.easeOut,
                              switchOutCurve: Curves.easeIn,
                              child: isHovered
                                  ? Padding(
                                      key: ValueKey<String>('desc_${data.title}'),
                                      padding: const EdgeInsets.only(top: AppSpacing.sm),
                                      child: Text(
                                        _impactDescriptions[data.title] ?? '',
                                        style: TextStyle(
                                          fontSize: descriptionSize,
                                          height: 1.4,
                                          color: data.textColor.withValues(alpha: 0.9),
                                        ),
                                        maxLines: 3,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    )
                                  : const SizedBox.shrink(),
                            ),
                        ],
                      ),
              ),
              const SizedBox.shrink(),
            ],
          ),
        ),
      ),
      );
  }

  String _imageForIndex(int index) {
    switch (index) {
      case 0:
        return 'assets/images/Reduce_lanfill.png';
      case 1:
        return 'assets/images/produce.png';
      case 2:
        return 'assets/images/empower.png';
      default:
        return 'assets/images/reduce.png';
    }
  }
}

class _ImpactCardData {
  final String title;
  final IconData? icon;
  final Color backgroundColor;
  final Color textColor;
  const _ImpactCardData({
    required this.title,
    this.icon,
    required this.backgroundColor,
    required this.textColor,
  });
}
