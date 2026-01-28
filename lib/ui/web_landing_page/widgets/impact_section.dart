// lib/ui/landing_page/widgets/impact_section.dart

import 'package:flutter/material.dart';
import '../../core/constants/spacing.dart';
import '../../core/themes/web_text_styles.dart';
import '../../core/themes/web_colors.dart';
import '../models/impact_stat_model.dart';

class ImpactSection extends StatelessWidget {
  final List<ImpactStatModel> stats;
  const ImpactSection({
    super.key,
    required this.stats,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xxxl,
        vertical: AppSpacing.xl,
      ),
      color: Colors.white,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 900;
          return isMobile
              ? _buildMobileLayout(context)
              : _buildDesktopLayout(context, constraints.maxHeight);
        },
      ),
    );
  }

  // ===================== MOBILE =====================
  Widget _buildMobileLayout(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'MAKING A SUSTAINABLE IMPACT',
            textAlign: TextAlign.center,
            style: WebTextStyles.h2.copyWith(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: WebColors.textTitle,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Text(
              'In the Philippines, over 50% of municipal solid waste is organic.\nAccel-O-Rot helps manage waste responsibly.',
              textAlign: TextAlign.center,
              style: WebTextStyles.sectionSubtitle.copyWith(
                fontSize: 14,
                height: 1.6,
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

          // Grid with expandable cards
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: AppSpacing.lg,
              crossAxisSpacing: AppSpacing.lg,
              childAspectRatio: 0.9,
            ),
            itemCount: stats.length,
            itemBuilder: (context, index) {
              return _buildStatsContainer(index, stats[index], isMobile: true);
            },
          ),
          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }

  // ===================== DESKTOP =====================
  Widget _buildDesktopLayout(BuildContext context, double maxHeight) {
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
                      fontSize: 36,
                      fontWeight: FontWeight.w700,
                      color: WebColors.textTitle,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  SizedBox(
                    width: 500,
                    child: Text(
                      'In the Philippines, over 50% of municipal solid waste is organic.\nAccel-O-Rot helps manage waste responsibly.',
                      style: WebTextStyles.sectionSubtitle.copyWith(
                        fontSize: 16,
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
                    width: 420,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _buildStatsContainer(0, stats[0]),
                            ),
                            const SizedBox(width: AppSpacing.lg),
                            Expanded(
                              child: _buildStatsContainer(1, stats[1]),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        Row(
                          children: [
                            Expanded(
                              child: _buildStatsContainer(2, stats[2]),
                            ),
                            const SizedBox(width: AppSpacing.lg),
                            Expanded(
                              child: _buildStatsContainer(3, stats[3]),
                            ),
                          ],
                        ),
                      ],
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

  // ===================== STAT CARD =====================
  Widget _buildStatsContainer(int index, ImpactStatModel stat, {bool isMobile = false}) {
    final row = index ~/ 2;
    final col = index % 2;
    final isGreen = (row == 0 && col == 0) || (row == 1 && col == 1);

    // Updated additional information based on research paper
    final Map<int, String> additionalInfo = {
      0: 'In the Philippines, biodegradable materials account for more than 50% of total municipal solid waste annually. Traditional composting faces challenges like inconsistent decomposition and long processing times.',
      1: 'Accel-O-Rot reduces composting time from months to just 2 weeks through optimized aeration, moisture regulation, and real-time monitoring, producing mature compost faster and more consistently.',
      2: 'Our IoT-enabled system operates 24/7 with minimal human intervention, continuously monitoring and adjusting conditions to ensure optimal decomposition and prevent odor issues.',
      3: 'Accel-O-Rot achieves over 100% efficiency in waste conversion compared to traditional methods, producing higher quality compost while reducing greenhouse gas emissions.',
    };

    return ExpandableStatCard(
      stat: stat,
      isGreen: isGreen,
      isMobile: isMobile,
      additionalInfo: additionalInfo[index] ?? '',
    );
  }

  // ===================== IMPACT ITEM =====================
  Widget _buildImpactItem(IconData icon, String text, {bool isMobile = false}) {
    // Updated impact item details based on research paper
    final Map<String, String> impactDetails = {
      'Reduces landfill waste': 'Addresses the pressing environmental concern in the Philippines where over 50% of municipal solid waste is organic. Prevents methane emissions from landfills that contribute to climate change.',
      'Produces nutrient-rich compost': 'Transforms organic waste into high-quality compost through accelerated decomposition. Improves soil health and reduces need for chemical fertilizers in agriculture.',
      'Empowers communities': 'Supports Republic Act 9003 implementation by providing accessible composting technology. Reduces manual labor and makes sustainable waste management practical for households and communities.',
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
}

// ===================== EXPANDABLE STAT CARD WIDGET =====================
class ExpandableStatCard extends StatefulWidget {
  final ImpactStatModel stat;
  final bool isGreen;
  final bool isMobile;
  final String additionalInfo;

  const ExpandableStatCard({
    super.key,
    required this.stat,
    required this.isGreen,
    this.isMobile = false,
    required this.additionalInfo,
  });

  @override
  State<ExpandableStatCard> createState() => _ExpandableStatCardState();
}

class _ExpandableStatCardState extends State<ExpandableStatCard> {
  bool _isHovered = false;
  double _cardHeight = 180.0;
  final double _expandedHeight = 320.0; // Increased for more text
  final double _collapsedHeight = 180.0;

  @override
  Widget build(BuildContext context) {
    // Combine "2" and "weeks" into one line if applicable
    String displayValue = widget.stat.value;
    if (widget.stat.label.toLowerCase().contains('week')) {
      displayValue = '${widget.stat.value} weeks';
    }

    return MouseRegion(
      onEnter: (_) {
        setState(() {
          _isHovered = true;
          _cardHeight = _expandedHeight;
        });
      },
      onExit: (_) {
        setState(() {
          _isHovered = false;
          _cardHeight = _collapsedHeight;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
        height: _cardHeight,
        width: double.infinity,
        padding: EdgeInsets.all(widget.isMobile ? 12.0 : 16.0),
        decoration: BoxDecoration(
          color: _isHovered 
            ? (widget.isGreen 
                ? const Color.fromARGB(255, 85, 221, 137) 
                : const Color(0xFFF8F9FA))
            : (widget.isGreen 
                ? const Color.fromARGB(255, 74, 211, 126) 
                : Colors.white),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _isHovered 
              ? (widget.isGreen ? Colors.transparent : WebColors.greenLight)
              : (widget.isGreen ? Colors.transparent : const Color(0xFFE0E0E0)),
            width: _isHovered ? 2.5 : 1.5,
          ),
          boxShadow: _isHovered
            ? [
                BoxShadow(
                  color: const Color.fromARGB(51, 0, 0, 0),
                  blurRadius: 25,
                  offset: const Offset(0, 10),
                  spreadRadius: 3,
                ),
                BoxShadow(
                  color: widget.isGreen 
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
                BoxShadow(
                  color: const Color.fromARGB(13, 0, 0, 0),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                  spreadRadius: 0,
                ),
              ],
        ),
        child: Stack(
          children: [
            // Main content that scales with hover
            AnimatedOpacity(
              duration: const Duration(milliseconds: 300),
              opacity: _isHovered ? 0 : 1,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // COMBINED VALUE AND UNIT - REDUCED FONT SIZE
                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        children: _buildCombinedValueText(displayValue, widget.stat.label),
                      ),
                    ),
                    const SizedBox(height: 8),
                    
                    // Stat label without "weeks" if already combined
                    if (!widget.stat.label.toLowerCase().contains('week'))
                      Text(
                        widget.stat.label,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: widget.isMobile ? 10 : 12,
                          fontWeight: FontWeight.w500,
                          color: widget.isGreen ? Colors.white : const Color(0xFF666666),
                          shadows: widget.isGreen ? [
                            Shadow(
                              color: const Color.fromARGB(26, 0, 0, 0),
                              blurRadius: 1,
                              offset: const Offset(0, 1),
                            ),
                          ] : null,
                        ),
                      ),
                    
                    if (_isHovered) const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
            
            // Expanded content on hover
            AnimatedOpacity(
              duration: const Duration(milliseconds: 300),
              opacity: _isHovered ? 1 : 0,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Icon at the top
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: widget.isGreen 
                            ? const Color.fromARGB(51, 255, 255, 255)
                            : const Color.fromARGB(26, 118, 230, 207),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: widget.isGreen ? Colors.white : WebColors.greenLight,
                            width: 1.5,
                          ),
                        ),
                        child: Icon(
                          _getIconForIndex(widget.stat),
                          size: 20,
                          color: widget.isGreen ? Colors.white : WebColors.greenLight,
                        ),
                      ),
                      const SizedBox(height: 12),
                      
                      // Combined stat value on hover - REDUCED FONT SIZE
                      RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          children: _buildCombinedValueTextHover(displayValue, widget.stat.label),
                        ),
                      ),
                      const SizedBox(height: 6),
                      
                      // Stat label without "weeks" if already combined
                      if (!widget.stat.label.toLowerCase().contains('week'))
                        Text(
                          widget.stat.label,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: widget.isMobile ? 12 : 14,
                            fontWeight: FontWeight.w600,
                            color: widget.isGreen ? Colors.white : WebColors.textTitle,
                          ),
                        ),
                      const SizedBox(height: 12),
                      
                      // Research-based additional info
                      AnimatedSize(
                        duration: const Duration(milliseconds: 400),
                        child: SizedBox(
                          height: _isHovered ? null : 0,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4.0),
                            child: Text(
                              widget.additionalInfo,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: widget.isMobile ? 9 : 10, // Smaller for more text
                                fontWeight: FontWeight.normal,
                                color: widget.isGreen 
                                  ? const Color(0xFFE6E6E6)
                                  : const Color(0xFF666666),
                                height: 1.4,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<TextSpan> _buildCombinedValueText(String value, String label) {
    if (label.toLowerCase().contains('week')) {
      final parts = label.split(' ');
      final unit = parts.last;
      final mainLabel = parts.sublist(0, parts.length - 1).join(' ');
      
      return [
        TextSpan(
          text: '$value\n',
          style: TextStyle(
            fontSize: widget.isMobile ? 24 : 30,
            fontWeight: FontWeight.w800,
            color: widget.isGreen ? Colors.white : WebColors.textTitle,
            shadows: widget.isGreen ? [
              Shadow(
                color: const Color.fromARGB(38, 0, 0, 0),
                blurRadius: 2,
                offset: const Offset(0, 1),
              ),
            ] : null,
          ),
        ),
        TextSpan(
          text: unit,
          style: TextStyle(
            fontSize: widget.isMobile ? 16 : 20,
            fontWeight: FontWeight.w600,
            color: widget.isGreen ? Colors.white : WebColors.textTitle,
            shadows: widget.isGreen ? [
              Shadow(
                color: const Color.fromARGB(26, 0, 0, 0),
                blurRadius: 1,
                offset: const Offset(0, 1),
              ),
            ] : null,
          ),
        ),
        if (mainLabel.isNotEmpty)
          TextSpan(
            text: '\n$mainLabel',
            style: TextStyle(
              fontSize: widget.isMobile ? 10 : 12,
              fontWeight: FontWeight.w500,
              color: widget.isGreen ? Colors.white : const Color(0xFF666666),
            ),
          ),
      ];
    } else {
      return [
        TextSpan(
          text: value,
          style: TextStyle(
            fontSize: widget.isMobile ? 24 : 30,
            fontWeight: FontWeight.w800,
            color: widget.isGreen ? Colors.white : WebColors.textTitle,
            shadows: widget.isGreen ? [
              Shadow(
                color: const Color.fromARGB(38, 0, 0, 0),
                blurRadius: 2,
                offset: const Offset(0, 1),
              ),
            ] : null,
          ),
        ),
      ];
    }
  }

  List<TextSpan> _buildCombinedValueTextHover(String value, String label) {
    if (label.toLowerCase().contains('week')) {
      final parts = label.split(' ');
      final unit = parts.last;
      final mainLabel = parts.sublist(0, parts.length - 1).join(' ');
      
      return [
        TextSpan(
          text: value,
          style: TextStyle(
            fontSize: widget.isMobile ? 28 : 34,
            fontWeight: FontWeight.w800,
            color: widget.isGreen ? Colors.white : WebColors.textTitle,
            shadows: widget.isGreen ? [
              Shadow(
                color: const Color.fromARGB(51, 0, 0, 0),
                blurRadius: 3,
                offset: const Offset(0, 1),
              ),
            ] : null,
          ),
        ),
        TextSpan(
          text: ' $unit',
          style: TextStyle(
            fontSize: widget.isMobile ? 18 : 22,
            fontWeight: FontWeight.w600,
            color: widget.isGreen ? Colors.white : WebColors.textTitle,
            shadows: widget.isGreen ? [
              Shadow(
                color: const Color.fromARGB(38, 0, 0, 0),
                blurRadius: 2,
                offset: const Offset(0, 1),
              ),
            ] : null,
          ),
        ),
        if (mainLabel.isNotEmpty)
          TextSpan(
            text: '\n$mainLabel',
            style: TextStyle(
              fontSize: widget.isMobile ? 12 : 14,
              fontWeight: FontWeight.w600,
              color: widget.isGreen ? Colors.white : WebColors.textTitle,
            ),
          ),
      ];
    } else {
      return [
        TextSpan(
          text: value,
          style: TextStyle(
            fontSize: widget.isMobile ? 28 : 34,
            fontWeight: FontWeight.w800,
            color: widget.isGreen ? Colors.white : WebColors.textTitle,
            shadows: widget.isGreen ? [
              Shadow(
                color: const Color.fromARGB(51, 0, 0, 0),
                blurRadius: 3,
                offset: const Offset(0, 1),
              ),
            ] : null,
          ),
        ),
      ];
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
        fontSize: 11, // Smaller for more content
        color: const Color(0xFF444444),
        height: 1.5,
      ),
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
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
                  BoxShadow(
                    color: const Color.fromARGB(38, 0, 0, 0),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                    spreadRadius: 0.5,
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
                width: _isHovered ? 30 : 28,
                height: _isHovered ? 30 : 28,
                decoration: BoxDecoration(
                  color: _isHovered
                    ? WebColors.greenLight
                    : const Color.fromARGB(66, 40, 168, 90),
                  borderRadius: BorderRadius.circular(_isHovered ? 8 : 6),
                  boxShadow: _isHovered
                    ? [
                        BoxShadow(
                          color: const Color.fromARGB(102, 118, 230, 207),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ]
                    : [
                        BoxShadow(
                          color: const Color.fromARGB(26, 40, 168, 90),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                ),
                child: Icon(
                  widget.icon,
                  size: _isHovered ? 16 : 15,
                  color: _isHovered 
                    ? Colors.white 
                    : const Color(0xFF28A85A),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 300),
                style: TextStyle(
                  fontSize: _isHovered ? 14 : 13,
                  fontWeight: _isHovered ? FontWeight.w600 : FontWeight.w500,
                  color: _isHovered 
                    ? WebColors.textTitle
                    : const Color(0xFF444444),
                ),
                child: Text(widget.text),
              ),
              if (_isHovered)
                Padding(
                  padding: const EdgeInsets.only(left: 6.0),
                  child: Icon(
                    Icons.arrow_forward_ios,
                    size: 12,
                    color: WebColors.greenLight,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}