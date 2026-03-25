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
  Timer? _autoScrollTimer;

  // Track the last fraction so we can rebuild on significant size change
  double _lastFraction = 0.45;

  final List<String> featureImages = [
    'assets/images/Mobile Dashboard.png',
    'assets/images/AI Recommendations.png',
    'assets/images/Auto-Regulations.png',
    'assets/images/Real-Time Alerts.png',
    'assets/images/Data Analytics.png',
    'assets/images/Sustainable Composting.png',
  ];

  double _fractionForWidth(double w) {
    if (w < 480) return 0.85;
    if (w < 768) return 0.75;
    if (w < 1024) return 0.60;
    return 0.45;
  }

  double _carouselHeightForWidth(double w) {
    if (w < 480) return 340;
    if (w < 768) return 400;
    if (w < 1024) return 460;
    return 520;
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: _lastFraction);
    _pageController.addListener(_onPageChanged);
    _startAutoScroll();
  }

  void _onPageChanged() {
    if (!mounted) return;
    setState(() {
      _currentIndex = (_pageController.page ?? 0).round();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final w = MediaQuery.of(context).size.width;
    final newFraction = _fractionForWidth(w);
    if ((newFraction - _lastFraction).abs() > 0.05) {
      _lastFraction = newFraction;
      final savedIndex = _currentIndex;
      _pageController.removeListener(_onPageChanged);
      _pageController.dispose();
      _pageController =
          PageController(viewportFraction: newFraction, initialPage: savedIndex);
      _pageController.addListener(_onPageChanged);
    }
  }

  void _startAutoScroll() {
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!mounted || !_pageController.hasClients) return;
      final next = (_currentIndex + 1) % featureImages.length;
      _pageController.animateToPage(
        next,
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOut,
      );
    });
  }

  void _stopAutoScroll() => _autoScrollTimer?.cancel();

  @override
  void dispose() {
    _stopAutoScroll();
    _pageController.removeListener(_onPageChanged);
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final carouselHeight = _carouselHeightForWidth(screenWidth);

    // Reduced horizontal & vertical padding for tighter layout
    final hPad = screenWidth > 1200
        ? AppSpacing.xxxl * 2.0
        : AppSpacing.xl;
    const vPad = AppSpacing.xxxl;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: hPad, vertical: vPad),
      color: Colors.white,
      child: Column(
        children: [
          // ── Title ─────────────────────────────────────────────────────
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
          
          const SizedBox(height: AppSpacing.xs),
          
          Text(
            'Our IoT-enabled system combines automation, monitoring, and AI Chatbot',
            textAlign: TextAlign.center,
            style: WebTextStyles.subtitle,
          ),
          
          const SizedBox(height: AppSpacing.sm),

          // ── Carousel ──────────────────────────────────────────────────
          SizedBox(
            height: carouselHeight,
            child: Stack(
              alignment: Alignment.center,
              children: [
                PageView.builder(
                  controller: _pageController,
                  itemCount: featureImages.length,
                  onPageChanged: (i) =>
                      setState(() => _currentIndex = i),
                  itemBuilder: (ctx, i) =>
                      _buildImageCard(i, carouselHeight),
                ),

                // Dot indicators — rendered OVER the carousel
                Positioned(
                  bottom: 8,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      featureImages.length,
                      (i) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 5),
                        width: _currentIndex == i ? 36 : 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: _currentIndex == i
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
          
          const SizedBox(height: AppSpacing.sm),
        ],
      ),
    );
  }

  Widget _buildImageCard(int index, double carouselHeight) {
    return AnimatedBuilder(
      animation: _pageController,
      builder: (context, child) {
        double scale = 1.0;
        double opacity = 1.0;
        double yOffset = 0.0;

        if (_pageController.position.haveDimensions) {
          final value = (_pageController.page! - index).abs();
          scale = (1 - value * 0.22).clamp(0.88, 1.0);
          opacity = (1 - value * 0.35).clamp(0.65, 1.0);
          yOffset = value * 10;
        }

        return Center(
          child: Transform.translate(
            offset: Offset(0, -yOffset),
            child: Transform.scale(
              scale: scale,
              child: Opacity(
                opacity: opacity,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      featureImages[index],
                      fit: BoxFit.contain,
                      errorBuilder: (_, _, _) => Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Center(
                          child: Icon(
                            Icons.broken_image_outlined,
                            size: 64,
                            color: Colors.grey.shade400,
                          ),
                        ),
                      ),
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