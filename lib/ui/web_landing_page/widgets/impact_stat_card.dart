// lib/ui/landing_page/widgets/impact_section.dart

import 'package:flutter/material.dart';
import '../../core/constants/spacing.dart';
import '../../core/themes/web_text_styles.dart';
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
  int? _hoveredIndex;
  bool _isAnimating = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: _getResponsivePadding(context),
      color: Colors.white,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final screenWidth = constraints.maxWidth;
          
          // Responsive breakpoints
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
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.xl,
      );
    } else if (screenWidth < 1024) {
      return const EdgeInsets.symmetric(
        horizontal: AppSpacing.xxl,
        vertical: AppSpacing.xl * 1.2,
      );
    } else {
      return const EdgeInsets.symmetric(
        horizontal: AppSpacing.xxxl,
        vertical: AppSpacing.xl * 1.5,
      );
    }
  }

  // ===================== MOBILE LAYOUT (<600px) =====================
  Widget _buildMobileLayout(BuildContext context, double screenWidth) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'MAKING A SUSTAINABLE IMPACT',
            textAlign: TextAlign.center,
            style: WebTextStyles.h2.copyWith(
              fontSize: screenWidth < 400 ? 22 : 24,
              fontWeight: FontWeight.w700,
              color: WebColors.textTitle,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm),
            child: Text(
              'In the Philippines, over 50% of municipal solid waste is organic.\nAccel-O-Rot helps manage waste responsibly.',
              textAlign: TextAlign.center,
              style: WebTextStyles.sectionSubtitle.copyWith(
                fontSize: screenWidth < 400 ? 12 : 13,
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          _buildImpactItem(Icons.delete_outline, 'Reduces landfill waste', isMobile: true),
          const SizedBox(height: AppSpacing.sm),
          _buildImpactItem(Icons.restaurant_outlined, 'Produces nutrient-rich compost', isMobile: true),
          const SizedBox(height: AppSpacing.sm),
          _buildImpactItem(Icons.eco_outlined, 'Empowers communities', isMobile: true),

          const SizedBox(height: AppSpacing.xl),

          // Grid for mobile - 2 columns
          SizedBox(
            height: _hoveredIndex != null ? 250 : 400,
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: AppSpacing.md,
                crossAxisSpacing: AppSpacing.md,
                childAspectRatio: screenWidth < 400 ? 0.75 : 0.85,
              ),
              itemCount: widget.stats.length,
              itemBuilder: (context, index) {
                return _buildStatsContainer(
                  index, 
                  widget.stats[index], 
                  isMobile: true, 
                  screenWidth: screenWidth
                );
              },
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }

  // ===================== TABLET LAYOUT (600-1024px) =====================
  Widget _buildTabletLayout(BuildContext context, double screenWidth) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Making a Sustainable Impact',
            textAlign: TextAlign.center,
            style: WebTextStyles.h2.copyWith(
              fontSize: screenWidth < 800 ? 28 : 32,
              fontWeight: FontWeight.w700,
              color: WebColors.textTitle,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.1),
            child: Text(
              'In the Philippines, over 50% of municipal solid waste is organic.\nAccel-O-Rot helps manage waste responsibly.',
              textAlign: TextAlign.center,
              style: WebTextStyles.sectionSubtitle.copyWith(
                fontSize: screenWidth < 800 ? 14 : 15,
                height: 1.6,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),

          // Impact items
          _buildImpactItem(Icons.delete_outline, 'Reduces landfill waste', isMobile: false),
          const SizedBox(height: AppSpacing.md),
          _buildImpactItem(Icons.restaurant_outlined, 'Produces nutrient-rich compost', isMobile: false),
          const SizedBox(height: AppSpacing.md),
          _buildImpactItem(Icons.eco_outlined, 'Empowers communities', isMobile: false),

          const SizedBox(height: AppSpacing.xl * 1.5),

          // Grid for tablet
          SizedBox(
            height: _hoveredIndex != null ? 300 : 500,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: AppSpacing.lg,
                  crossAxisSpacing: AppSpacing.lg,
                  childAspectRatio: screenWidth < 800 ? 0.9 : 1.0,
                ),
                itemCount: widget.stats.length,
                itemBuilder: (context, index) {
                  return _buildStatsContainer(
                    index, 
                    widget.stats[index], 
                    isMobile: false, 
                    screenWidth: screenWidth
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }

  // ===================== DESKTOP LAYOUT (>1024px) =====================
  Widget _buildDesktopLayout(BuildContext context, double screenWidth) {
    final isLargeDesktop = screenWidth > 1440;
    
    return SizedBox(
      height: 600,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 5,
            child: Padding(
              padding: const EdgeInsets.only(right: AppSpacing.xl),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Making a Sustainable Impact',
                    style: WebTextStyles.h2.copyWith(
                      fontSize: isLargeDesktop ? 42 : 36,
                      fontWeight: FontWeight.w700,
                      color: WebColors.textTitle,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  SizedBox(
                    width: isLargeDesktop ? 600 : 500,
                    child: Text(
                      'In the Philippines, over 50% of municipal solid waste is organic.\nAccel-O-Rot helps manage waste responsibly.',
                      style: WebTextStyles.sectionSubtitle.copyWith(
                        fontSize: isLargeDesktop ? 18 : 16,
                        height: 1.6,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  _buildImpactItem(Icons.delete_outline, 'Reduces landfill waste'),
                  const SizedBox(height: AppSpacing.md),
                  _buildImpactItem(Icons.restaurant_outlined, 'Produces nutrient-rich compost'),
                  const SizedBox(height: AppSpacing.md),
                  _buildImpactItem(Icons.eco_outlined, 'Empowers communities'),
                ],
              ),
            ),
          ),

          const SizedBox(width: AppSpacing.xxl),

          Expanded(
            flex: 3,
            child: SizedBox(
              height: 500,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Transform.translate(
                  offset: const Offset(-32, 0),
                  child: SizedBox(
                    width: isLargeDesktop ? 480 : 420,
                    height: 500,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 500),
                      child: _hoveredIndex != null
                          ? _buildExpandedCard(_hoveredIndex!, screenWidth)
                          : _buildGridLayout(screenWidth),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGridLayout(double screenWidth) {
    final isLargeDesktop = screenWidth > 1440;
    
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Expanded(
              child: MouseRegion(
                onEnter: (_) => _onCardHover(0),
                child: _buildStatsCard(0, widget.stats[0], screenWidth, isExpanded: false),
              ),
            ),
            SizedBox(width: isLargeDesktop ? AppSpacing.xl : AppSpacing.lg),
            Expanded(
              child: MouseRegion(
                onEnter: (_) => _onCardHover(1),
                child: _buildStatsCard(1, widget.stats[1], screenWidth, isExpanded: false),
              ),
            ),
          ],
        ),
        SizedBox(height: isLargeDesktop ? AppSpacing.xl : AppSpacing.lg),
        Row(
          children: [
            Expanded(
              child: MouseRegion(
                onEnter: (_) => _onCardHover(2),
                child: _buildStatsCard(2, widget.stats[2], screenWidth, isExpanded: false),
              ),
            ),
            SizedBox(width: isLargeDesktop ? AppSpacing.xl : AppSpacing.lg),
            Expanded(
              child: MouseRegion(
                onEnter: (_) => _onCardHover(3),
                child: _buildStatsCard(3, widget.stats[3], screenWidth, isExpanded: false),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildExpandedCard(int index, double screenWidth) {
    final stat = widget.stats[index];
    final isLargeDesktop = screenWidth > 1440;
    final row = index ~/ 2;
    final col = index % 2;
    final isGreen = (row == 0 && col == 0) || (row == 1 && col == 1);

    final Map<int, String> additionalInfo = {
      0: 'In the Philippines, biodegradable materials account for more than 50% of total municipal solid waste annually. Traditional composting faces challenges like inconsistent decomposition and long processing times.',
      1: 'Accel-O-Rot reduces composting time from months to just 2 weeks through optimized aeration, moisture regulation, and real-time monitoring, producing mature compost faster and more consistently.',
      2: 'Our IoT-enabled system operates 24/7 with minimal human intervention, continuously monitoring and adjusting conditions to ensure optimal decomposition and prevent odor issues.',
      3: 'Accel-O-Rot achieves over 100% efficiency in waste conversion compared to traditional methods, producing higher quality compost while reducing greenhouse gas emissions.',
    };

    return MouseRegion(
      onExit: (_) => _onCardHoverEnd(),
      child: Container(
        height: 500,
        decoration: BoxDecoration(
          color: isGreen 
            ? const Color.fromARGB(255, 74, 211, 126)
            : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isGreen ? Colors.transparent : WebColors.greenLight,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color.fromARGB(77, 0, 0, 0),
              blurRadius: 30,
              offset: const Offset(0, 15),
              spreadRadius: 5,
            ),
            BoxShadow(
              color: isGreen 
                ? const Color.fromARGB(102, 74, 211, 126)
                : const Color.fromARGB(77, 118, 230, 207),
              blurRadius: 25,
              offset: const Offset(0, 10),
              spreadRadius: 3,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: isGreen 
                    ? const Color.fromARGB(102, 255, 255, 255)
                    : const Color.fromARGB(51, 118, 230, 207),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isGreen ? Colors.white : WebColors.greenLight,
                    width: 2,
                  ),
                ),
                child: Icon(
                  _getIconForIndex(stat),
                  size: 40,
                  color: isGreen ? Colors.white : WebColors.greenLight,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              
              Text(
                stat.value,
                style: TextStyle(
                  fontSize: isLargeDesktop ? 64 : 56,
                  fontWeight: FontWeight.w800,
                  color: isGreen ? Colors.white : WebColors.textTitle,
                  shadows: isGreen ? [
                    Shadow(
                      color: const Color.fromARGB(51, 0, 0, 0),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ] : null,
                ),
              ),
              
              const SizedBox(height: AppSpacing.sm),
              
              Text(
                stat.label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: isLargeDesktop ? 22 : 20,
                  fontWeight: FontWeight.w600,
                  color: isGreen ? Colors.white : WebColors.textTitle,
                ),
              ),
              
              const SizedBox(height: AppSpacing.lg),
              
              Divider(
                color: isGreen 
                  ? const Color.fromARGB(102, 255, 255, 255)
                  : const Color(0xFFE0E0E0),
                thickness: 1,
                indent: 40,
                endIndent: 40,
              ),
              
              const SizedBox(height: AppSpacing.lg),
              
              Expanded(
                child: SingleChildScrollView(
                  child: Text(
                    additionalInfo[index] ?? '',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: isLargeDesktop ? 16 : 14,
                      fontWeight: FontWeight.normal,
                      color: isGreen 
                        ? const Color.fromARGB(204, 255, 255, 255)
                        : const Color(0xFF666666),
                      height: 1.7,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: AppSpacing.lg),
              
              if (!isGreen)
                Text(
                  'Hover off to collapse',
                  style: TextStyle(
                    fontSize: 12,
                    color: const Color(0xFF999999),
                    fontStyle: FontStyle.italic,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsCard(int index, ImpactStatModel stat, double screenWidth, {bool isExpanded = false}) {
    final row = index ~/ 2;
    final col = index % 2;
    final isGreen = (row == 0 && col == 0) || (row == 1 && col == 1);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: isExpanded ? 500 : 180,
      decoration: BoxDecoration(
        color: isGreen 
          ? const Color.fromARGB(255, 74, 211, 126)
          : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isGreen ? Colors.transparent : const Color(0xFFE0E0E0),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(38, 0, 0, 0),
            blurRadius: 12,
            offset: const Offset(0, 4),
            spreadRadius: 1,
          ),
        ],
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              stat.value,
              style: TextStyle(
                fontSize: isExpanded ? 48 : 32,
                fontWeight: FontWeight.w800,
                color: isGreen ? Colors.white : WebColors.textTitle,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              stat.label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: isExpanded ? 16 : 12,
                fontWeight: FontWeight.w500,
                color: isGreen ? Colors.white : const Color(0xFF666666),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===================== STAT CARD FOR MOBILE/TABLET =====================
  Widget _buildStatsContainer(int index, ImpactStatModel stat, {bool isMobile = false, required double screenWidth}) {
    final row = index ~/ 2;
    final col = index % 2;
    final isGreen = (row == 0 && col == 0) || (row == 1 && col == 1);

    return MouseRegion(
      onEnter: (_) => _onCardHover(index),
      onExit: (_) => _onCardHoverEnd(),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: _hoveredIndex == index 
          ? (isMobile ? 220 : 280)
          : (isMobile ? 140 : 170),
        decoration: BoxDecoration(
          color: _hoveredIndex == index 
            ? (isGreen 
                ? const Color.fromARGB(255, 85, 221, 137) 
                : const Color(0xFFF8F9FA))
            : (isGreen 
                ? const Color.fromARGB(255, 74, 211, 126) 
                : Colors.white),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _hoveredIndex == index 
              ? (isGreen ? Colors.transparent : WebColors.greenLight)
              : (isGreen ? Colors.transparent : const Color(0xFFE0E0E0)),
            width: _hoveredIndex == index ? 2.5 : 1.5,
          ),
          boxShadow: _hoveredIndex == index
            ? [
                BoxShadow(
                  color: const Color.fromARGB(51, 0, 0, 0),
                  blurRadius: 25,
                  offset: const Offset(0, 10),
                  spreadRadius: 3,
                ),
                BoxShadow(
                  color: isGreen 
                    ? const Color.fromARGB(77, 74, 211, 126)
                    : const Color.fromARGB(64, 118, 230, 207),
                  blurRadius: 20,
                  offset: const Offset(0, 6),
                  spreadRadius: 2,
                ),
              ]
            : [
                BoxShadow(
                  color: const Color.fromARGB(38, 0, 0, 0),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                  spreadRadius: 1,
                ),
              ],
        ),
        child: _hoveredIndex == index
            ? _buildExpandedContent(index, stat, isGreen, isMobile, screenWidth)
            : _buildCollapsedContent(stat, isGreen, isMobile, screenWidth),
      ),
    );
  }

  Widget _buildCollapsedContent(ImpactStatModel stat, bool isGreen, bool isMobile, double screenWidth) {
    String displayValue = stat.value;
    if (stat.label.toLowerCase().contains('week')) {
      displayValue = '${stat.value} weeks';
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            displayValue,
            style: TextStyle(
              fontSize: isMobile ? 24 : 28,
              fontWeight: FontWeight.w800,
              color: isGreen ? Colors.white : WebColors.textTitle,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            stat.label,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: isMobile ? 10 : 12,
              fontWeight: FontWeight.w500,
              color: isGreen ? Colors.white : const Color(0xFF666666),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpandedContent(int index, ImpactStatModel stat, bool isGreen, bool isMobile, double screenWidth) {
    final Map<int, String> additionalInfo = {
      0: 'In the Philippines, biodegradable materials account for more than 50% of total municipal solid waste annually.',
      1: 'Accel-O-Rot reduces composting time from months to just 2 weeks through optimized conditions.',
      2: 'Our IoT-enabled system operates 24/7 with minimal human intervention.',
      3: 'Accel-O-Rot achieves over 100% efficiency in waste conversion compared to traditional methods.',
    };

    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isGreen 
                ? const Color.fromARGB(51, 255, 255, 255)
                : const Color.fromARGB(26, 118, 230, 207),
              shape: BoxShape.circle,
              border: Border.all(
                color: isGreen ? Colors.white : WebColors.greenLight,
                width: 1.5,
              ),
            ),
            child: Icon(
              _getIconForIndex(stat),
              size: 20,
              color: isGreen ? Colors.white : WebColors.greenLight,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            stat.value,
            style: TextStyle(
              fontSize: isMobile ? 28 : 32,
              fontWeight: FontWeight.w800,
              color: isGreen ? Colors.white : WebColors.textTitle,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            stat.label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: isMobile ? 12 : 14,
              fontWeight: FontWeight.w600,
              color: isGreen ? Colors.white : WebColors.textTitle,
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: SingleChildScrollView(
              child: Text(
                additionalInfo[index] ?? '',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: isMobile ? 10 : 11,
                  fontWeight: FontWeight.normal,
                  color: isGreen 
                    ? const Color.fromARGB(204, 255, 255, 255)
                    : const Color(0xFF666666),
                  height: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onCardHover(int index) {
    if (_isAnimating) return;
    
    setState(() {
      _isAnimating = true;
      _hoveredIndex = index;
    });
    
    // Reset animation flag after animation completes
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        _isAnimating = false;
      });
    });
  }

  void _onCardHoverEnd() {
    if (_isAnimating) return;
    
    setState(() {
      _isAnimating = true;
      _hoveredIndex = null;
    });
    
    // Reset animation flag after animation completes
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        _isAnimating = false;
      });
    });
  }

  // ===================== IMPACT ITEM =====================
  Widget _buildImpactItem(IconData icon, String text, {bool isMobile = false}) {
    final Map<String, String> impactDetails = {
      'Reduces landfill waste': 'Addresses the pressing environmental concern in the Philippines where over 50% of municipal solid waste is organic.',
      'Produces nutrient-rich compost': 'Transforms organic waste into high-quality compost through accelerated decomposition.',
      'Empowers communities': 'Supports Republic Act 9003 implementation by providing accessible composting technology.',
    };

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: HoverableImpactItem(
        icon: icon,
        text: text,
        isMobile: isMobile,
        details: impactDetails[text] ?? text,
      ),
    );
  }

  IconData _getIconForIndex(ImpactStatModel stat) {
    if (stat.label.toLowerCase().contains('waste') || stat.value.contains('50%')) {
      return Icons.analytics_outlined;
    } else if (stat.label.toLowerCase().contains('week')) {
      return Icons.timer_outlined;
    } else if (stat.label.toLowerCase().contains('operation')) {
      return Icons.settings_outlined;
    } else if (stat.value.contains('100%')) {
      return Icons.trending_up_outlined;
    }
    return Icons.eco_outlined;
  }
}

// ===================== HOVERABLE IMPACT ITEM WIDGET =====================
class HoverableImpactItem extends StatefulWidget {
  final IconData icon;
  final String text;
  final bool isMobile;
  final String details;

  const HoverableImpactItem({
    super.key,
    required this.icon,
    required this.text,
    this.isMobile = false,
    required this.details,
  });

  @override
  State<HoverableImpactItem> createState() => _HoverableImpactItemState();
}

class _HoverableImpactItemState extends State<HoverableImpactItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: widget.details,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: WebColors.greenLight, width: 1),
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(51, 0, 0, 0),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      textStyle: TextStyle(
        fontSize: widget.isMobile ? 10 : 11,
        color: const Color(0xFF444444),
        height: 1.5,
      ),
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: EdgeInsets.symmetric(
            vertical: widget.isMobile ? 8 : 10,
            horizontal: widget.isMobile ? 12 : 16,
          ),
          decoration: BoxDecoration(
            color: _isHovered 
              ? const Color.fromARGB(26, 118, 230, 207)
              : Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: _isHovered 
                ? WebColors.greenLight
                : const Color(0xFFE8F5E9),
              width: _isHovered ? 2 : 1.2,
            ),
            boxShadow: _isHovered
              ? [
                  BoxShadow(
                    color: const Color.fromARGB(51, 118, 230, 207),
                    blurRadius: 15,
                    offset: const Offset(0, 6),
                    spreadRadius: 1,
                  ),
                ]
              : [
                  BoxShadow(
                    color: const Color.fromARGB(26, 0, 0, 0),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                    spreadRadius: 0.5,
                  ),
                ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: _isHovered ? (widget.isMobile ? 26 : 30) : (widget.isMobile ? 24 : 28),
                height: _isHovered ? (widget.isMobile ? 26 : 30) : (widget.isMobile ? 24 : 28),
                decoration: BoxDecoration(
                  color: _isHovered
                    ? WebColors.greenLight
                    : const Color.fromARGB(66, 40, 168, 90),
                  borderRadius: BorderRadius.circular(_isHovered ? 8 : 6),
                ),
                child: Icon(
                  widget.icon,
                  size: _isHovered ? (widget.isMobile ? 14 : 16) : (widget.isMobile ? 13 : 15),
                  color: _isHovered 
                    ? Colors.white 
                    : const Color(0xFF28A85A),
                ),
              ),
              SizedBox(width: widget.isMobile ? AppSpacing.xs : AppSpacing.sm),
              Flexible(
                child: AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 300),
                  style: TextStyle(
                    fontSize: _isHovered ? (widget.isMobile ? 12 : 14) : (widget.isMobile ? 11 : 13),
                    fontWeight: _isHovered ? FontWeight.w600 : FontWeight.w500,
                    color: _isHovered 
                      ? WebColors.textTitle
                      : const Color(0xFF444444),
                  ),
                  child: Text(widget.text),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}