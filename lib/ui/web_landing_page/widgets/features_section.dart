// lib/ui/web_landing_page/widgets/features_section.dart

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/constants/spacing.dart';
import '../../core/themes/web_text_styles.dart';
import '../../core/themes/web_colors.dart';
import '../models/feature_model.dart';

class FeaturesSection extends StatefulWidget {
  final List<FeatureModel> features;

  const FeaturesSection({
    super.key,
    required this.features,
  });

  static FeaturesSectionState? of(BuildContext? context) {
    return context?.findAncestorStateOfType<FeaturesSectionState>();
  }

  @override
  State<FeaturesSection> createState() => FeaturesSectionState();
}

class FeaturesSectionState extends State<FeaturesSection> {
  late PageController _pageController;
  int _currentIndex = 0;

  final List<String> featureImages = [
    'assets/images/mobile_dashboard_1.svg',
    'assets/images/ai_recommendations_1.svg',
    'assets/images/auto_regulations_1.svg',
    'assets/images/real_time_alerts_1.svg',
    'assets/images/data_analytics_1.svg',
    'assets/images/sustainable_composting_1.svg',
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.85);
    _pageController.addListener(() {
      setState(() {
        _currentIndex = (_pageController.page ?? 0).round();
      });
    });
  }

  // ✅ CRITICAL: This method was missing — now added!
  void resetCarousel() {
    if (_pageController.hasClients) {
      _pageController.animateToPage(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xxxl * 2,
        vertical: AppSpacing.xxxl * 3,
      ),
      color: Colors.white,
      child: Column(
        children: [
          // TITLE
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: WebTextStyles.h2,
              children: const [
                TextSpan(text: 'Smart Features for '),
                TextSpan(
                  text: 'Efficient Composting',
                  style: TextStyle(color: WebColors.textTitle),
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
          const SizedBox(height: AppSpacing.xxxl),

          // CAROUSEL
          SizedBox(
            height: 380,
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                PageView.builder(
                  controller: _pageController,
                  itemCount: featureImages.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: Container(
                          height: 300,
                          color: Colors.grey.shade50,
                          child: Center(
                            child: SvgPicture.asset(
                              featureImages[index],
                              fit: BoxFit.scaleDown,
                              width: 280,
                              height: 280,
                              placeholderBuilder: (context) =>
                                  const CircularProgressIndicator(),
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.broken_image,
                                          color: Colors.red, size: 48),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Failed to load:\n${featureImages[index]}',
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                            fontSize: 12, color: Colors.black87),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        error.toString().split('\n').first,
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                            fontSize: 10, color: Colors.red),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),

                // INDICATOR DOTS
                Positioned(
                  bottom: 12,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(
                      featureImages.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 6),
                        width: index == _currentIndex ? 22 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: index == _currentIndex
                              ? WebColors.greenAccent
                              : Colors.grey.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}