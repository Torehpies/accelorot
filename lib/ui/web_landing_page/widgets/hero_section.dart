// lib/ui/landing_page/widgets/hero_section.dart

import 'package:flutter/material.dart';
import '../../core/constants/spacing.dart';
import '../../core/themes/web_text_styles.dart';
import '../../core/themes/web_colors.dart';
import '../../core/ui/primary_button.dart';
import '../../core/ui/second_button.dart';
import '../widgets/metric_card.dart';

class HeroSection extends StatelessWidget {
  final VoidCallback onGetStarted;
  final VoidCallback onLearnMore;

  const HeroSection({
    super.key,
    required this.onGetStarted,
    required this.onLearnMore,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xxxl * 2),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFE0F2FE),
            Color(0xFFCCFBF1),
          ],
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left side - Content
          Expanded(
            flex: 5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: WebColors.divider),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.rocket_launch,
                        size: 16,
                        color: WebColors.tealAccent,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        'Smart IoT Composting System',
                        style: WebTextStyles.caption.copyWith(
                          color: WebColors.tealAccent,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                RichText(
                  text: TextSpan(
                    style: WebTextStyles.h1.copyWith(
                      fontSize: 48,
                      height: 1.2,
                    ),
                    children: [
                      const TextSpan(text: 'Transform Your\n'),
                      TextSpan(
                        text: 'Organic Waste\n',
                        style: TextStyle(color: WebColors.tealAccent),
                      ),
                      const TextSpan(text: 'into Rich\nCompost'),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                Text(
                  'Accelerate decomposition with our IoT-enabled rotary\ndrum system. Monitor in real-time, automate\nprocesses, and produce quality compost in just 2\nweeks.',
                  style: WebTextStyles.subtitle.copyWith(
                    fontSize: 16,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxxl),
                Row(
                  children: [
                    PrimaryButton(
                      text: 'Start Composting →',
                      onPressed: onGetStarted,
                    ),
                    const SizedBox(width: AppSpacing.lg),
                    SecondaryButton(
                      text: 'Learn More',
                      onPressed: onLearnMore,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.xxxl),
          // Right side - Metrics
          Expanded(
            flex: 3,
            child: Column(
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: MetricsCard(
                        icon: Icons.thermostat_outlined,
                        value: '45°C',
                        label: 'Temperature',
                      ),
                    ),
                    const SizedBox(width: AppSpacing.lg),
                    const Expanded(
                      child: MetricsCard(
                        icon: Icons.water_drop_outlined,
                        value: '58%',
                        label: 'Moisture',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                Row(
                  children: [
                    const Expanded(
                      child: MetricsCard(
                        icon: Icons.air_outlined,
                        value: '21%',
                        label: 'Oxygen',
                      ),
                    ),
                    const SizedBox(width: AppSpacing.lg),
                    const Expanded(
                      child: MetricsCard(
                        icon: Icons.trending_up_outlined,
                        value: 'Day 8',
                        label: 'Progress',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}