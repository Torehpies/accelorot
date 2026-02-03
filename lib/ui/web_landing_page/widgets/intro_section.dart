import 'package:flutter/material.dart';
import 'package:flutter_application_1/ui/core/themes/app_theme.dart';
import '../../core/constants/spacing.dart';
import '../../core/themes/web_text_styles.dart';
import '../../core/ui/primary_button.dart';
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
        // Determine layout breakpoints
        final isMobile = constraints.maxWidth < 768;
        final isTablet = constraints.maxWidth >= 768 && constraints.maxWidth < 1024;
        final isDesktop = constraints.maxWidth >= 1024;

        return Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                'assets/images/bg.png',
                fit: BoxFit.cover,
                cacheHeight: 1000,
                cacheWidth: 1000,
              ),
            ),
            Positioned.fill(
              child: Container(
                color: Colors.black.withValues(alpha: 0.2),
              ),
            ),
            Container(
              width: double.infinity,
              padding: EdgeInsets.fromLTRB(
                isMobile ? AppSpacing.xl : (isTablet ? AppSpacing.xxxl * 2 : AppSpacing.xxxl * 3),
                isMobile ? AppSpacing.xxxl * 2 : (isTablet ? AppSpacing.xxxl * 2.5 : AppSpacing.xxxl * 3),
                isMobile ? AppSpacing.xl : (isTablet ? AppSpacing.xxxl * 2 : AppSpacing.xxxl * 3),
                isMobile ? AppSpacing.xxxl * 3 : (isTablet ? AppSpacing.xxxl * 4 : AppSpacing.xxxl * 7),
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

  // Desktop layout (side-by-side)
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
          child: _buildRightCards(context, false),
        ),
      ],
    );
  }

  Widget _buildMobileTabletLayout(BuildContext context, bool isMobile, bool isTablet) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildLeftContent(context, isMobile, isTablet),
        SizedBox(height: isMobile ? AppSpacing.xxxl * 2 : AppSpacing.xxxl * 2.5),
        _buildRightCards(context, isMobile),
      ],
    );
  }

  Widget _buildLeftContent(BuildContext context, bool isMobile, bool isTablet) {
    return Column(
      crossAxisAlignment: isMobile ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        if (!isMobile) const SizedBox(height: AppSpacing.xl),
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
                  color: AppColors.green100.withValues(alpha: 0.8), // FIXED: comma instead of semicolon, proper opacity method
                  fontWeight: FontWeight.bold,
                ),
              ),
              const TextSpan(text: 'into Rich Compost'),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        Text(
          'Accelerate decomposition with our IoT-enabled rotary drum system.\n'
          'Monitor in real-time, automate processes,\n'
          'and produce quality compost in just 2 weeks.',
          textAlign: isMobile ? TextAlign.center : TextAlign.start,
          style: WebTextStyles.subtitle.copyWith(
            color: Colors.white,
            fontSize: isMobile ? 14 : (isTablet ? 15 : 16),
            height: 1.6,
          ),
        ),
        const SizedBox(height: AppSpacing.xxxl),
        // Buttons layout
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
                  // Learn More button with white text
                  SizedBox(
                    height: 50,
                    child: OutlinedButton(
                      onPressed: onLearnMore,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: isMobile ? 24 : 32,
                        ),
                      ),
                      child: const Text(
                        'Learn More',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              )
            : Wrap(
                spacing: AppSpacing.lg,
                runSpacing: AppSpacing.md,
                children: [
                  SizedBox(
                    height: 50,
                    child: PrimaryButton(
                      text: 'Start Composting →',
                      onPressed: onGetStarted,
                    ),
                  ),
                  // Learn More button with white text
                  SizedBox(
                    height: 50,
                    child: OutlinedButton(
                      onPressed: onLearnMore,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                      ),
                      child: const Text(
                        'Learn More',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
      ],
    );
  }

  Widget _buildRightCards(BuildContext context, bool isMobile) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: const [
            Expanded(
              child: TemMoisOxyCard(
                icon: Icons.thermostat_outlined,
                value: '45°C',
                label: 'Temperature',
                hoverInfo: 'Optimal range: 40-60°C for thermophilic composting',
                position: 0,
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
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        Row(
          children: const [
            Expanded(
              child: TemMoisOxyCard(
                icon: Icons.air_outlined,
                value: '21%',
                label: 'Aeration',
                hoverInfo: 'Adequate aeration for aerobic decomposition',
                position: 2,
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
              ),
            ),
          ],
        ),
      ],
    );
  }
}