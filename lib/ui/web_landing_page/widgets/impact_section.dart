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
      padding: const EdgeInsets.all(AppSpacing.xxxl), // Reduced padding
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
          text: TextSpan(
            style: WebTextStyles.h2.copyWith(fontSize: 28), // Smaller title
            children: const [
              TextSpan(text: 'Making a '),
              TextSpan(
                text: 'Sustainable\nImpact',
                style: TextStyle(color: WebColors.tealAccent),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md), // Reduced space
        
        Text(
          'In the Philippines, over 50% of municipal solid waste is\n'
          'organic. Accel-O-Rot helps manage waste responsibly.',
          textAlign: TextAlign.center,
          style: WebTextStyles.subtitle.copyWith(
            fontSize: 14, // Smaller text
            height: 1.6,  // Tighter line spacing
          ),
        ),
        const SizedBox(height: AppSpacing.xl), // Reduced space
        
        _buildImpactItem(
          Icons.recycling_outlined,
          'Reduces landfill waste',
        ),
        const SizedBox(height: AppSpacing.md), // Reduced space
        _buildImpactItem(
          Icons.eco_outlined,
          'Produces nutrient-rich compost',
        ),
        const SizedBox(height: AppSpacing.md), // Reduced space
        _buildImpactItem(
          Icons.people_outline,
          'Empowers communities',
        ),
        
        const SizedBox(height: AppSpacing.xl), // Reduced space
        
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: AppSpacing.md, // Reduced spacing
            mainAxisSpacing: AppSpacing.md,  // Reduced spacing
            childAspectRatio: 1, // Square cards
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
                  style: WebTextStyles.h2.copyWith(fontSize: 28), // Smaller title
                  children: const [
                    TextSpan(text: 'Making a '),
                    TextSpan(
                      text: 'Sustainable\nImpact',
                      style: TextStyle(color: WebColors.tealAccent),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md), // Reduced space
              Text(
                'In the Philippines, over 50% of municipal solid waste is\n'
                'organic. Accel-O-Rot helps manage waste responsibly.',
                style: WebTextStyles.subtitle.copyWith(
                  fontSize: 14, // Smaller text
                  height: 1.6,  // Tighter line spacing
                ),
              ),
              const SizedBox(height: AppSpacing.xl), // Reduced space
              _buildImpactItem(
                Icons.recycling_outlined,
                'Reduces landfill waste',
              ),
              const SizedBox(height: AppSpacing.md), // Reduced space
              _buildImpactItem(
                Icons.eco_outlined,
                'Produces nutrient-rich compost',
              ),
              const SizedBox(height: AppSpacing.md), // Reduced space
              _buildImpactItem(
                Icons.people_outline,
                'Empowers communities',
              ),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.xl), // Reduced space
        
        Expanded(
          flex: 3,
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: AppSpacing.md, // Reduced spacing
              mainAxisSpacing: AppSpacing.md,  // Reduced spacing
              childAspectRatio: 1, // Square cards
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 28, // Smaller icon container
          height: 28,
          decoration: BoxDecoration(
            color: const Color(0xFFCCFBF1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(
            icon,
            size: 16, // Smaller icon
            color: WebColors.tealAccent,
          ),
        ),
        const SizedBox(width: AppSpacing.sm), // Reduced space
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 2), // Reduced space
            child: Text(
              text,
              style: WebTextStyles.bodyMediumGray.copyWith(
                fontSize: 14, // Smaller text
                height: 1.4,  // Tighter line spacing
              ),
            ),
          ),
        ),
      ],
    );
  }
}