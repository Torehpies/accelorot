import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/constants/spacing.dart';
import '../../core/themes/web_text_styles.dart';
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
  Timer? _autoScrollTimer;

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
    // Increased viewportFraction from 0.25 to 0.45 for larger visible images
    _pageController = PageController(viewportFraction: 0.45);
    _pageController.addListener(() {
      if (!mounted) return;
      setState(() {
        _currentPage = _pageController.page ?? 0.0;
        _currentIndex = _currentPage.round();
      });
    });
    _startAutoScroll();
  }

  void _startAutoScroll() {
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (!mounted) return;
      if (_pageController.hasClients) {
        final nextPage = (_currentIndex + 1) % featureImages.length;
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  void _stopAutoScroll() {
    _autoScrollTimer?.cancel();
  }

  @override
  void dispose() {
    _stopAutoScroll();
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
                  style: TextStyle(color: Color(0xFF2D3748)),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Our IoT-enabled system combines automation, monitoring, and AI Chatbot',
            textAlign: TextAlign.center,
            style: WebTextStyles.subtitle,
          ),
          const SizedBox(height: AppSpacing.xl * 1.5),

          // CAROUSEL - Images only with increased size
          SizedBox(
            // Increased height for larger images
            height: isMobile ? 420 : 580,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // PageView with images only
                PageView.builder(
                  controller: _pageController,
                  itemCount: featureImages.length,
                  onPageChanged: (index) {
                    if (mounted) {
                      setState(() => _currentIndex = index);
                    }
                  },
                  itemBuilder: (context, index) {
                    return _buildImageCard(index, isMobile);
                  },
                ),

                // INDICATORS - Modern dots at bottom
                Positioned(
                  bottom: isMobile ? 16 : 24,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      featureImages.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 6),
                        width: _currentIndex == index 
                            ? (isMobile ? 32 : 40) 
                            : 10,
                        height: _currentIndex == index ? 10 : 10,
                        decoration: BoxDecoration(
                          color: _currentIndex == index 
                              ? const Color(0xFF2D3748)
                              : Colors.grey.shade300,
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

  Widget _buildImageCard(int index, bool isMobile) {
    return AnimatedBuilder(
      animation: _pageController,
      builder: (context, child) {
        double scale = 1.0;
        double opacity = 1.0;
        double yOffset = 0.0;

        if (_pageController.position.haveDimensions) {
          final value = (_pageController.page! - index).abs();
          
          // Adjusted scale curve for more prominent active image
          scale = (1 - (value * 0.25)).clamp(0.85, 1.0);
          opacity = (1 - (value * 0.4)).clamp(0.6, 1.0);
          yOffset = value * 15;
        }

        return Center(
          child: Transform.translate(
            offset: Offset(0, -yOffset),
            child: Transform.scale(
              scale: scale,
              child: Opacity(
                opacity: opacity,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Image.asset(
                    featureImages[index],
                    // Changed to BoxFit.scaleDown for better high-res handling
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.center,
                    // Added cacheWidth/cacheHeight for better performance with large images
                    cacheWidth: isMobile ? 600 : 1200,
                    cacheHeight: isMobile ? 400 : 800,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: isMobile ? 280 : 500,
                        height: isMobile ? 350 : 600,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Center(
                          child: Icon(
                            Icons.broken_image_outlined,
                            size: isMobile ? 56 : 80,
                            color: Colors.grey.shade400,
                          ),
                        ),
                      );
                    },
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