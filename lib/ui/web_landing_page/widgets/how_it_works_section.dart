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
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.xxxl,
        horizontal: AppSpacing.xxxl,
      ),
      color: const Color( 0xFFE0F2FE),
      child: Column(
        children: [

          // Title
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: WebTextStyles.h2.copyWith(
                fontSize: 38,
                fontWeight: FontWeight.w800,
                color: WebColors.textTitle,
              ),
              children: [
                const TextSpan(text: 'How '),
                TextSpan(
                  text: 'Accel-O-Rot',
                  style: TextStyle(
                    color: WebColors.greenAccent,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const TextSpan(text: ' Works'),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.lg),

          // Subtitle
          SizedBox(
            width: 720,
            child: Text(
              'Our smart composting system transforms your organic waste into garden-ready compost with minimal effort. Just add waste and let technology handle the rest.',
              textAlign: TextAlign.center,
              style: WebTextStyles.subtitle.copyWith(
                fontSize: 16,
                color: const Color(0xFF555555),
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.xxxl),

          // Steps row
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(steps.length, (index) {
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      right: index == steps.length - 1
                          ? 0
                          : AppSpacing.xl,
                    ),
                    child: StepCard(step: steps[index]),
                  ),
                );
              }),
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

  const StepCard({
    super.key,
    required this.step,
  });

  @override
  State<StepCard> createState() => _StepCardState();
}

class _StepCardState extends State<StepCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        height: 220,
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: _hovered
                ? WebColors.greenAccent
                : const Color.fromARGB(255, 246, 248, 250),
            width: _hovered ? 2 : 1.5,
          ),
        ),
        child: Stack(
          children: [
            // Step number
            Positioned(
              top: 0,
              right: 0,
              child: Text(
                widget.step.number.toString().padLeft(2, '0'),
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  color: Color.fromARGB(255, 212, 212, 212),
                ),
              ),
            ),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon box
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5FDFA),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFFE8F5EF),
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    _getIcon(widget.step.number),
                    color: WebColors.greenAccent,
                    size: 24,
                  ),
                ),

                const SizedBox(height: AppSpacing.md),

                // Title
                Text(
                  widget.step.title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: WebColors.textTitle,
                  ),
                ),

                const SizedBox(height: AppSpacing.xs),

                // Description
                Expanded(
                  child: Text(
                    widget.step.description,
                    style: const TextStyle(
                      fontSize: 13,
                      height: 1.5,
                      color: Color(0xFF6B7280),
                    ),
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                  ),
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