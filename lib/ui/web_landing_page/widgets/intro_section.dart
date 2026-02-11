// lib/ui/web_landing_page/widgets/intro_section.dart
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_application_1/ui/core/themes/app_theme.dart';

import '../../core/constants/spacing.dart';
import '../../core/themes/app_text_styles.dart';
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
    // Use MediaQuery instead of LayoutBuilder for more reliable responsive behavior on web
    final size = MediaQuery.sizeOf(context);
    final isMobile = size.width < 768;
    final isTablet = size.width >= 768 && size.width < 1024;
    final isDesktop = size.width >= 1024;

    return Stack(
      children: [
        /// Flipped Background Image with error fallback
        Positioned.fill(
          child: Transform(
            transform: Matrix4.rotationY(math.pi),
            alignment: Alignment.center,
            child: Image.asset(
              'assets/images/bg.png',
              fit: BoxFit.cover,
              cacheHeight: isMobile ? 600 : (isTablet ? 800 : 1200),
              cacheWidth: isMobile ? 600 : (isTablet ? 1000 : 1800),
              errorBuilder: (_, _, _) => Container(
                color: const Color(0xFF1F2937), // Dark gray fallback for readability
              ),
            ),
          ),
        ),

        /// Dark overlay to ensure text readability
        Positioned.fill(
          child: Container(
            color: Colors.black.withValues(alpha: 0.3),
          ),
        ),

        /// Image Credit (bottom-right)
        Positioned(
          bottom: AppSpacing.md,
          right: AppSpacing.md,
          child: Text(
            'Image courtesy of A1 Organics',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),

        /// Content — with min-height to prevent collapse
        Container(
          width: double.infinity,
          constraints: BoxConstraints(
            minHeight: isMobile ? 500 : 600, // 👈 CRITICAL: prevents blank screen
          ),
          padding: EdgeInsets.fromLTRB(
            isMobile ? AppSpacing.lg : (isTablet ? AppSpacing.xxxl * 2 : AppSpacing.xxxl * 3),
            isMobile ? AppSpacing.xxxl * 2 : (isTablet ? AppSpacing.xxxl * 2.5 : AppSpacing.xxxl * 3),
            isMobile ? AppSpacing.lg : (isTablet ? AppSpacing.xxxl * 2 : AppSpacing.xxxl * 3),
            isMobile ? AppSpacing.xxxl * 3 : (isTablet ? AppSpacing.xxxl * 4 : AppSpacing.xxxl * 7),
          ),
          child: isDesktop
              ? _buildDesktopLayout(context)
              : _buildMobileTabletLayout(context, isMobile, isTablet),
        ),
      ],
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
          height: isMobile ? AppSpacing.xxxl * 2 : AppSpacing.xxxl * 2.5,
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
    // ✅ Use slightly larger base styles for better visibility
    TextStyle heroStyle;
    TextStyle subtitleStyle;
    
    if (isMobile) {
      // Make mobile text noticeably larger than before
      heroStyle = AppTextStyles.introHeroMobile.copyWith(fontSize: 36, height: 1.2);
      subtitleStyle = AppTextStyles.introSubtitleMobile.copyWith(fontSize: 16, height: 1.5);
    } else if (isTablet) {
      heroStyle = AppTextStyles.introHeroTablet.copyWith(fontSize: 44, height: 1.2);
      subtitleStyle = AppTextStyles.introSubtitleTablet.copyWith(fontSize: 17, height: 1.5);
    } else {
      heroStyle = AppTextStyles.introHeroDesktop.copyWith(fontSize: 52, height: 1.2);
      subtitleStyle = AppTextStyles.introSubtitleDesktop.copyWith(fontSize: 18, height: 1.5);
    }

    return Column(
      crossAxisAlignment: isMobile ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        if (!isMobile) const SizedBox(height: AppSpacing.xl),

        /// Heading
        RichText(
          textAlign: isMobile ? TextAlign.center : TextAlign.start,
          text: TextSpan(
            style: heroStyle.copyWith(color: Colors.white),
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

        /// Subtitle — ✅ Grammar fixed: "IoT-enabled"
        Text(
          'Accelerate decomposition with our IoT-enabled rotary drum system.\n'
          'Monitor in real-time, automate processes,\n'
          'and produce quality compost within 2 weeks.',
          textAlign: isMobile ? TextAlign.center : TextAlign.start,
          style: subtitleStyle.copyWith(
            color: Colors.white.withValues(alpha: 0.92),
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
                hoverInfo: 'Optimal range: 40–60°C for thermophilic composting',
                position: 0,
                iconColor: const Color(0xFFF44336),
              ),
            ),
            SizedBox(width: AppSpacing.lg),
            Expanded(
              child: TemMoisOxyCard(
                icon: Icons.water_drop_outlined,
                value: '58%',
                label: 'Moisture',
                hoverInfo: 'Ideal moisture level for efficient decomposition',
                position: 1,
                iconColor: const Color(0xFF2196F3),
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
                value: '21 ppm', // ✅ Already corrected to ppm
                label: 'Aeration',
                hoverInfo: 'Adequate aeration for aerobic decomposition',
                position: 2,
                iconColor: const Color(0xFF03A9F4),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
