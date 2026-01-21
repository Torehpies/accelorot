// lib/ui/landing_page/widgets/impact_section.dart

import 'package:flutter/material.dart';
import '../../core/constants/spacing.dart';
import '../../core/themes/web_text_styles.dart';
import '../../core/themes/web_colors.dart';
import '../models/impact_stat_model.dart';
import 'impact_stat_card.dart';

class ImpactSection extends StatelessWidget {
  final List<ImpactStatModel> stats;
  const ImpactSection({
    super.key,
    required this.stats,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xxxl,
        vertical: AppSpacing.xxl * 2,
      ),
      color: Colors.white,
      child: LayoutBuilder(
        builder: (context, constraints) {
          bool isMobile = constraints.maxWidth < 900;

          return isMobile
              ? _buildMobileLayout(context)
              : _buildDesktopLayout(context);
        },
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return Column(
      children: [
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: WebTextStyles.h2.copyWith(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: WebColors.textHeading,
            ),
            children: const [
              TextSpan(text: 'Making a '),
              TextSpan(
                text: 'Sustainable\nImpact',
                style: TextStyle(
                  color: WebColors.greenAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          'In the Philippines, over 50% of municipal solid waste is organic. Accel-O-Rot helps manage waste responsibly.',
          textAlign: TextAlign.center,
          style: WebTextStyles.sectionSubtitle.copyWith(
            fontSize: 16,
            color: WebColors.textSecondary,
          ),
        ),
        const SizedBox(height: AppSpacing.xl * 2),
        _buildImpactItem(
          Icons.recycling_outlined,
          'Reduces landfill waste',
        ),
        const SizedBox(height: AppSpacing.md),
        _buildImpactItem(
          Icons.eco_outlined,
          'Produces nutrient-rich compost',
        ),
        const SizedBox(height: AppSpacing.md),
        _buildImpactItem(
          Icons.people_outline,
          'Empowers communities',
        ),
        const SizedBox(height: AppSpacing.xxl * 2),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: AppSpacing.md,
            mainAxisSpacing: AppSpacing.md,
            childAspectRatio: 1.0,
          ),
          itemCount: stats.length,
          itemBuilder: (context, index) {
            return ImpactStatCard(stat: stats[index]);
          },
        ),
      ],
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 4,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(
                text: TextSpan(
                  style: WebTextStyles.h2.copyWith(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: WebColors.textHeading,
                  ),
                  children: const [
                    TextSpan(text: 'Making a '),
                    TextSpan(
                      text: 'Sustainable\nImpact',
                      style: TextStyle(
                        color: WebColors.greenAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'In the Philippines, over 50% of municipal solid waste is organic. Accel-O-Rot helps manage waste responsibly.',
                style: WebTextStyles.sectionSubtitle.copyWith(
                  fontSize: 16,
                  color: WebColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.xl * 2),
              _buildImpactItem(
                Icons.recycling_outlined,
                'Reduces landfill waste',
              ),
              const SizedBox(height: AppSpacing.md),
              _buildImpactItem(
                Icons.eco_outlined,
                'Produces nutrient-rich compost',
              ),
              const SizedBox(height: AppSpacing.md),
              _buildImpactItem(
                Icons.people_outline,
                'Empowers communities',
              ),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.xxxl),
        Expanded(
          flex: 3,
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: AppSpacing.md,
              mainAxisSpacing: AppSpacing.md,
              childAspectRatio: 1.0,
            ),
            itemCount: stats.length,
            itemBuilder: (context, index) {
              return ImpactStatCard(stat: stats[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildImpactItem(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: WebColors.greenAccent.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 18,
            color: WebColors.greenAccent,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Text(
            text,
            style: WebTextStyles.bodyText.copyWith(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: WebColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}
