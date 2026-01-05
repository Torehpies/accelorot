// lib/ui/landing_page/widgets/features_section.dart

import 'package:flutter/material.dart';
import '../../core/constants/spacing.dart';
import '../../core/themes/web_text_styles.dart';
import '../../core/themes/web_colors.dart';
import '../models/feature_model.dart';
import 'feature_card.dart';

class FeaturesSection extends StatelessWidget {
  final List<FeatureModel> features;
  const FeaturesSection({
    super.key,
    required this.features,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xxxl * 2),
      color: Colors.white,
      child: Column(
        children: [
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: WebTextStyles.h2,
              children: [
                const TextSpan(text: 'Smart Features for '),
                TextSpan(
                  text: 'Efficient Composting',
                  style: TextStyle(color: WebColors.tealAccent),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Our IoT-enabled system combines automation, real-time monitoring, and AI recommendations',
            textAlign: TextAlign.center,
            style: WebTextStyles.subtitle,
          ),
          const SizedBox(height: AppSpacing.xxxl * 2),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: AppSpacing.xl,
              mainAxisSpacing: AppSpacing.xl,
              mainAxisExtent: 250, 
            ),
            itemCount: features.length,
            itemBuilder: (context, index) {
              return FeatureCard(feature: features[index]);
            },
          ),
        ],
      ),
    );
  }
}