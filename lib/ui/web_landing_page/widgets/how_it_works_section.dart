// lib/ui/landing_page/widgets/how_it_works_section.dart

import 'package:flutter/material.dart';
import '../../core/constants/spacing.dart';
import '../../core/themes/web_text_styles.dart';
import '../../core/themes/web_colors.dart';
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
    
    // More granular breakpoints for better responsiveness
    final isMobile = screenWidth < 768;
    final isTablet = screenWidth >= 768 && screenWidth < 1024;
    final isSmallMobile = screenWidth < 400;
    final isLargeDesktop = screenWidth >= 1440;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        vertical: isMobile 
            ? AppSpacing.xl 
            : isTablet 
              ? AppSpacing.xxl 
              : AppSpacing.xxxl * 1.5,
        horizontal: isMobile 
            ? (isSmallMobile ? AppSpacing.md : AppSpacing.lg)
            : isTablet
              ? AppSpacing.xl
              : AppSpacing.xxxl,
      ),
      color: const Color.fromARGB(255, 34, 197, 94).withValues(alpha: 0.8), // FIXED: comma instead of semicolon, proper opacity method
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: isLargeDesktop ? 1400 : 1200, // Larger max width for large screens
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Title
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: WebTextStyles.h2.copyWith(
                    fontSize: isSmallMobile ? 22 
                        : isMobile ? 26 
                        : isTablet ? 32 
                        : 38,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    height: 1.2,
                  ),
                  children: [
                    const TextSpan(text: 'How '),
                    TextSpan(
                      text: 'Accel-O-Rot',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const TextSpan(text: ' Works'),
                  ],
                ),
              ),

              SizedBox(height: isMobile ? AppSpacing.md : AppSpacing.lg),

              // Subtitle - removed opacity for better contrast
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? AppSpacing.sm : 0,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: isMobile 
                        ? double.infinity 
                        : isTablet 
                          ? 800 
                          : 720,
                  ),
                  child: Text(
                    'Our smart composting system transforms your organic waste into garden-ready compost with minimal effort. Just add waste and let technology handle the rest.',
                    textAlign: TextAlign.center,
                    style: WebTextStyles.subtitle.copyWith(
                      fontSize: isSmallMobile ? 13 
                          : isMobile ? 14 
                          : isTablet ? 15 
                          : 16,
                      color: Colors.white, // Removed opacity
                      height: 1.5,
                    ),
                  ),
                ),
              ),

              SizedBox(height: isMobile ? AppSpacing.xl : AppSpacing.xxxl),

              // Responsive layout for steps
              if (isSmallMobile)
                // Single column for very small screens
                Column(
                  children: steps.map((step) {
                    return Padding(
                      padding: EdgeInsets.only(bottom: AppSpacing.md),
                      child: StepCard(
                        step: step,
                        isMobile: true,
                        isSmallMobile: true,
                      ),
                    );
                  }).toList(),
                )
              else if (isMobile)
                // 2 columns for mobile (except small mobile)
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: AppSpacing.md,
                    mainAxisSpacing: AppSpacing.md,
                    childAspectRatio: 0.85, // Adjusted for better mobile layout
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
                // Tablet: 4 cards in a row with less spacing
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: steps.asMap().entries.map((entry) {
                    final index = entry.key;
                    final step = entry.value;
                    return Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(
                          right: index == steps.length - 1 ? 0 : AppSpacing.md,
                        ),
                        child: StepCard(
                          step: step,
                          isMobile: false,
                          isSmallMobile: false,
                          isTablet: true,
                        ),
                      ),
                    );
                  }).toList(),
                )
              else
                // Desktop: 4 cards with proper spacing
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: steps.asMap().entries.map((entry) {
                    final index = entry.key;
                    final step = entry.value;
                    return Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(
                          right: index == steps.length - 1 ? 0 : AppSpacing.lg,
                        ),
                        child: StepCard(
                          step: step,
                          isMobile: false,
                          isSmallMobile: false,
                        ),
                      ),
                    );
                  }).toList(),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// STEP CARD
class StepCard extends StatefulWidget {
  final StepModel step;
  final bool isMobile;
  final bool isSmallMobile;
  final bool isTablet;

  const StepCard({
    super.key,
    required this.step,
    required this.isMobile,
    this.isSmallMobile = false,
    this.isTablet = false,
  });

  @override
  State<StepCard> createState() => _StepCardState();
}

class _StepCardState extends State<StepCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeDesktop = screenWidth >= 1440;

    return MouseRegion(
      onEnter: (_) {
        if (!widget.isMobile) {
          setState(() => _hovered = true);
        }
      },
      onExit: (_) {
        if (!widget.isMobile) {
          setState(() => _hovered = false);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        constraints: BoxConstraints(
          minHeight: widget.isMobile
              ? (widget.isSmallMobile ? 140 : 160)
              : widget.isTablet
                  ? 180
                  : isLargeDesktop
                      ? 220
                      : 200,
        ),
        padding: EdgeInsets.all(
          widget.isSmallMobile
              ? AppSpacing.md
              : widget.isMobile
                  ? AppSpacing.lg
                  : widget.isTablet
                      ? AppSpacing.md
                      : isLargeDesktop
                          ? AppSpacing.xl
                          : AppSpacing.lg,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(
            widget.isSmallMobile
                ? 10.0
                : widget.isMobile
                    ? 12.0
                    : widget.isTablet
                        ? 14.0
                        : 16.0,
          ),
          border: Border.all(
            color: _hovered && !widget.isMobile
                ? WebColors.greenAccent
                : const Color(0xFFF6F8FA), // Using hex color directly
            width: _hovered && !widget.isMobile ? 2.0 : 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0x0A000000),
              blurRadius: widget.isMobile ? 8 : 12,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Step number
            Positioned(
              top: 0,
              right: 0,
              child: Text(
                widget.step.number.toString().padLeft(2, '0'),
                style: TextStyle(
                  fontSize: widget.isSmallMobile
                      ? 28.0
                      : widget.isMobile
                          ? 32.0
                          : widget.isTablet
                              ? 34.0
                              : isLargeDesktop
                                  ? 40.0
                                  : 36.0,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFFF0F0F0),
                ),
              ),
            ),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon box
                Container(
                  width: widget.isSmallMobile
                      ? 40.0
                      : widget.isMobile
                          ? 44.0
                          : widget.isTablet
                              ? 46.0
                              : isLargeDesktop
                                  ? 52.0
                                  : 48.0,
                  height: widget.isSmallMobile
                      ? 40.0
                      : widget.isMobile
                          ? 44.0
                          : widget.isTablet
                              ? 46.0
                              : isLargeDesktop
                                  ? 52.0
                                  : 48.0,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5FDFA),
                    borderRadius: BorderRadius.circular(
                      widget.isSmallMobile
                          ? 8.0
                          : widget.isMobile
                              ? 10.0
                              : widget.isTablet
                                  ? 11.0
                                  : 12.0,
                    ),
                    border: Border.all(
                      color: const Color(0xFFE8F5EF),
                      width: 1.0,
                    ),
                  ),
                  child: Icon(
                    _getIcon(widget.step.number),
                    color: WebColors.greenAccent,
                    size: widget.isSmallMobile
                        ? 20.0
                        : widget.isMobile
                            ? 22.0
                            : widget.isTablet
                                ? 23.0
                                : isLargeDesktop
                                    ? 26.0
                                    : 24.0,
                  ),
                ),

                SizedBox(
                  height: widget.isSmallMobile
                      ? AppSpacing.sm
                      : widget.isMobile
                          ? AppSpacing.sm
                          : widget.isTablet
                              ? AppSpacing.md
                              : AppSpacing.md,
                ),

                // Title
                Text(
                  widget.step.title,
                  style: TextStyle(
                    fontSize: widget.isSmallMobile
                        ? 14.0
                        : widget.isMobile
                            ? 15.0
                            : widget.isTablet
                                ? 16.0
                                : isLargeDesktop
                                    ? 18.0
                                    : 17.0,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF2B2B2B),
                    height: 1.3,
                  ),
                ),

                SizedBox(
                  height: widget.isSmallMobile
                      ? AppSpacing.xs
                      : widget.isMobile
                          ? AppSpacing.xs
                          : widget.isTablet
                              ? AppSpacing.sm
                              : AppSpacing.sm,
                ),

                // Description
                Text(
                  widget.step.description,
                  style: TextStyle(
                    fontSize: widget.isSmallMobile
                        ? 12.0
                        : widget.isMobile
                            ? 12.5
                            : widget.isTablet
                                ? 13.0
                                : isLargeDesktop
                                    ? 14.0
                                    : 13.5,
                    height: 1.5,
                    color: const Color(0xFF6B7280),
                  ),
                  maxLines: widget.isMobile ? null : 4,
                  overflow:
                      widget.isMobile ? null : TextOverflow.ellipsis,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Simple icon selector
  IconData _getIcon(int stepNumber) {
    switch (stepNumber) {
      case 1:
        return Icons.recycling;
      case 2:
        return Icons.monitor_heart_outlined;
      case 3:
        return Icons.settings_outlined;
      case 4:
        return Icons.eco_outlined;
      default:
        return Icons.circle;
    }
  }
}