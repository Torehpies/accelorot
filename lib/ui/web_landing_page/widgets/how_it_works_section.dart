// lib/ui/landing_page/widgets/how_it_works_section.dart

import 'package:flutter/material.dart';
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
    
    final isMobile = screenWidth < 768;
    final isTablet = screenWidth >= 768 && screenWidth < 1024;
    final isSmallMobile = screenWidth < 400;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        vertical: isMobile ? 40.0 : 60.0,
        horizontal: isMobile 
            ? (isSmallMobile ? 16.0 : 20.0)
            : isTablet
              ? 32.0
              : 48.0,
      ),
      color: const Color.fromARGB(255, 34, 197, 94).withValues(alpha: 0.8), // FIXED: comma instead of semicolon, proper opacity method
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: 1200,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Title - Minimized
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: WebTextStyles.h2.copyWith(
                    fontSize: isSmallMobile ? 24 
                        : isMobile ? 28 
                        : isTablet ? 32 
                        : 36,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    height: 1.2,
                  ),
                  children: [
                    const TextSpan(text: 'How '),
                    TextSpan(
                      text: 'Accel-O-Rot',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const TextSpan(text: ' Works'),
                  ],
                ),
              ),

              SizedBox(height: isMobile ? 16.0 : 24.0),

              // Subtitle - Minimized
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 16.0 : 0,
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
                      fontSize: isSmallMobile ? 14 
                          : isMobile ? 15 
                          : isTablet ? 16 
                          : 17,
                      color: Colors.white,
                      height: 1.5,
                    ),
                  ),
                ),
              ),

              SizedBox(height: isMobile ? 32.0 : 48.0),

              // Responsive layout for steps - Minimized
              if (isSmallMobile)
                Column(
                  children: steps.map((step) {
                    return Padding(
                      padding: EdgeInsets.only(bottom: 16.0),
                      child: StepCard(
                        step: step,
                        isMobile: true,
                        isSmallMobile: true,
                      ),
                    );
                  }).toList(),
                )
              else if (isMobile)
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16.0,
                    mainAxisSpacing: 16.0,
                    childAspectRatio: 0.85,
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
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: steps.asMap().entries.map((entry) {
                    final index = entry.key;
                    final step = entry.value;
                    return Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(
                          right: index == steps.length - 1 ? 0 : 16.0,
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
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: steps.asMap().entries.map((entry) {
                    final index = entry.key;
                    final step = entry.value;
                    return Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(
                          right: index == steps.length - 1 ? 0 : 24.0,
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

// STEP CARD - MINIMIZED VERSION
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
        duration: const Duration(milliseconds: 200),
        constraints: BoxConstraints(
          minHeight: widget.isMobile
              ? (widget.isSmallMobile ? 160 : 180)
              : widget.isTablet
                  ? 200
                  : 220,
        ),
        padding: EdgeInsets.all(
          widget.isSmallMobile
              ? 16.0
              : widget.isMobile
                  ? 20.0
                  : widget.isTablet
                      ? 20.0
                      : 24.0,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(
            widget.isSmallMobile
                ? 12.0
                : widget.isMobile
                    ? 14.0
                    : widget.isTablet
                        ? 16.0
                        : 16.0,
          ),
          border: Border.all(
            color: _hovered && !widget.isMobile
                ? WebColors.greenAccent
                : const Color(0xFFF6F8FA),
            width: _hovered && !widget.isMobile ? 2.0 : 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color.fromARGB(26, 0, 0, 0),
              blurRadius: widget.isMobile ? 8 : 12,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Step number - Minimized
            Positioned(
              top: 8,
              right: 8,
              child: Text(
                widget.step.number.toString().padLeft(2, '0'),
                style: TextStyle(
                  fontSize: widget.isSmallMobile
                      ? 24.0
                      : widget.isMobile
                          ? 28.0
                          : widget.isTablet
                              ? 30.0
                              : 32.0,
                  fontWeight: FontWeight.w700,
                  color: const Color.fromARGB(255, 34, 197, 94).withValues(alpha: 0.8),
                ),
              ),
            ),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon box - Minimized
                Container(
                  width: widget.isSmallMobile
                      ? 40.0
                      : widget.isMobile
                          ? 44.0
                          : widget.isTablet
                              ? 46.0
                              : 48.0,
                  height: widget.isSmallMobile
                      ? 40.0
                      : widget.isMobile
                          ? 44.0
                          : widget.isTablet
                              ? 46.0
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
                                : 24.0,
                  ),
                ),

                SizedBox(
                  height: widget.isSmallMobile
                      ? 12.0
                      : widget.isMobile
                          ? 16.0
                          : widget.isTablet
                              ? 16.0
                              : 16.0,
                ),

                // Title - Minimized
                Text(
                  widget.step.title,
                  style: TextStyle(
                    fontSize: widget.isSmallMobile
                        ? 16.0
                        : widget.isMobile
                            ? 17.0
                            : widget.isTablet
                                ? 18.0
                                : 19.0,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF2B2B2B),
                    height: 1.3,
                  ),
                ),

                SizedBox(
                  height: widget.isSmallMobile
                      ? 8.0
                      : widget.isMobile
                          ? 8.0
                          : widget.isTablet
                              ? 8.0
                              : 12.0,
                ),

                // Description - Minimized
                Text(
                  widget.step.description,
                  style: TextStyle(
                    fontSize: widget.isSmallMobile
                        ? 13.0
                        : widget.isMobile
                            ? 13.5
                            : widget.isTablet
                                ? 14.0
                                : 14.5,
                    height: 1.5,
                    color: const Color(0xFF6B7280),
                  ),
                  maxLines: widget.isMobile ? 3 : 4,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIcon(int stepNumber) {
    switch (stepNumber) {
      case 1:
        return Icons.recycling_outlined;
      case 2:
        return Icons.sensors_outlined;
      case 3:
        return Icons.psychology_outlined;
      case 4:
        return Icons.agriculture_outlined;
      default:
        return Icons.auto_awesome_outlined;
    }
  }
}