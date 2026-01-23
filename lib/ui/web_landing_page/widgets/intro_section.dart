// lib/ui/landing_page/widgets/intro_section.dart

import 'package:flutter/material.dart';
import '../../core/constants/spacing.dart';
import '../../core/themes/web_text_styles.dart';
import '../../core/themes/web_colors.dart';
import '../../core/ui/primary_button.dart';
import '../../core/ui/second_button.dart';
import '../widgets/tem_mois_oxy_card.dart';

class IntroSection extends StatelessWidget {
  final VoidCallback onGetStarted;
  final VoidCallback onLearnMore;

  const IntroSection({
    super.key,
    required this.onGetStarted,
    required this.onLearnMore,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFE0F2FE), Color(0xFFCCFBF1)],
        ),
      ),
      padding: const EdgeInsets.all(AppSpacing.xxxl * 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left side - Content
          Expanded(
            flex: 5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppSpacing.xl),
                RichText(
                  text: TextSpan(
                    style: WebTextStyles.h1.copyWith(fontSize: 48, height: 1.2),
                    children: [
                      const TextSpan(text: 'Transform Your\n'),
                      TextSpan(
                        text: 'Organic Waste\n',
                        style: TextStyle(color: WebColors.iconsPrimary),
                      ),
                      const TextSpan(text: 'into Rich\nCompost'),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                Text(
                  'Accelerate decomposition with our IoT-enabled rotary drum system.\nMonitor in real-time, automate processes, \nand produce quality compost in just 2 weeks.',
                  style: WebTextStyles.subtitle.copyWith(
                    fontSize: 16,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxxl),
                Row(
                  children: [
                    SizedBox(
                      height: 50,
                      child: PrimaryButton(
                        text: 'Start Composting →',
                        onPressed: onGetStarted,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.lg),
                    SizedBox(
                      height: 50,
                      child: SecondaryButton(
                        text: 'Learn More',
                        onPressed: onLearnMore,
                      ),
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
                      child: TemMoisOxyCard(
                        icon: Icons.thermostat_outlined,
                        value: '45°C',
                        label: 'Temperature',
                      ),
                    ),
                    const SizedBox(width: AppSpacing.lg),
                    const Expanded(
                      child: TemMoisOxyCard(
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
                      child: TemMoisOxyCard(
                        icon: Icons.air_outlined,
                        value: '21%',
                        label: 'Oxygen',
                      ),
                    ),
                    const SizedBox(width: AppSpacing.lg),
                    const Expanded(
                      child: TemMoisOxyCard(
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
