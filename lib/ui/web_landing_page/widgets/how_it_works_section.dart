// lib/ui/landing_page/widgets/how_it_works_section.dart

import 'package:flutter/material.dart';
import '../../core/themes/web_text_styles.dart';
import '../models/step_model.dart';

class HowItWorksSection extends StatelessWidget {
  final List<StepModel> steps;

  const HowItWorksSection({
    super.key,
    required this.steps,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    final isMobile = screenWidth < 768;
    final isTablet = screenWidth >= 768 && screenWidth < 1024;
    final isSmallMobile = screenWidth < 400;
    final isLargeTablet = screenWidth >= 900 && screenWidth < 1024;

    // Define accent color - Using 0xFF28A85A
    const accentColor = Color(0xFF28A85A); // Your specified green color as ACCENT

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        vertical: isMobile ? 32.0 : 60.0, // Reduced mobile padding
        horizontal: isMobile 
            ? (isSmallMobile ? 12.0 : 16.0) // Reduced horizontal padding
            : isTablet
              ? 32.0
              : 48.0,
      ),
      // SOFT GREEN BACKGROUND WITH ACCENT COLOR FOR ACCENTS ONLY
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            accentColor.withValues(alpha: 0.05), // Very subtle green tint
            accentColor.withValues(alpha: 0.08), // Slightly more green
            accentColor.withValues(alpha: 0.12), // Subtle green
          ],
          stops: [0.0, 0.5, 1.0],
        ),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: 1200,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Title - With accent color only for the brand name
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: WebTextStyles.h2.copyWith(
                    fontSize: isSmallMobile ? 20  // Reduced for small mobile
                        : isMobile ? 24           // Reduced for mobile
                        : isTablet ? 32 
                        : 36,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF111827), // Dark gray for most text
                    height: 1.2,
                  ),
                  children: [
                    const TextSpan(text: 'How '),
                    TextSpan(
                      text: 'Accel-O-Rot',
                      style: TextStyle(
                        color: accentColor, // ACCENT COLOR for brand name only
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const TextSpan(text: ' Works'),
                  ],
                ),
              ),

              SizedBox(height: isMobile ? 12.0 : 24.0), // Reduced spacing for mobile

              // Subtitle - Neutral color with slight green tint
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 12.0 : 0, // Reduced padding for mobile
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: isMobile 
                        ? double.infinity 
                        : isTablet 
                          ? 700 
                          : 600,
                  ),
                  child: Text(
                    'Our smart composting system transforms your organic waste into garden-ready compost with minimal effort. Just add waste and let technology handle the rest.',
                    textAlign: TextAlign.center,
                    style: WebTextStyles.subtitle.copyWith(
                      fontSize: isSmallMobile ? 12  // Reduced for small mobile
                          : isMobile ? 13           // Reduced for mobile
                          : isTablet ? 16 
                          : 17,
                      color: Color(0xFF374151), // Dark gray with subtle green feel
                      height: 1.4, // Tighter line height for mobile
                    ),
                  ),
                ),
              ),

              SizedBox(height: isMobile ? 24.0 : 48.0), // Reduced spacing for mobile

              // RESPONSIVE LAYOUT - Tablet and Mobile optimized
              if (isSmallMobile)
                // Very small mobile: Single column with full description
                Column(
                  children: steps.map((step) {
                    return Padding(
                      padding: EdgeInsets.only(bottom: 12.0), // Reduced padding
                      child: StepCard(
                        step: step,
                        isMobile: true,
                        isSmallMobile: true,
                      ),
                    );
                  }).toList(),
                )
              else if (isMobile)
                // Mobile: 2 columns with better text display
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12.0, // Reduced spacing
                    mainAxisSpacing: 12.0, // Reduced spacing
                    childAspectRatio: 1.3, // Taller for more text space
                  ),
                  itemCount: steps.length,
                  itemBuilder: (context, index) {
                    return StepCard(
                      step: steps[index],
                      isMobile: true,
                      isSmallMobile: false,
                    );
                  },
                )
              else if (isTablet)
                // Tablet: Adjust layout for better readability
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: isLargeTablet ? 4 : 2,
                    crossAxisSpacing: isLargeTablet ? 16.0 : 20.0,
                    mainAxisSpacing: isLargeTablet ? 16.0 : 20.0,
                    childAspectRatio: isLargeTablet ? 1.0 : 1.3, // Taller for 2-column
                  ),
                  itemCount: steps.length,
                  itemBuilder: (context, index) {
                    return StepCard(
                      step: steps[index],
                      isMobile: false,
                      isSmallMobile: false,
                      isTablet: true,
                      isLargeTablet: isLargeTablet,
                    );
                  },
                )
              else
                // Desktop: UNIFORM HEIGHT AND WIDTH - Use GridView for perfect squares
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: steps.length, // 4 cards in a row
                    crossAxisSpacing: 24.0,
                    mainAxisSpacing: 24.0,
                    childAspectRatio: 1.0, // Perfect square cards for uniform height & width
                  ),
                  itemCount: steps.length,
                  itemBuilder: (context, index) {
                    return StepCard(
                      step: steps[index],
                      isMobile: false,
                      isSmallMobile: false,
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// STEP CARD - Using accent color only for accents
class StepCard extends StatefulWidget {
  final StepModel step;
  final bool isMobile;
  final bool isSmallMobile;
  final bool isTablet;
  final bool isLargeTablet;

  const StepCard({
    super.key,
    required this.step,
    required this.isMobile,
    this.isSmallMobile = false,
    this.isTablet = false,
    this.isLargeTablet = false,
  });

  @override
  State<StepCard> createState() => _StepCardState();
}

class _StepCardState extends State<StepCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    // Define accent color - Using 0xFF28A85A
    const accentColor = Color(0xFF28A85A); // Your specified green color as ACCENT
    
    // Desktop view - UNIFORM SQUARE CARDS
    if (!widget.isMobile && !widget.isTablet) {
      return MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18.0),
            border: Border.all(
              color: _hovered ? accentColor : Color(0xFFD1FAE5), // Light green border, accent on hover
              width: _hovered ? 2.0 : 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: accentColor.withValues(alpha: 0.1), // Subtle green shadow
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top row with icon and step number
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Icon box - Using accent color
                    Container(
                      width: 52.0,
                      height: 52.0,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            accentColor.withValues(alpha: 0.1),
                            accentColor.withValues(alpha: 0.05),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12.0),
                        border: Border.all(
                          color: accentColor.withValues(alpha: 0.3), // Subtle accent border
                          width: 1.0,
                        ),
                      ),
                      child: Icon(
                        _getIcon(widget.step.number, widget.step.title),
                        color: accentColor, // ACCENT COLOR for icon
                        size: 26.0,
                      ),
                    ),
                    
                    // Step number - Using accent color
                    Text(
                      widget.step.number.toString().padLeft(2, '0'),
                      style: TextStyle(
                        fontSize: 32.0,
                        fontWeight: FontWeight.w700,
                        color: accentColor, // ACCENT COLOR for step number
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20.0),

                // Title - Neutral dark color with slight green tint
                Text(
                  widget.step.title,
                  style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF064E3B), // Dark green-gray
                    height: 1.2,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 12.0),

                // Description - Neutral medium gray with green tint
                Expanded(
                  child: SingleChildScrollView(
                    physics: const NeverScrollableScrollPhysics(),
                    child: Text(
                      widget.step.description,
                      style: TextStyle(
                        fontSize: 15.0,
                        height: 1.5,
                        color: Color(0xFF374151), // Medium gray with green undertone
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

    // Tablet and Mobile view - MINIMIZED FONT SIZES
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(
          widget.isSmallMobile ? 10.0 : // Smaller radius for mobile
          widget.isMobile ? 12.0 :
          16.0,
        ),
        border: Border.all(
          color: Color(0xFFD1FAE5), // Light green border
          width: 1.0, // Thinner border for mobile
        ),
        boxShadow: [
          BoxShadow(
            color: accentColor.withValues(alpha: 0.06), // Even more subtle shadow for mobile
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(
          widget.isSmallMobile ? 12.0 : // Reduced padding for mobile
          widget.isMobile ? 14.0 :
          widget.isLargeTablet ? 18.0 : 20.0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row with icon and step number
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon box - Using accent color as accent
                Container(
                  width: widget.isSmallMobile ? 32.0 : // Smaller for mobile
                         widget.isMobile ? 36.0 :
                         widget.isLargeTablet ? 44.0 : 48.0,
                  height: widget.isSmallMobile ? 32.0 : // Smaller for mobile
                         widget.isMobile ? 36.0 :
                         widget.isLargeTablet ? 44.0 : 48.0,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        accentColor.withValues(alpha: 0.1),
                        accentColor.withValues(alpha: 0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(
                      widget.isSmallMobile ? 6.0 : // Smaller radius
                      widget.isMobile ? 8.0 :
                      12.0,
                    ),
                    border: Border.all(
                      color: accentColor.withValues(alpha: 0.2), // Even more subtle border for mobile
                      width: 0.8, // Thinner border
                    ),
                  ),
                  child: Icon(
                    _getIcon(widget.step.number, widget.step.title),
                    color: accentColor, // ACCENT COLOR for icon
                    size: widget.isSmallMobile ? 16.0 : // Smaller icon for mobile
                          widget.isMobile ? 18.0 :
                          widget.isLargeTablet ? 22.0 : 24.0,
                  ),
                ),
                
                // Step number - MINIMIZED for mobile
                Text(
                  widget.step.number.toString().padLeft(2, '0'),
                  style: TextStyle(
                    fontSize: widget.isSmallMobile ? 20.0 : // Smaller for mobile
                             widget.isMobile ? 22.0 :
                             widget.isLargeTablet ? 28.0 : 30.0,
                    fontWeight: FontWeight.w700,
                    color: accentColor, // ACCENT COLOR for step number
                  ),
                ),
              ],
            ),

            SizedBox(
              height: widget.isSmallMobile ? 8.0 : // Reduced spacing
                     widget.isMobile ? 10.0 :
                     18.0,
            ),

            // Title - MINIMIZED for mobile
            Text(
              widget.step.title,
              style: TextStyle(
                fontSize: widget.isSmallMobile ? 14.0 : // Smaller for mobile
                         widget.isMobile ? 15.0 :
                         widget.isLargeTablet ? 17.0 : 18.0,
                fontWeight: FontWeight.w700,
                color: Color(0xFF064E3B), // Dark green-gray
                height: 1.2,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            SizedBox(
              height: widget.isSmallMobile ? 4.0 : // Reduced spacing
                     widget.isMobile ? 6.0 :
                     12.0,
            ),

            // Description - MINIMIZED for mobile
            Expanded(
              child: SingleChildScrollView(
                physics: const NeverScrollableScrollPhysics(),
                child: Text(
                  widget.step.description,
                  style: TextStyle(
                    fontSize: widget.isSmallMobile ? 11.5 : // Much smaller for mobile
                             widget.isMobile ? 12.0 : // Smaller for mobile
                             widget.isLargeTablet ? 14.0 : 14.5,
                    height: 1.4, // Tighter line height for mobile
                    color: Color(0xFF374151), // Medium gray with green undertone
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIcon(int stepNumber, String title) {
    // Check for "Harvest" in the title to use soil/fertilizer icon
    final isHarvestStep = title.toLowerCase().contains('harvest') || stepNumber == 4;
    
    if (isHarvestStep) {
      // Soil/fertilizer icon for harvest/patabang lupa
      return Icons.grass; // Grass/plant icon for fertile soil
    }
    
    switch (stepNumber) {
      case 1:
        return Icons.recycling_outlined; // Recycling for waste
      case 2:
        return Icons.sensors_outlined; // Sensors for monitoring
      case 3:
        return Icons.psychology_outlined; // Psychology/brain for AI
      default:
        return Icons.auto_awesome_outlined;
    }
  }
}