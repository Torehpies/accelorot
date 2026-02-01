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
  int? _expandedIndex;
  final Map<String, bool> _impactItemHover = {
    'Reduces landfill waste': false,
    'Produces nutrient-rich compost': false,
    'Empowers communities': false,
  };
  
  // Map for impact item descriptions
  final Map<String, String> _impactDescriptions = {
    'Reduces landfill waste': 'Addresses the pressing environmental concern in the Philippines where over 50% of municipal solid waste is organic. Prevents methane emissions from landfills that contribute to climate change.',
    'Produces nutrient-rich compost': 'Transforms organic waste into high-quality compost through accelerated decomposition. Improves soil health and reduces need for chemical fertilizers in agriculture.',
    'Empowers communities': 'Supports Republic Act 9003 implementation by providing accessible composting technology. Reduces manual labor and makes sustainable waste management practical for households and communities.',
  };

  @override
  void initState() {
    super.initState();
    // Initialize hover states
    _impactItemHover['Reduces landfill waste'] = false;
    _impactItemHover['Produces nutrient-rich compost'] = false;
    _impactItemHover['Empowers communities'] = false;
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
          
          // Ensure widget.stats is not null
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
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'MAKING A SUSTAINABLE IMPACT',
          textAlign: TextAlign.center,
          style: WebTextStyles.h2.copyWith(
            fontSize: screenWidth < 400 ? 24 : 26, // INCREASED from 20:22 to 24:26
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
              fontSize: screenWidth < 400 ? 11 : 12,
              height: 1.4,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),

        // 3 Containers in CENTER for mobile (MINIMIZED HEIGHT)
        Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: screenWidth < 400 ? 320 : 380,
            ),
            child: Column(
              children: [
                _buildMobileImpactItem(
                  Icons.delete_outline, 
                  'Reduces landfill waste',
                  screenWidth,
                ),
                const SizedBox(height: 6),
                _buildMobileImpactItem(
                  Icons.restaurant_outlined, 
                  'Produces nutrient-rich compost',
                  screenWidth,
                ),
                const SizedBox(height: 6),
                _buildMobileImpactItem(
                  Icons.eco_outlined, 
                  'Empowers communities',
                  screenWidth,
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: AppSpacing.lg),

        // Grid for mobile with MAXIMIZED sizes
        _buildMobileGrid(screenWidth),
      ],
    );
  }

  Widget _buildMobileImpactItem(IconData icon, String text, double screenWidth) {
    final isHovered = _impactItemHover[text] ?? false;
    
    return MouseRegion(
      onEnter: (_) => _safeSetState(() => _impactItemHover[text] = true),
      onExit: (_) => _safeSetState(() => _impactItemHover[text] = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        width: double.infinity,
        padding: EdgeInsets.symmetric(
          vertical: isHovered ? 8 : 6, // Reduced vertical padding
          horizontal: 10,
        ),
        decoration: BoxDecoration(
          color: isHovered 
            ? const Color.fromARGB(15, 118, 230, 207)
            : Colors.white, // Changed from Color(0xFFF8F9FA) to Colors.white
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
          ] : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 18, // Reduced size
                  height: 18,
                  decoration: BoxDecoration(
                    color: isHovered
                      ? WebColors.greenLight
                      : const Color.fromARGB(38, 40, 168, 90),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Icon(
                    icon,
                    size: 9, // Reduced icon size
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
                      fontSize: screenWidth < 400 ? 9 : 10,
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
              const SizedBox(height: 4), // Reduced spacing
              Padding(
                padding: const EdgeInsets.only(left: 26.0), // Adjusted left padding
                child: Text(
                  _impactDescriptions[text]!,
                  style: TextStyle(
                    fontSize: screenWidth < 400 ? 7 : 8, // Reduced font size
                    color: const Color(0xFF666666),
                    height: 1.3,
                  ),
                  maxLines: 2, // Limit to 2 lines
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
    
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth < 400 ? 0 : AppSpacing.sm,
      ),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: AppSpacing.sm, // Increased spacing
          crossAxisSpacing: AppSpacing.sm, // Increased spacing
          childAspectRatio: screenWidth < 400 ? 1.0 : 1.1, // Increased aspect ratio for larger cards
        ),
        itemCount: widget.stats.length,
        itemBuilder: (context, index) {
          return _buildMobileStatCard(index, widget.stats[index], screenWidth);
        },
      ),
    );
  }

  Widget _buildMobileStatCard(int index, ImpactStatModel stat, double screenWidth) {
    final row = index ~/ 2;
    final col = index % 2;
    final isGreen = (row == 0 && col == 0) || (row == 1 && col == 1);
    final isHovered = _expandedIndex == index;

    return MouseRegion(
      onEnter: (_) => _safeSetState(() => _expandedIndex = index),
      onExit: (_) => _safeSetState(() => _expandedIndex = null),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        height: screenWidth < 400 ? 90 : 100, // Increased height
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
        child: _buildMobileNormalContent(index, stat, isGreen, screenWidth, isHovered),
      ),
    );
  }

  Widget _buildMobileNormalContent(int index, ImpactStatModel stat, bool isGreen, double screenWidth, bool isHovered) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(6.0),
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
                      fontSize: screenWidth < 400 ? 22 : 24, // Increased font size
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
                      fontSize: screenWidth < 400 ? 14 : 16, // Increased font size
                      fontWeight: FontWeight.w600,
                      color: isGreen ? Colors.white : WebColors.textTitle,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Composting Time',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 9, // Increased font size
                      fontWeight: isHovered ? FontWeight.w600 : FontWeight.w500,
                      color: isGreen ? Colors.white : const Color(0xFF666666),
                    ),
                  ),
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
                      fontSize: screenWidth < 400 ? 18 : 20, // Increased font size
                      fontWeight: FontWeight.w800,
                      color: isGreen ? Colors.white : WebColors.textTitle,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: Text(
                      stat.label,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 9, // Increased font size
                        fontWeight: isHovered ? FontWeight.w600 : FontWeight.w500,
                        color: isGreen ? Colors.white : const Color(0xFF666666),
                        height: 1.1,
                      ),
                    ),
                  ),
                ],
              ),
            if (isHovered) ...[
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: Text(
                  _getMobileAdditionalInfo(index),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 7,
                    color: isGreen 
                      ? const Color.fromARGB(180, 255, 255, 255)
                      : const Color(0xFF888888),
                    height: 1.2,
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

  String _getMobileAdditionalInfo(int index) {
    switch(index) {
      case 0: return 'Over 50% of total waste is organic annually';
      case 1: return 'Reduces from months to just 2 weeks';
      case 2: return 'IoT-enabled 24/7 operation';
      case 3: return '100% efficiency in waste conversion';
      default: return '';
    }
  }

  // ===================== TABLET LAYOUT (600-1024px) =====================
  Widget _buildTabletLayout(BuildContext context, double screenWidth) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Making a Sustainable Impact',
          textAlign: TextAlign.center,
          style: WebTextStyles.h2.copyWith(
            fontSize: screenWidth < 800 ? 28 : 30, // INCREASED from 26:28 to 28:30
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
              fontSize: screenWidth < 800 ? 13 : 14,
              height: 1.5,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),

        // 3 Containers in CENTER for tablet (MINIMIZED HEIGHT)
        Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: screenWidth < 800 ? 500 : 550,
            ),
            child: Column(
              children: [
                _buildTabletImpactItem(
                  Icons.delete_outline, 
                  'Reduces landfill waste',
                  screenWidth,
                ),
                const SizedBox(height: 8),
                _buildTabletImpactItem(
                  Icons.restaurant_outlined, 
                  'Produces nutrient-rich compost',
                  screenWidth,
                ),
                const SizedBox(height: 8),
                _buildTabletImpactItem(
                  Icons.eco_outlined, 
                  'Empowers communities',
                  screenWidth,
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: AppSpacing.xl),

        // Grid for tablet with MAXIMIZED sizes
        _buildTabletGrid(screenWidth),
      ],
    );
  }

  Widget _buildTabletImpactItem(IconData icon, String text, double screenWidth) {
    final isHovered = _impactItemHover[text] ?? false;
    
    return MouseRegion(
      onEnter: (_) => _safeSetState(() => _impactItemHover[text] = true),
      onExit: (_) => _safeSetState(() => _impactItemHover[text] = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        width: double.infinity,
        padding: EdgeInsets.symmetric(
          vertical: isHovered ? 10 : 8, // Reduced vertical padding
          horizontal: 12,
        ),
        decoration: BoxDecoration(
          color: isHovered 
            ? const Color.fromARGB(15, 118, 230, 207)
            : Colors.white, // Changed from Color(0xFFF8F9FA) to Colors.white
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
              blurRadius: 10,
              offset: const Offset(0, 3),
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
                  width: 22, // Reduced size
                  height: 22,
                  decoration: BoxDecoration(
                    color: isHovered
                      ? WebColors.greenLight
                      : const Color.fromARGB(51, 40, 168, 90),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Icon(
                    icon,
                    size: 12, // Reduced icon size
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
                      fontSize: screenWidth < 800 ? 12 : 13,
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
              const SizedBox(height: 6), // Reduced spacing
              Padding(
                padding: const EdgeInsets.only(left: 32.0), // Adjusted left padding
                child: Text(
                  _impactDescriptions[text]!,
                  style: TextStyle(
                    fontSize: screenWidth < 800 ? 9 : 10, // Reduced font size
                    color: const Color(0xFF666666),
                    height: 1.4,
                  ),
                  maxLines: 2, // Limit to 2 lines
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
    
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth < 800 ? AppSpacing.md : AppSpacing.lg,
      ),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: AppSpacing.md, // Increased spacing
          crossAxisSpacing: AppSpacing.md, // Increased spacing
          childAspectRatio: screenWidth < 800 ? 1.2 : 1.3, // Increased aspect ratio for larger cards
        ),
        itemCount: widget.stats.length,
        itemBuilder: (context, index) {
          return _buildTabletStatCard(index, widget.stats[index], screenWidth);
        },
      ),
    );
  }

  Widget _buildTabletStatCard(int index, ImpactStatModel stat, double screenWidth) {
    final row = index ~/ 2;
    final col = index % 2;
    final isGreen = (row == 0 && col == 0) || (row == 1 && col == 1);
    final isHovered = _expandedIndex == index;

    return MouseRegion(
      onEnter: (_) => _safeSetState(() => _expandedIndex = index),
      onExit: (_) => _safeSetState(() => _expandedIndex = null),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        height: screenWidth < 800 ? 130 : 140, // Increased height
        decoration: BoxDecoration(
          color: isGreen 
            ? const Color.fromARGB(255, 74, 211, 126)
            : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isHovered
              ? (isGreen ? Colors.transparent : WebColors.greenLight)
              : (isGreen ? Colors.transparent : const Color(0xFFE0E0E0)),
            width: isHovered ? 2.0 : 1.5,
          ),
          boxShadow: isHovered ? [
            BoxShadow(
              color: const Color.fromARGB(25, 0, 0, 0),
              blurRadius: 12,
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
        child: _buildTabletNormalContent(index, stat, isGreen, isHovered),
      ),
    );
  }

  Widget _buildTabletNormalContent(int index, ImpactStatModel stat, bool isGreen, bool isHovered) {
    return Center(
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
                      fontSize: 28, // Increased font size
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
                      fontSize: 22, // Increased font size
                      fontWeight: FontWeight.w600,
                      color: isGreen ? Colors.white : WebColors.textTitle,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Composting Time',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12, // Increased font size
                      fontWeight: isHovered ? FontWeight.w600 : FontWeight.w500,
                      color: isGreen ? Colors.white : const Color(0xFF666666),
                    ),
                  ),
                ],
              )
            else
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    stat.value,
                    style: TextStyle(
                      fontSize: 26, // Increased font size
                      fontWeight: FontWeight.w800,
                      color: isGreen ? Colors.white : WebColors.textTitle,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(
                      stat.label,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11, // Increased font size
                        fontWeight: isHovered ? FontWeight.w600 : FontWeight.w500,
                        color: isGreen ? Colors.white : const Color(0xFF666666),
                        height: 1.1,
                      ),
                    ),
                  ),
                ],
              ),
            if (isHovered) ...[
              const SizedBox(height: 6),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(
                  _getTabletAdditionalInfo(index),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: isGreen 
                      ? const Color.fromARGB(200, 255, 255, 255)
                      : const Color(0xFF888888),
                    height: 1.3,
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

  String _getTabletAdditionalInfo(int index) {
    switch(index) {
      case 0: return 'Biodegradable materials account for more than 50% of total waste';
      case 1: return 'Accel-O-Rot reduces composting time from months to just 2 weeks';
      case 2: return 'Our IoT-enabled system operates 24/7 with minimal intervention';
      case 3: return 'Achieves over 100% efficiency in waste conversion';
      default: return '';
    }
  }

  // ===================== DESKTOP LAYOUT (>1024px) =====================
  Widget _buildDesktopLayout(BuildContext context, double screenWidth) {
    final isLargeDesktop = screenWidth > 1440;
    
    if (widget.stats.length < 4) {
      return const Center(child: CircularProgressIndicator());
    }
    
    return SizedBox(
      height: 500, // Reduced height for minimized 3 containers
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Left side: 3 impact items (MINIMIZED HEIGHT)
          Expanded(
            flex: isLargeDesktop ? 4 : 3, // Reduced flex for smaller 3 containers
            child: Padding(
              padding: EdgeInsets.only(
                right: isLargeDesktop ? AppSpacing.lg : AppSpacing.md, // Reduced right padding
                left: isLargeDesktop ? AppSpacing.xxl : AppSpacing.xl, // Increased left padding to move right
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Making a Sustainable Impact',
                    style: WebTextStyles.h2.copyWith(
                      fontSize: isLargeDesktop ? 36 : 32, // INCREASED from 30:26 to 36:32
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
                        fontSize: isLargeDesktop ? 14 : 13, // Reduced font size
                        height: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg), // Reduced spacing
                  
                  // 3 Containers with MINIMIZED HEIGHT
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: isLargeDesktop ? 450 : 400, // Reduced max width
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildDesktopImpactItem(
                          Icons.delete_outline, 
                          'Reduces landfill waste',
                          screenWidth,
                        ),
                        const SizedBox(height: 10), // Reduced spacing
                        _buildDesktopImpactItem(
                          Icons.restaurant_outlined, 
                          'Produces nutrient-rich compost',
                          screenWidth,
                        ),
                        const SizedBox(height: 10), // Reduced spacing
                        _buildDesktopImpactItem(
                          Icons.eco_outlined, 
                          'Empowers communities',
                          screenWidth,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Right side: 4 stat cards (MOVED MORE TOWARD CENTER with increased left padding)
          Expanded(
            flex: isLargeDesktop ? 6 : 5, // Increased flex for larger 4 containers
            child: Align(
              alignment: Alignment.centerRight, // Changed to centerRight
              child: Padding(
                padding: EdgeInsets.only(
                  left: isLargeDesktop ? AppSpacing.xl : AppSpacing.lg, // INCREASED left padding to move toward center
                  right: isLargeDesktop ? AppSpacing.xxxl : AppSpacing.xxl, // Increased right padding
                ),
                child: SizedBox(
                  width: isLargeDesktop ? 460 : 420, // Increased width for larger cards
                  height: 420, // Increased height
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 400),
                    child: _expandedIndex != null && _expandedIndex! < widget.stats.length
                        ? _buildExpandedDesktopCard(_expandedIndex!, screenWidth)
                        : _buildDesktopGrid(screenWidth),
                  ),
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
          vertical: isHovered ? 12 : 10, // Reduced vertical padding
          horizontal: isHovered ? 16 : 12, // Reduced horizontal padding
        ),
        decoration: BoxDecoration(
          color: isHovered 
            ? const Color.fromARGB(15, 118, 230, 207)
            : Colors.white, // Changed from Color(0xFFF8F9FA) to Colors.white
          borderRadius: BorderRadius.circular(6), // Reduced border radius
          border: Border.all(
            color: isHovered 
              ? WebColors.greenLight
              : const Color(0xFFE8F5E9),
            width: isHovered ? 1.5 : 1, // Reduced border width
          ),
          boxShadow: isHovered ? [
            BoxShadow(
              color: const Color.fromARGB(20, 118, 230, 207),
              blurRadius: 8, // Reduced blur radius
              offset: const Offset(0, 2),
            ),
          ] : [
            BoxShadow(
              color: const Color.fromARGB(8, 0, 0, 0), // Lighter shadow
              blurRadius: 3, // Reduced blur radius
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
                  width: isHovered ? 28 : 26, // Reduced size
                  height: isHovered ? 28 : 26,
                  decoration: BoxDecoration(
                    color: isHovered
                      ? WebColors.greenLight
                      : const Color.fromARGB(51, 40, 168, 90),
                    borderRadius: BorderRadius.circular(5), // Reduced border radius
                  ),
                  child: Icon(
                    icon,
                    size: isHovered ? 16 : 14, // Reduced icon size
                    color: isHovered 
                      ? Colors.white 
                      : const Color(0xFF28A85A),
                  ),
                ),
                const SizedBox(width: 10), // Reduced spacing
                Expanded(
                  child: Text(
                    text,
                    style: TextStyle(
                      fontSize: isHovered 
                        ? (screenWidth > 1440 ? 14 : 13) // Reduced font size
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
              const SizedBox(height: 8), // Reduced spacing
              Padding(
                padding: const EdgeInsets.only(left: 38.0), // Adjusted left padding
                child: Text(
                  _impactDescriptions[text]!,
                  style: TextStyle(
                    fontSize: screenWidth > 1440 ? 11 : 10, // Reduced font size
                    color: const Color(0xFF666666),
                    height: 1.4,
                  ),
                  maxLines: 2, // Limit to 2 lines
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

    return Container(
      height: 150, // Increased height
      decoration: BoxDecoration(
        color: isGreen 
          ? const Color.fromARGB(255, 74, 211, 126)
          : Colors.white,
        borderRadius: BorderRadius.circular(12), // Larger border radius
        border: Border.all(
          color: isGreen ? Colors.transparent : const Color(0xFFE0E0E0),
          width: 1.5, // Thicker border
        ),
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(25, 0, 0, 0), // Darker shadow
            blurRadius: 10,
            spreadRadius: 1,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
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
                      fontSize: 32, // Increased font size
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
                      fontSize: 26, // Increased font size
                      fontWeight: FontWeight.w600,
                      color: isGreen ? Colors.white : WebColors.textTitle,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Composting Time',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14, // Increased font size
                      fontWeight: FontWeight.w500,
                      color: isGreen ? Colors.white : const Color(0xFF666666),
                    ),
                  ),
                ],
              )
            else
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    stat.value,
                    style: TextStyle(
                      fontSize: 30, // Increased font size
                      fontWeight: FontWeight.w800,
                      color: isGreen ? Colors.white : WebColors.textTitle,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: Text(
                      stat.label,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13, // Increased font size
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

    return MouseRegion(
      onExit: (_) => _safeSetState(() => _expandedIndex = null),
      child: Container(
        height: 340, // Increased height
        decoration: BoxDecoration(
          color: isGreen 
            ? const Color.fromARGB(255, 74, 211, 126)
            : Colors.white,
        borderRadius: BorderRadius.circular(14), // Larger border radius
          border: Border.all(
            color: isGreen ? Colors.transparent : WebColors.greenLight,
            width: 2.0, // Thicker border
          ),
          boxShadow: [
            BoxShadow(
              color: const Color.fromARGB(35, 0, 0, 0), // Darker shadow
              blurRadius: 18,
              spreadRadius: 2,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(18.0), // Increased padding
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 55, // Larger icon container
                height: 55,
                decoration: BoxDecoration(
                  color: isGreen 
                    ? const Color.fromARGB(90, 255, 255, 255)
                    : const Color.fromARGB(45, 118, 230, 207),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isGreen ? Colors.white : WebColors.greenLight,
                    width: 1.8,
                  ),
                ),
                child: Icon(
                  _getIconForIndex(stat),
                  size: 26, // Larger icon
                  color: isGreen ? Colors.white : WebColors.greenLight,
                ),
              ),
              const SizedBox(height: 14),
              
              if (stat.label.toLowerCase().contains('week'))
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      stat.value,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: isLargeDesktop ? 44 : 40, // Increased font size
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
                        fontSize: isLargeDesktop ? 32 : 28, // Increased font size
                        fontWeight: FontWeight.w600,
                        color: isGreen ? Colors.white : WebColors.textTitle,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Composting Time',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: isLargeDesktop ? 18 : 16, // Increased font size
                        fontWeight: FontWeight.w600,
                        color: isGreen ? Colors.white : WebColors.textTitle,
                      ),
                    ),
                  ],
                )
              else
                Column(
                  children: [
                    Text(
                      stat.value,
                      style: TextStyle(
                        fontSize: isLargeDesktop ? 44 : 40, // Increased font size
                        fontWeight: FontWeight.w800,
                        color: isGreen ? Colors.white : WebColors.textTitle,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      stat.label,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: isLargeDesktop ? 18 : 16, // Increased font size
                        fontWeight: FontWeight.w600,
                        color: isGreen ? Colors.white : WebColors.textTitle,
                      ),
                    ),
                  ],
                ),
              
              const SizedBox(height: 14),
              
              Divider(
                color: isGreen 
                  ? const Color.fromARGB(120, 255, 255, 255)
                  : const Color(0xFFE0E0E0),
                thickness: 1.5,
              ),
              
              const SizedBox(height: 14),
              
              Expanded(
                child: SingleChildScrollView(
                  child: Text(
                    _getCompactDesktopAdditionalInfo(index),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: isLargeDesktop ? 14 : 13, // Increased font size
                      fontWeight: FontWeight.normal,
                      color: isGreen 
                        ? const Color.fromARGB(230, 255, 255, 255)
                        : const Color(0xFF666666),
                      height: 1.6,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getCompactDesktopAdditionalInfo(int index) {
    switch(index) {
      case 0: return 'Biodegradable materials account for more than 50% of total municipal solid waste annually. This significant portion highlights the urgent need for effective organic waste management solutions.';
      case 1: return 'Accel-O-Rot reduces composting time from months to just 2 weeks through optimized conditions, temperature control, and efficient aeration systems.';
      case 2: return 'Our IoT-enabled system operates 24/7 with minimal human intervention, providing real-time monitoring and automated adjustments for optimal composting conditions.';
      case 3: return 'Accel-O-Rot achieves over 100% efficiency in waste conversion compared to traditional methods, producing higher quality compost with better nutrient retention.';
      default: return '';
    }
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

  // Safe setState method to prevent errors during hot reload
  void _safeSetState(VoidCallback callback) {
    if (mounted) {
      setState(callback);
    }
  }
}