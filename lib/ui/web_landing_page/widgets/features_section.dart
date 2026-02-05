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

  void goToPrevious() {
    if (_currentIndex > 0 && _pageController.hasClients) {
      _pageController.animateToPage(
        _currentIndex - 1,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  void goToNext() {
    if (_currentIndex < featureImages.length - 1 && _pageController.hasClients) {
      _pageController.animateToPage(
        _currentIndex + 1,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
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
    final isMobile = screenWidth < 600;

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

          // CAROUSEL — image with arrows and indicators inside
          ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: screenWidth > 1400 ? 1000 : screenWidth * 0.85,
              maxHeight: 500,
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Scaled image carousel
                SizedBox(
                  height: 440,
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: featureImages.length,
                    itemBuilder: (context, index) {
                      return _buildCarouselItem(index);
                    },
                  ),
                ),

                // LEFT ARROW — inside image, vertically centered
                Positioned(
                  left: isMobile ? 12 : 24,
                  child: Center(
                    child: Container(
                      width: isMobile ? 40 : 48,
                      height: isMobile ? 40 : 48,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0F8FF), // Alice blue
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.3),
                            blurRadius: 8,
                            spreadRadius: 0,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: IconButton(
                        onPressed: _currentIndex > 0 ? goToPrevious : null,
                        icon: Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: isMobile ? 20 : 24,
                          color: Colors.green,
                        ),
                        padding: EdgeInsets.zero,
                        splashRadius: isMobile ? 20 : 24,
                        style: ButtonStyle(
                          backgroundColor: WidgetStateProperty.all(Colors.transparent),
                          overlayColor: WidgetStateProperty.all(Colors.white.withValues(alpha: 0.1)),
                        ),
                      ),
                    ),
                  ),
                ),

                // RIGHT ARROW — inside image, vertically centered
                Positioned(
                  right: isMobile ? 12 : 24,
                  child: Center(
                    child: Container(
                      width: isMobile ? 40 : 48,
                      height: isMobile ? 40 : 48,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0F8FF), // Alice blue
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.3),
                            blurRadius: 8,
                            spreadRadius: 0,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: IconButton(
                        onPressed: _currentIndex < featureImages.length - 1 ? goToNext : null,
                        icon: Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: isMobile ? 20 : 24,
                          color: Colors.green,
                        ),
                        padding: EdgeInsets.zero,
                        splashRadius: isMobile ? 20 : 24,
                        style: ButtonStyle(
                          backgroundColor: WidgetStateProperty.all(Colors.transparent),
                          overlayColor: WidgetStateProperty.all(Colors.white.withValues(alpha: 0.1)),
                        ),
                      ),
                    ),
                  ),
                ),

                // INDICATORS — positioned at bottom inside image
                Positioned(
                  bottom: isMobile ? 16 : 24,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      featureImages.length,
                      (index) => Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _currentIndex == index ? (isMobile ? 20 : 24) : 8,
                        height: isMobile ? 6 : 8,
                        decoration: BoxDecoration(
                          color: _currentIndex == index 
                              ? Colors.white.withValues(alpha: 0.9)  // Active indicator - bright white
                              : Colors.white.withValues(alpha: 0.3), // Inactive indicator - muted/low opacity
                          borderRadius: BorderRadius.circular(4),
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
              constraints: const BoxConstraints(
                maxWidth: 700,
                maxHeight: 440,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: value > 0.95
                    ? [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.12),
                          blurRadius: 20,
                          spreadRadius: 0,
                          offset: const Offset(0, 8),
                        ),
                      ]
                    : [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.06),
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
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey.shade100,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.broken_image_outlined, size: 64, color: Colors.grey[500]),
                            const SizedBox(height: 12),
                            Text(
                              'Image Load Failed',
                              style: TextStyle(color: Colors.grey[700], fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}