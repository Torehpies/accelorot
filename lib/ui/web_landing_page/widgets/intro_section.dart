import 'package:flutter/material.dart';
import 'package:flutter_application_1/ui/core/themes/app_theme.dart';

import '../../core/constants/spacing.dart';
import '../../core/themes/web_text_styles.dart';
import '../../core/ui/primary_button.dart';
import '../../core/ui/tap_button.dart';
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
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 768;
        final isTablet =
            constraints.maxWidth >= 768 && constraints.maxWidth < 1024;
        final isDesktop = constraints.maxWidth >= 1024;

        return Stack(
          children: [
            /// Background Image (now visible without overlay)
            Positioned.fill(
              child: Image.asset(
                'assets/images/bg.png',
                fit: BoxFit.cover,
                cacheHeight: isMobile ? 600 : (isTablet ? 800 : 1200),
                cacheWidth: isMobile ? 600 : (isTablet ? 1000 : 1800),
              ),
            ),

            /// Content
            Container(
              width: double.infinity,
              padding: EdgeInsets.fromLTRB(
                isMobile
                    ? AppSpacing.xl
                    : (isTablet
                        ? AppSpacing.xxxl * 2
                        : AppSpacing.xxxl * 3),
                isMobile
                    ? AppSpacing.xxxl * 2
                    : (isTablet
                        ? AppSpacing.xxxl * 2.5
                        : AppSpacing.xxxl * 3),
                isMobile
                    ? AppSpacing.xl
                    : (isTablet
                        ? AppSpacing.xxxl * 2
                        : AppSpacing.xxxl * 3),
                isMobile
                    ? AppSpacing.xxxl * 3
                    : (isTablet
                        ? AppSpacing.xxxl * 4
                        : AppSpacing.xxxl * 7),
              ),
              child: isDesktop
                  ? _buildDesktopLayout(context)
                  : _buildMobileTabletLayout(context, isMobile, isTablet),
            ),
          ],
        );
      },
    );
  }

  // ───────────────────────────────── Desktop Layout
  Widget _buildDesktopLayout(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 5,
          child: _buildLeftContent(context, false, false),
        ),
        const SizedBox(width: AppSpacing.xxxl),
        Expanded(
          flex: 3,
          child: _buildRightCards(context),
        ),
      ],
    );
  }

  // ───────────────────────────────── Mobile / Tablet Layout
  Widget _buildMobileTabletLayout(
    BuildContext context,
    bool isMobile,
    bool isTablet,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildLeftContent(context, isMobile, isTablet),
        SizedBox(
          height: isMobile
              ? AppSpacing.xxxl * 2
              : AppSpacing.xxxl * 2.5,
        ),
        _buildRightCards(context),
      ],
    );
  }

  // ───────────────────────────────── Left Content
  Widget _buildLeftContent(
    BuildContext context,
    bool isMobile,
    bool isTablet,
  ) {
    return Column(
      crossAxisAlignment:
          isMobile ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        if (!isMobile) const SizedBox(height: AppSpacing.xl),

        /// Heading
        RichText(
          textAlign: isMobile ? TextAlign.center : TextAlign.start,
          text: TextSpan(
            style: WebTextStyles.h1.copyWith(
              color: Colors.white,
              fontSize: isMobile ? 32 : (isTablet ? 40 : 48),
              height: 1.2,
            ),
            children: [
              const TextSpan(text: 'Transform Your\n'),
              TextSpan(
                text: 'Organic Waste\n',
                style: TextStyle(
                  color: AppColors.green100,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const TextSpan(text: 'into Rich Compost'),
            ],
          ),
        ),

        const SizedBox(height: AppSpacing.xl),

        /// Subtitle
        Text(
          'Accelerate decomposition with our IoT-enabled rotary drum system.\n'
          'Monitor in real-time, automate processes,\n'
          'and produce quality compost in just 2 weeks.',
          textAlign: isMobile ? TextAlign.center : TextAlign.start,
          style: WebTextStyles.subtitle.copyWith(
            color: Colors.white.withValues(alpha: 0.92),
            fontSize: isMobile ? 14 : (isTablet ? 15 : 16),
            height: 1.6,
          ),
        ),

        const SizedBox(height: AppSpacing.xxxl),

        /// Buttons
        isMobile
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    height: 50,
                    child: PrimaryButton(
                      text: 'Start Composting →',
                      onPressed: onGetStarted,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  SizedBox(
                    height: 50,
                    width: double.infinity,
                    child: TapButton(
                      text: 'Learn More',
                      onPressed: onLearnMore,
                    ),
                  ),
                ],
              )
            : Wrap(
                spacing: AppSpacing.lg,
                runSpacing: AppSpacing.md,
                children: [
                  SizedBox(
                    height: 56,
                    width: 220,
                    child: PrimaryButton(
                      text: 'Start Composting →',
                      onPressed: onGetStarted,
                    ),
                  ),
                  SizedBox(
                    height: 56,
                    width: 170,
                    child: TapButton(
                      text: 'Learn More',
                      onPressed: onLearnMore,
                    ),
                  ),
                ],
              ),
      ],
    );
  }

  // ───────────────────────────────── Right Cards
  Widget _buildRightCards(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Expanded(
              child: TemMoisOxyCard(
                icon: Icons.thermostat_outlined,
                value: '45°C',
                label: 'Temperature',
                hoverInfo:
                    'Optimal range: 40–60°C for thermophilic composting',
                position: 0,
                iconColor: const Color(0xFFF44336), // Warm red for heat
              ),
            ),
            SizedBox(width: AppSpacing.lg),
            Expanded(
              child: TemMoisOxyCard(
                icon: Icons.water_drop_outlined,
                value: '58%',
                label: 'Moisture',
                hoverInfo:
                    'Ideal moisture level for efficient decomposition',
                position: 1,
                iconColor: const Color(0xFF2196F3), // Blue for water
              ),
            ),
          ],
        ),
        SizedBox(height: AppSpacing.lg),
        Row(
          children: [
            Expanded(
              child: TemMoisOxyCard(
                icon: Icons.air_outlined,
                value: '21%',
                label: 'Aeration',
                hoverInfo:
                    'Adequate aeration for aerobic decomposition',
                position: 2,
                iconColor: const Color(0xFF03A9F4), // Light blue for air
              ),
            ),
            SizedBox(width: AppSpacing.lg),
            Expanded(
              child: TemMoisOxyCard(
                icon: Icons.trending_up_outlined,
                value: 'Day 14',
                label: 'Complete',
                hoverInfo: '2-week composting cycle',
                position: 3,
                iconColor: AppColors.green100, // Green for success/completion
              ),
            ),
          ],
        ),
      ],
    );
  }
}