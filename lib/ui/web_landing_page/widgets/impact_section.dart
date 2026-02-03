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
        _currentExpandedInfo = (_currentExpandedInfo + 1) % 3;
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
        vertical: AppSpacing.lg,
      );
    } else if (screenWidth < 1024) {
      return const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.xl,
      );
    } else {
      return const EdgeInsets.symmetric(
        horizontal: AppSpacing.xxl,
        vertical: AppSpacing.xl * 1.5,
      );
    }
  }

  // ===================== MOBILE LAYOUT (<600px) =====================
  Widget _buildMobileLayout(BuildContext context, double screenWidth) {
    final isSmallMobile = screenWidth < 400;
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'MAKING A SUSTAINABLE IMPACT',
          textAlign: TextAlign.center,
          style: WebTextStyles.h2.copyWith(
            fontSize: isSmallMobile ? 26 : 28,
            fontWeight: FontWeight.w700,
            color: WebColors.textTitle,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.xs),
          child: Text(
            'In the Philippines, over 50% of municipal solid waste is organic.\nAccel-O-Rot helps manage waste responsibly.',
            textAlign: TextAlign.center,
            style: WebTextStyles.sectionSubtitle.copyWith(
              fontSize: isSmallMobile ? 14 : 15,
              height: 1.4,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),

        Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: screenWidth < 400 ? 300 : 350,
            ),
            child: Column(
              children: [
                _buildMobileImpactItem(Icons.delete_outline, 'Reduces landfill waste', screenWidth),
                const SizedBox(height: 8),
                _buildMobileImpactItem(Icons.restaurant_outlined, 'Produces nutrient-rich compost', screenWidth),
                const SizedBox(height: 8),
                _buildMobileImpactItem(Icons.eco_outlined, 'Empowers communities', screenWidth),
              ],
            ),
          ),
        ),

        const SizedBox(height: AppSpacing.lg),

        // Grid for mobile
        _buildMobileGrid(screenWidth),
      ],
    );
  }

  Widget _buildMobileImpactItem(IconData icon, String text, double screenWidth) {
    final isHovered = _impactItemHover[text] ?? false;
    final isSmallMobile = screenWidth < 400;
    
    return MouseRegion(
      onEnter: (_) => _safeSetState(() => _impactItemHover[text] = true),
      onExit: (_) => _safeSetState(() => _impactItemHover[text] = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        width: double.infinity,
        padding: EdgeInsets.symmetric(
          vertical: isHovered ? 12 : 10,
          horizontal: 12,
        ),
        decoration: BoxDecoration(
          color: isHovered 
            ? const Color.fromARGB(15, 118, 230, 207)
            : Colors.white,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isHovered 
              ? WebColors.greenLight
              : const Color(0xFFE8F5E9),
            width: isHovered ? 1.5 : 1,
          ),
          boxShadow: isHovered ? [
            BoxShadow(
              color: const Color.fromARGB(20, 118, 230, 207),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ] : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: isHovered
                      ? WebColors.greenLight
                      : const Color.fromARGB(38, 40, 168, 90),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Icon(
                    icon,
                    size: 12,
                    color: isHovered 
                      ? Colors.white 
                      : const Color(0xFF28A85A),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    text,
                    style: TextStyle(
                      fontSize: isSmallMobile ? 14 : 15,
                      fontWeight: isHovered ? FontWeight.w600 : FontWeight.w500,
                      color: isHovered 
                        ? WebColors.textTitle
                        : const Color(0xFF444444),
                    ),
                  ),
                ),
              ],
            ),
            // Description on hover for mobile
            if (isHovered && _impactDescriptions.containsKey(text)) ...[
              const SizedBox(height: 6),
              Padding(
                padding: const EdgeInsets.only(left: 32.0),
                child: Text(
                  _impactDescriptions[text]!,
                  style: TextStyle(
                    fontSize: isSmallMobile ? 10 : 11,
                    color: const Color(0xFF666666),
                    height: 1.3,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMobileGrid(double screenWidth) {
    if (widget.stats.length < 4) {
      return const SizedBox();
    }
    
    final isSmallMobile = screenWidth < 400;
    
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: screenWidth < 400 ? 0 : AppSpacing.sm),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: AppSpacing.sm,
          crossAxisSpacing: AppSpacing.sm,
          childAspectRatio: isSmallMobile ? 1.1 : 1.2,
        ),
        itemCount: widget.stats.length,
        itemBuilder: (context, index) {
          return _buildMobileStatCard(index, widget.stats[index], screenWidth);
        },
      ),
    );
  }

  Widget _buildMobileStatCard(int index, ImpactStatModel stat, double screenWidth) {
    final isSmallMobile = screenWidth < 400;
    final row = index ~/ 2;
    final col = index % 2;
    final isGreen = (row == 0 && col == 0) || (row == 1 && col == 1);
    final isHovered = _expandedIndex == index;

    return MouseRegion(
      onEnter: (_) => _safeSetState(() => _expandedIndex = index),
      onExit: (_) => _safeSetState(() => _expandedIndex = null),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: isGreen 
            ? const Color.fromARGB(255, 74, 211, 126)
            : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isHovered
              ? (isGreen ? Colors.transparent : WebColors.greenLight)
              : (isGreen ? Colors.transparent : const Color(0xFFE0E0E0)),
            width: isHovered ? 1.5 : 1,
          ),
          boxShadow: isHovered ? [
            BoxShadow(
              color: const Color.fromARGB(20, 0, 0, 0),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ] : [
            BoxShadow(
              color: const Color.fromARGB(10, 0, 0, 0),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (stat.label.toLowerCase().contains('week'))
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        stat.value,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: isSmallMobile ? 28 : 32,
                          fontWeight: FontWeight.w800,
                          color: isGreen ? Colors.white : WebColors.textTitle,
                          height: 0.9,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'weeks',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: isSmallMobile ? 20 : 22,
                          fontWeight: FontWeight.w600,
                          color: isGreen ? Colors.white : WebColors.textTitle,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Composting Time',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: isSmallMobile ? 11 : 12,
                          fontWeight: FontWeight.w500,
                          color: isGreen ? Colors.white : const Color(0xFF666666),
                        ),
                      ),
                      // Additional info on hover for mobile
                      if (isHovered) ...[
                        const SizedBox(height: 4),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6.0),
                          child: Text(
                            _getMobileStatDescription(index),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: isSmallMobile ? 9 : 10,
                              color: isGreen ? Colors.white : const Color(0xFF888888),
                              height: 1.2,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ],
                  )
                else
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        stat.value,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: isSmallMobile ? 24 : 28,
                          fontWeight: FontWeight.w800,
                          color: isGreen ? Colors.white : WebColors.textTitle,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6.0),
                        child: Text(
                          stat.label,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: isSmallMobile ? 11 : 12,
                            fontWeight: FontWeight.w500,
                            color: isGreen ? Colors.white : const Color(0xFF666666),
                            height: 1.1,
                          ),
                        ),
                      ),
                      // Additional info on hover for mobile
                      if (isHovered) ...[
                        const SizedBox(height: 4),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text(
                            _getMobileStatDescription(index),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: isSmallMobile ? 9 : 10,
                              color: isGreen ? Colors.white : const Color(0xFF888888),
                              height: 1.2,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ],
                  ),
              ],
            ),
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
      children: [
        Text(
          'Making a Sustainable Impact',
          textAlign: TextAlign.center,
          style: WebTextStyles.h2.copyWith(
            fontSize: isSmallTablet ? 32 : 34,
            fontWeight: FontWeight.w700,
            color: WebColors.textTitle,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
          child: Text(
            'In the Philippines, over 50% of municipal solid waste is organic.\nAccel-O-Rot helps manage waste responsibly.',
            textAlign: TextAlign.center,
            style: WebTextStyles.sectionSubtitle.copyWith(
              fontSize: isSmallTablet ? 16 : 17,
              height: 1.5,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),

        Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: screenWidth < 800 ? 500 : 550,
            ),
            child: Column(
              children: [
                _buildTabletImpactItem(Icons.delete_outline, 'Reduces landfill waste', screenWidth),
                const SizedBox(height: 10),
                _buildTabletImpactItem(Icons.restaurant_outlined, 'Produces nutrient-rich compost', screenWidth),
                const SizedBox(height: 10),
                _buildTabletImpactItem(Icons.eco_outlined, 'Empowers communities', screenWidth),
              ],
            ),
          ),
        ),

        const SizedBox(height: AppSpacing.lg),

        // Grid for tablet
        _buildTabletGrid(screenWidth),
      ],
    );
  }

  Widget _buildTabletImpactItem(IconData icon, String text, double screenWidth) {
    final isHovered = _impactItemHover[text] ?? false;
    final isSmallTablet = screenWidth < 800;
    
    return MouseRegion(
      onEnter: (_) => _safeSetState(() => _impactItemHover[text] = true),
      onExit: (_) => _safeSetState(() => _impactItemHover[text] = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        width: double.infinity,
        padding: EdgeInsets.symmetric(
          vertical: isHovered ? 16 : 14,
          horizontal: 16,
        ),
        decoration: BoxDecoration(
          color: isHovered 
            ? const Color.fromARGB(15, 118, 230, 207)
            : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isHovered 
              ? WebColors.greenLight
              : const Color(0xFFE8F5E9),
            width: isHovered ? 1.5 : 1,
          ),
          boxShadow: isHovered ? [
            BoxShadow(
              color: const Color.fromARGB(20, 118, 230, 207),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ] : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: isHovered
                      ? WebColors.greenLight
                      : const Color.fromARGB(51, 40, 168, 90),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Icon(
                    icon,
                    size: 14,
                    color: isHovered 
                      ? Colors.white 
                      : const Color(0xFF28A85A),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    text,
                    style: TextStyle(
                      fontSize: isSmallTablet ? 14 : 15,
                      fontWeight: isHovered ? FontWeight.w600 : FontWeight.w500,
                      color: isHovered 
                        ? WebColors.textTitle
                        : const Color(0xFF444444),
                    ),
                  ),
                ),
              ],
            ),
            // Description on hover for tablet
            if (isHovered && _impactDescriptions.containsKey(text)) ...[
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.only(left: 40.0),
                child: Text(
                  _impactDescriptions[text]!,
                  style: TextStyle(
                    fontSize: isSmallTablet ? 12 : 13,
                    color: const Color(0xFF666666),
                    height: 1.4,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTabletGrid(double screenWidth) {
    if (widget.stats.length < 4) {
      return const SizedBox();
    }
    
    final isSmallTablet = screenWidth < 800;
    
    return Container(
      padding: EdgeInsets.symmetric(horizontal: screenWidth < 800 ? AppSpacing.md : AppSpacing.lg),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: AppSpacing.md,
          crossAxisSpacing: AppSpacing.md,
          childAspectRatio: isSmallTablet ? 1.3 : 1.4,
        ),
        itemCount: widget.stats.length,
        itemBuilder: (context, index) {
          return _buildTabletStatCard(index, widget.stats[index], screenWidth);
        },
      ),
    );
  }

  Widget _buildTabletStatCard(int index, ImpactStatModel stat, double screenWidth) {
    final isSmallTablet = screenWidth < 800;
    final row = index ~/ 2;
    final col = index % 2;
    final isGreen = (row == 0 && col == 0) || (row == 1 && col == 1);
    final isHovered = _expandedIndex == index;

    return MouseRegion(
      onEnter: (_) => _safeSetState(() => _expandedIndex = index),
      onExit: (_) => _safeSetState(() => _expandedIndex = null),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: isGreen 
            ? const Color.fromARGB(255, 74, 211, 126)
            : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isHovered
              ? (isGreen ? Colors.transparent : WebColors.greenLight)
              : (isGreen ? Colors.transparent : const Color(0xFFE0E0E0)),
            width: isHovered ? 1.8 : 1.3,
          ),
          boxShadow: isHovered ? [
            BoxShadow(
              color: const Color.fromARGB(25, 0, 0, 0),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ] : [
            BoxShadow(
              color: const Color.fromARGB(15, 0, 0, 0),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (stat.label.toLowerCase().contains('week'))
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        stat.value,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: isSmallTablet ? 36 : 40,
                          fontWeight: FontWeight.w800,
                          color: isGreen ? Colors.white : WebColors.textTitle,
                          height: 0.9,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'weeks',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: isSmallTablet ? 28 : 30,
                          fontWeight: FontWeight.w600,
                          color: isGreen ? Colors.white : WebColors.textTitle,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Composting Time',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: isSmallTablet ? 14 : 15,
                          fontWeight: FontWeight.w500,
                          color: isGreen ? Colors.white : const Color(0xFF666666),
                        ),
                      ),
                      // Additional info on hover for tablet
                      if (isHovered) ...[
                        const SizedBox(height: 6),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0),
                          child: Text(
                            _getTabletStatDescription(index),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: isSmallTablet ? 12 : 13,
                              color: isGreen ? Colors.white : const Color(0xFF888888),
                              height: 1.3,
                            ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ],
                  )
                else
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        stat.value,
                        style: TextStyle(
                          fontSize: isSmallTablet ? 34 : 38,
                          fontWeight: FontWeight.w800,
                          color: isGreen ? Colors.white : WebColors.textTitle,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: Text(
                          stat.label,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: isSmallTablet ? 14 : 15,
                            fontWeight: FontWeight.w500,
                            color: isGreen ? Colors.white : const Color(0xFF666666),
                            height: 1.1,
                          ),
                        ),
                      ),
                      // Additional info on hover for tablet
                      if (isHovered) ...[
                        const SizedBox(height: 6),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0),
                          child: Text(
                            _getTabletStatDescription(index),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: isSmallTablet ? 12 : 13,
                              color: isGreen ? Colors.white : const Color(0xFF888888),
                              height: 1.3,
                            ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ===================== DESKTOP LAYOUT (>1024px) =====================
  Widget _buildDesktopLayout(BuildContext context, double screenWidth) {
    final isLargeDesktop = screenWidth > 1440;
    
    if (widget.stats.length < 4) {
      return const Center(child: CircularProgressIndicator());
    }
    
    return SizedBox(
      height: 420,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Left side: 3 impact items
          Expanded(
            flex: isLargeDesktop ? 4 : 3,
            child: Padding(
              padding: EdgeInsets.only(
                right: isLargeDesktop ? AppSpacing.lg : AppSpacing.md,
                left: isLargeDesktop ? AppSpacing.xxl : AppSpacing.xl,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Making a Sustainable Impact',
                    style: WebTextStyles.h2.copyWith(
                      fontSize: isLargeDesktop ? 36 : 32,
                      fontWeight: FontWeight.w700,
                      color: WebColors.textTitle,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  SizedBox(
                    width: double.infinity,
                    child: Text(
                      'In the Philippines, over 50% of municipal solid waste is organic.\nAccel-O-Rot helps manage waste responsibly.',
                      style: WebTextStyles.sectionSubtitle.copyWith(
                        fontSize: isLargeDesktop ? 14 : 13,
                        height: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: isLargeDesktop ? 450 : 400,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildDesktopImpactItem(Icons.delete_outline, 'Reduces landfill waste', screenWidth),
                        const SizedBox(height: 10),
                        _buildDesktopImpactItem(Icons.restaurant_outlined, 'Produces nutrient-rich compost', screenWidth),
                        const SizedBox(height: 10),
                        _buildDesktopImpactItem(Icons.eco_outlined, 'Empowers communities', screenWidth),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Right side: 4 stat cards
          Expanded(
            flex: isLargeDesktop ? 5 : 4,
            child: Padding(
              padding: EdgeInsets.only(
                left: AppSpacing.md,
                right: isLargeDesktop ? AppSpacing.xxxl * 2 : AppSpacing.xxl * 2,
              ),
              child: SizedBox(
                width: isLargeDesktop ? 460 : 420,
                height: 350,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Base grid
                    if (_expandedIndex == null)
                      _buildDesktopGrid(screenWidth),
                    
                    // Expanded card overlay
                    if (_expandedIndex != null && _expandedIndex! < widget.stats.length)
                      _buildExpandedDesktopCard(_expandedIndex!, screenWidth),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopImpactItem(IconData icon, String text, double screenWidth) {
    final isHovered = _impactItemHover[text] ?? false;
    
    return MouseRegion(
      onEnter: (_) => _safeSetState(() => _impactItemHover[text] = true),
      onExit: (_) => _safeSetState(() => _impactItemHover[text] = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        width: double.infinity,
        padding: EdgeInsets.symmetric(
          vertical: isHovered ? 12 : 10,
          horizontal: isHovered ? 16 : 12,
        ),
        decoration: BoxDecoration(
          color: isHovered 
            ? const Color.fromARGB(15, 118, 230, 207)
            : Colors.white,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isHovered 
              ? WebColors.greenLight
              : const Color(0xFFE8F5E9),
            width: isHovered ? 1.5 : 1,
          ),
          boxShadow: isHovered ? [
            BoxShadow(
              color: const Color.fromARGB(20, 118, 230, 207),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ] : [
            BoxShadow(
              color: const Color.fromARGB(8, 0, 0, 0),
              blurRadius: 3,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: isHovered ? 28 : 26,
                  height: isHovered ? 28 : 26,
                  decoration: BoxDecoration(
                    color: isHovered
                      ? WebColors.greenLight
                      : const Color.fromARGB(51, 40, 168, 90),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Icon(
                    icon,
                    size: isHovered ? 16 : 14,
                    color: isHovered 
                      ? Colors.white 
                      : const Color(0xFF28A85A),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    text,
                    style: TextStyle(
                      fontSize: isHovered 
                        ? (screenWidth > 1440 ? 14 : 13)
                        : (screenWidth > 1440 ? 13 : 12),
                      fontWeight: isHovered ? FontWeight.w600 : FontWeight.w500,
                      color: isHovered 
                        ? WebColors.textTitle
                        : const Color(0xFF444444),
                    ),
                  ),
                ),
              ],
            ),
            if (isHovered && _impactDescriptions.containsKey(text)) ...[
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.only(left: 38.0),
                child: Text(
                  _impactDescriptions[text]!,
                  style: TextStyle(
                    fontSize: screenWidth > 1440 ? 11 : 10,
                    color: const Color(0xFF666666),
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ],
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
                onEnter: (_) => _safeSetState(() => _expandedIndex = 0),
                child: _buildDesktopStatCard(0, widget.stats[0], screenWidth),
              ),
            ),
            SizedBox(width: isLargeDesktop ? AppSpacing.md : AppSpacing.sm),
            Expanded(
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                onEnter: (_) => _safeSetState(() => _expandedIndex = 1),
                child: _buildDesktopStatCard(1, widget.stats[1], screenWidth),
              ),
            ),
          ],
        ),
        SizedBox(height: isLargeDesktop ? AppSpacing.md : AppSpacing.sm),
        Row(
          children: [
            Expanded(
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                onEnter: (_) => _safeSetState(() => _expandedIndex = 2),
                child: _buildDesktopStatCard(2, widget.stats[2], screenWidth),
              ),
            ),
            SizedBox(width: isLargeDesktop ? AppSpacing.md : AppSpacing.sm),
            Expanded(
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                onEnter: (_) => _safeSetState(() => _expandedIndex = 3),
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

    return MouseRegion(
      onEnter: (_) => _safeSetState(() => _expandedIndex = index),
      onExit: (_) => _safeSetState(() => _expandedIndex = null),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        height: 130,
        decoration: BoxDecoration(
          color: isGreen 
            ? const Color.fromARGB(255, 74, 211, 126)
            : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isGreen ? Colors.transparent : const Color(0xFFE0E0E0),
            width: 1.5,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color.fromARGB(25, 0, 0, 0),
              blurRadius: 10,
              spreadRadius: 1,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (stat.label.toLowerCase().contains('week'))
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          stat.value,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: isGreen ? Colors.white : WebColors.textTitle,
                            height: 0.9,
                          ),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'weeks',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          color: isGreen ? Colors.white : WebColors.textTitle,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Composting Time',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
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
                          stat.value,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: isGreen ? Colors.white : WebColors.textTitle,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6.0),
                        child: Text(
                          stat.label,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
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
    ];

    return MouseRegion(
      onExit: (_) => _safeSetState(() {
        _expandedIndex = null;
        _currentExpandedInfo = 0;
      }),
      child: GestureDetector(
        onTap: _swipeToNext,
        child: AnimatedBuilder(
          animation: _swipeAnimation,
          builder: (context, child) {
            final currentInfo = expandedInfos[_currentExpandedInfo];
            
            return Transform.translate(
              offset: Offset(0, -8 * math.sin(_swipeAnimation.value * math.pi)),
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: 1.0 - (_swipeAnimation.value * 0.3),
                child: Container(
                  width: double.infinity,
                  height: 340,
                  decoration: BoxDecoration(
                    color: isGreen 
                      ? const Color.fromARGB(255, 74, 211, 126)
                      : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isGreen ? Colors.transparent : WebColors.greenLight,
                      width: 2.0,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color.fromARGB(35, 0, 0, 0),
                        blurRadius: 16,
                        spreadRadius: 1,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Icon section
                      Padding(
                        padding: const EdgeInsets.only(top: 16.0),
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: isGreen 
                              ? const Color.fromARGB(90, 255, 255, 255)
                              : const Color.fromARGB(45, 118, 230, 207),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isGreen ? Colors.white : WebColors.greenLight,
                              width: 1.5,
                            ),
                          ),
                          child: Icon(
                            currentInfo['icon'] as IconData,
                            size: 20,
                            color: isGreen ? Colors.white : WebColors.greenLight,
                          ),
                        ),
                      ),
                      
                      // Stat value section
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            if (stat.label.toLowerCase().contains('week'))
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      stat.value,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: isLargeDesktop ? 32 : 28,
                                        fontWeight: FontWeight.w800,
                                        color: isGreen ? Colors.white : WebColors.textTitle,
                                        height: 0.9,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'weeks',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: isLargeDesktop ? 22 : 20,
                                      fontWeight: FontWeight.w600,
                                      color: isGreen ? Colors.white : WebColors.textTitle,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Composting Time',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: isLargeDesktop ? 13 : 12,
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
                                      stat.value,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: isLargeDesktop ? 32 : 28,
                                        fontWeight: FontWeight.w800,
                                        color: isGreen ? Colors.white : WebColors.textTitle,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    stat.label,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: isLargeDesktop ? 13 : 12,
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
                        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                        child: Divider(
                          color: isGreen 
                            ? const Color.fromARGB(120, 255, 255, 255)
                            : const Color(0xFFE0E0E0),
                          thickness: 1.0,
                        ),
                      ),
                      
                      // Title section
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text(
                          currentInfo['title'],
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: isLargeDesktop ? 15 : 14,
                            fontWeight: FontWeight.w700,
                            color: isGreen ? Colors.white : WebColors.textTitle,
                          ),
                        ),
                      ),
                      
                      // Description section - now with fixed height and proper scrolling
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                          child: SingleChildScrollView(
                            physics: const BouncingScrollPhysics(),
                            child: Text(
                              currentInfo['description'],
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: isLargeDesktop ? 12 : 11,
                                fontWeight: FontWeight.normal,
                                color: isGreen 
                                  ? const Color.fromARGB(230, 255, 255, 255)
                                  : const Color(0xFF666666),
                                height: 1.4,
                              ),
                            ),
                          ),
                        ),
                      ),
                      
                      // Navigation dots and instruction
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(3, (i) {
                                return Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 2),
                                  width: i == _currentExpandedInfo ? 16 : 5,
                                  height: 5,
                                  decoration: BoxDecoration(
                                    color: i == _currentExpandedInfo 
                                      ? (isGreen ? Colors.white : WebColors.greenLight)
                                      : (isGreen 
                                          ? const Color.fromARGB(100, 255, 255, 255)
                                          : const Color(0xFFE0E0E0)),
                                    borderRadius: BorderRadius.circular(2.5),
                                  ),
                                );
                              }),
                            ),
                            const SizedBox(height: 4),
                          
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // Helper method to get mobile stat description
  String _getMobileStatDescription(int index) {
    switch (index) {
      case 0:
        return 'Traditional composting takes months. Our technology accelerates the process significantly.';
      case 1:
        return 'Biodegradable waste makes up over half of all municipal solid waste in the Philippines.';
      case 2:
        return 'Our system operates with minimal human intervention, automating the composting process.';
      case 3:
        return 'IoT technology provides real-time monitoring and adjustments for optimal composting.';
      default:
        return 'Sustainable waste management solution for communities.';
    }
  }

  // Helper method to get tablet stat description
  String _getTabletStatDescription(int index) {
    switch (index) {
      case 0:
        return 'Traditional composting takes 3-6 months. Our technology reduces this to just 2 weeks through optimized conditions.';
      case 1:
        return 'Over 50% of municipal solid waste is organic material that can be composted instead of going to landfills.';
      case 2:
        return 'IoT-enabled system operates 24/7 with minimal human intervention, providing real-time monitoring.';
      case 3:
        return 'Smart technology automates temperature, moisture, and aeration for optimal composting conditions.';
      default:
        return 'Sustainable waste management solution that empowers communities and reduces environmental impact.';
    }
  }

  void _safeSetState(VoidCallback callback) {
    if (mounted) {
      setState(callback);
    }
  }
}