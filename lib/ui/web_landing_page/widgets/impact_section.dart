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
      padding: const EdgeInsets.all(AppSpacing.xxxl * 2),
      color: Colors.white,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left side - Content
          Expanded(
            flex: 4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    style: WebTextStyles.h2,
                    children: [
                      const TextSpan(text: 'Making a '),
                      TextSpan(
                        text: 'Sustainable\nImpact',
                        style: TextStyle(color: WebColors.tealAccent),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                Text(
                  'In the Philippines, over 50% of municipal solid waste is\norganic. Accel-O-Rot helps communities and institutions\nmanage waste responsibly while producing valuable\ncompost for agriculture.',
                  style: WebTextStyles.subtitle.copyWith(
                    fontSize: 15,
                    height: 1.8,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxxl),
                _buildImpactItem(
                  Icons.recycling_outlined,
                  'Reduces landfill waste and methane emissions',
                ),
                const SizedBox(height: AppSpacing.lg),
                _buildImpactItem(
                  Icons.eco_outlined,
                  'Produces nutrient-rich compost for sustainable farming',
                ),
                const SizedBox(height: AppSpacing.lg),
                _buildImpactItem(
                  Icons.people_outline,
                  'Empowers households and communities with accessible\ntechnology',
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.xxxl * 2),
          // Right side - Stats
          Expanded(
            flex: 3,
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: AppSpacing.lg,
                mainAxisSpacing: AppSpacing.lg,
                childAspectRatio: 1.2,
              ),
              itemCount: stats.length,
              itemBuilder: (context, index) {
                return ImpactStatCard(stat: stats[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImpactItem(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: const Color(0xFFCCFBF1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(
            icon,
            size: 18,
            color: WebColors.tealAccent,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              text,
              style: WebTextStyles.bodyMediumGray.copyWith(
                fontSize: 15,
                height: 1.6,
              ),
            ),
          ),
        ),
      ],
    );
  }
}