// lib/ui/web_landing_page/widgets/features_section.dart

import 'package:flutter/material.dart';

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
  double _currentPage = 0.0;

  final List<String> featureImages = [
    'assets/images/Mobile Dashboard.png',
    'assets/images/AI Recommendations.png',
    'assets/images/Auto-Regulations.png',
    'assets/images/Real-Time Alerts.png',
    'assets/images/Data Analytics.png',
    'assets/images/Sustainable Composting.png',
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.85);
    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page ?? 0.0;
        _currentIndex = _currentPage.round();
      });
    });
  }

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
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth > 1200 ? AppSpacing.xxxl * 2 : AppSpacing.xl,
        vertical: AppSpacing.xxxl * 1.5,
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
          const SizedBox(height: AppSpacing.md),
          Text(
            'Our IoT-enabled system combines automation, real-time monitoring, and AI recommendations',
            textAlign: TextAlign.center,
            style: WebTextStyles.subtitle,
          ),
          const SizedBox(height: AppSpacing.lg),

          // CAROUSEL
          ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: screenWidth > 1400 ? 1000 : screenWidth * 0.85,
              maxHeight: 500,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: featureImages.length,
                    itemBuilder: (context, index) {
                      return _buildCarouselItem(index);
                    },
                  ),
                ),
                const SizedBox(height: 20),
                // INDICATOR DOTS
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    featureImages.length,
                    (index) => GestureDetector(
                      onTap: () {
                        _pageController.animateToPage(
                          index,
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeInOut,
                        );
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 6),
                        width: index == _currentIndex ? 32 : 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: index == _currentIndex
                              ? WebColors.greenAccent
                              : Colors.grey.withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }

  Widget _buildCarouselItem(int index) {
    return AnimatedBuilder(
      animation: _pageController,
      builder: (context, child) {
        double value = 1.0;

        if (_pageController.position.haveDimensions) {
          value = _pageController.page! - index;
          value = (1 - (value.abs() * 0.15)).clamp(0.85, 1.0);
        }

        return Center(
          child: Transform.scale(
            scale: value,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Opacity(
                opacity: value > 0.9 ? 1.0 : 0.6,
                child: Container(
                  constraints: const BoxConstraints(
                    maxWidth: 700,
                    maxHeight: 440,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: value > 0.95
                        ? [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.12),
                              blurRadius: 20,
                              spreadRadius: 0,
                              offset: const Offset(0, 8),
                            ),
                          ]
                        : [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.06),
                              blurRadius: 10,
                              spreadRadius: 0,
                              offset: const Offset(0, 4),
                            ),
                          ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.asset(
                      featureImages[index],
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.broken_image_outlined,
                                color: Colors.grey.shade400,
                                size: 56,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Failed to load image',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                featureImages[index],
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}