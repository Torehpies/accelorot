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
    final isMobile = screenWidth < 800;
    final isSmallMobile = screenWidth < 400;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        vertical: isMobile ? AppSpacing.xl : AppSpacing.xxxl * 1.5,
        horizontal: isMobile 
            ? (isSmallMobile ? AppSpacing.md : AppSpacing.lg)
            : AppSpacing.xxxl,
      ),
      color:  const Color.fromARGB(255, 74, 209, 126), // Changed to #00a400 green background
      child: Column(
        children: [
          // Title - changed text color to white for contrast on green background
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: WebTextStyles.h2.copyWith(
                fontSize: isSmallMobile ? 22 : (isMobile ? 26 : 38),
                fontWeight: FontWeight.w800,
                color: Colors.white, // Changed from WebColors.textTitle to white
                height: 1.2,
              ),
              children: [
                const TextSpan(text: 'How '),
                TextSpan(
                  text: 'Accel-O-Rot',
                  style: TextStyle(
                    color: Colors.white, // Changed to white for consistency on green background
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const TextSpan(text: ' Works'),
              ],
            ),
          ),

          SizedBox(height: isMobile ? AppSpacing.md : AppSpacing.lg),

          // Subtitle - changed text color to light white for readability
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? AppSpacing.xs : 0,
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: isMobile ? double.infinity : 720,
              ),
              child: Text(
                'Our smart composting system transforms your organic waste into garden-ready compost with minimal effort. Just add waste and let technology handle the rest.',
                textAlign: TextAlign.center,
                style: WebTextStyles.subtitle.copyWith(
                  fontSize: isSmallMobile ? 13 : (isMobile ? 14 : 16),
                  color: Colors.white70, // Changed from dark gray to light white
                  height: 1.5,
                ),
              ),
            ),
          ),

          SizedBox(height: isMobile ? AppSpacing.xl : AppSpacing.xxxl),

          // Steps - 2 Column Grid for mobile, Row for desktop
          if (isMobile)
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: AppSpacing.md,
                mainAxisSpacing: AppSpacing.md,
                childAspectRatio: isSmallMobile ? 0.85 : 0.9,
              ),
              itemCount: steps.length,
              itemBuilder: (context, index) {
                return StepCard(step: steps[index], isMobile: true);
              },
            )
          else
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: steps.asMap().entries.map((entry) {
                  final index = entry.key;
                  final step = entry.value;
                  return Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                        right: index == steps.length - 1 ? 0 : AppSpacing.lg,
                      ),
                      child: StepCard(step: step, isMobile: false),
                    ),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }
}

// STEP CARD
class StepCard extends StatefulWidget {
  final StepModel step;
  final bool isMobile;

  const StepCard({
    super.key,
    required this.step,
    required this.isMobile,
  });

  @override
  State<StepCard> createState() => _StepCardState();
}

class _StepCardState extends State<StepCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallMobile = screenWidth < 400;

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
          minHeight: widget.isMobile ? 140 : 200,
        ),
        padding: EdgeInsets.all(
          widget.isMobile 
              ? (isSmallMobile ? AppSpacing.md : AppSpacing.lg)
              : AppSpacing.lg,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(widget.isMobile ? 12.0 : 16.0),
          border: Border.all(
            color: _hovered && !widget.isMobile
                ? WebColors.greenAccent
                : const Color.fromARGB(255, 246, 248, 250),
            width: _hovered && !widget.isMobile ? 2.0 : 1.5,
          ),
          boxShadow: widget.isMobile
              ? [
                  BoxShadow(
                    color: Color(0x0A000000),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ]
              : null,
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
                  fontSize: widget.isMobile 
                      ? (isSmallMobile ? 28.0 : 32.0)
                      : 36.0,
                  fontWeight: FontWeight.w700,
                  color: const Color.fromARGB(255, 220, 220, 220),
                ),
              ),
            ),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon box
                Container(
                  width: widget.isMobile ? 44.0 : 48.0,
                  height: widget.isMobile ? 44.0 : 48.0,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5FDFA),
                    borderRadius: BorderRadius.circular(widget.isMobile ? 10.0 : 12.0),
                    border: Border.all(
                      color: const Color(0xFFE8F5EF),
                      width: 1.0,
                    ),
                  ),
                  child: Icon(
                    _getIcon(widget.step.number),
                    color: WebColors.greenAccent,
                    size: widget.isMobile ? 22.0 : 24.0,
                  ),
                ),

                SizedBox(height: widget.isMobile ? AppSpacing.sm : AppSpacing.md),

                // Title
                Text(
                  widget.step.title,
                  style: TextStyle(
                    fontSize: widget.isMobile 
                        ? (isSmallMobile ? 15.0 : 16.0)
                        : 17.0,
                    fontWeight: FontWeight.w700,
                    color: const Color.fromARGB(255, 43, 43, 43),
                    height: 1.3,
                  ),
                ),

                SizedBox(height: widget.isMobile ? AppSpacing.xs : AppSpacing.sm),

                // Description
                Text(
                  widget.step.description,
                  style: TextStyle(
                    fontSize: widget.isMobile 
                        ? (isSmallMobile ? 12.5 : 13.0)
                        : 13.5,
                    height: 1.5,
                    color: const Color(0xFF6B7280),
                  ),
                  maxLines: widget.isMobile ? null : 4,
                  overflow: widget.isMobile ? null : TextOverflow.ellipsis,
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
        return Icons.recycling; // For "Add Materials"
      case 2:
        return Icons.monitor_heart_outlined; // For "Monitor Sensors"
      case 3:
        return Icons.settings_outlined; // For "Auto-Regulate"
      case 4:
        return Icons.eco_outlined; // For "Harvest Compost"
      default:
        return Icons.circle;
    }
  }
}