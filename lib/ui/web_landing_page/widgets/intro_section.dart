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
    return LayoutBuilder(
      builder: (context, constraints) {
        // Determine layout breakpoints
        final isMobile = constraints.maxWidth < 768;
        final isTablet = constraints.maxWidth >= 768 && constraints.maxWidth < 1024;
        final isDesktop = constraints.maxWidth >= 1024;

        return Container(
          width: double.infinity,
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
          padding: EdgeInsets.fromLTRB(
            isMobile ? AppSpacing.xl : (isTablet ? AppSpacing.xxxl * 2 : AppSpacing.xxxl * 3),
            isMobile ? AppSpacing.xxxl * 2 : (isTablet ? AppSpacing.xxxl * 2.5 : AppSpacing.xxxl * 3),
            isMobile ? AppSpacing.xl : (isTablet ? AppSpacing.xxxl * 2 : AppSpacing.xxxl * 3),
            isMobile ? AppSpacing.xxxl * 3 : (isTablet ? AppSpacing.xxxl * 4 : AppSpacing.xxxl * 7),
          ),
          child: isDesktop 
              ? _buildDesktopLayout(context)
              : _buildMobileTabletLayout(context, isMobile, isTablet),
        );
      },
    );
  }

  // Desktop layout (side-by-side)
  Widget _buildDesktopLayout(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // LEFT CONTENT - Text and CTAs
        Expanded(
          flex: 5,
          child: _buildLeftContent(context, false, false),
        ),
        const SizedBox(width: AppSpacing.xxxl),
        // RIGHT CONTENT - Cards
        Expanded(
          flex: 3,
          child: _buildRightCards(context, false),
        ),
      ],
    );
  }

  // Mobile/Tablet layout (stacked - left content BEFORE right content)
  Widget _buildMobileTabletLayout(BuildContext context, bool isMobile, bool isTablet) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // LEFT CONTENT FIRST (appears on top on mobile/tablet)
        _buildLeftContent(context, isMobile, isTablet),
        SizedBox(height: isMobile ? AppSpacing.xxxl * 2 : AppSpacing.xxxl * 2.5),
        // RIGHT CONTENT SECOND (appears below on mobile/tablet)
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
              fontSize: isMobile ? 32 : (isTablet ? 40 : 48),
              height: 1.2,
            ),
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
          'Accelerate decomposition with our IoT-enabled rotary drum system.\n'
          'Monitor in real-time, automate processes,\n'
          'and produce quality compost in just 2 weeks.',
          textAlign: isMobile ? TextAlign.center : TextAlign.start,
          style: WebTextStyles.subtitle.copyWith(
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
                  SizedBox(
                    height: 50,
                    child: SecondaryButton(
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
                    height: 50,
                    child: PrimaryButton(
                      text: 'Start Composting →',
                      onPressed: onGetStarted,
                    ),
                  ),
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
                label: 'Oxygen',
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