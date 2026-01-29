// lib/ui/web_landing_page/web_landing_page.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/app_header.dart';
import '../widgets/intro_section.dart';
import '../widgets/features_section.dart';
import '../widgets/how_it_works_section.dart';
import '../widgets/impact_section.dart';
import '../widgets/banner_section.dart';
import '../widgets/contact_section.dart';
import '../view_models/landing_page_view_model.dart';

class WebLandingPageView extends StatefulWidget {
  const WebLandingPageView({super.key});

  @override
  State<WebLandingPageView> createState() => _WebLandingPageState();
}

class _WebLandingPageState extends State<WebLandingPageView> {
  final ScrollController _scrollController = ScrollController();
  final LandingPageViewModel _viewModel = LandingPageViewModel();

  // Section keys for navigation
  final GlobalKey _homeKey = GlobalKey();
  final GlobalKey _featuresKey = GlobalKey();
  final GlobalKey _howItWorksKey = GlobalKey();
  final GlobalKey _impactKey = GlobalKey();
  final GlobalKey _bannerKey = GlobalKey();

  String _activeSection = 'home';
  bool _isScrolled = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    // Update header style based on scroll
    final scrolled = _scrollController.offset > 50;
    if (scrolled != _isScrolled) {
      setState(() => _isScrolled = scrolled);
    }

    // Detect active section
    _updateActiveSection();
  }

  void _updateActiveSection() {
    final scrollOffset = _scrollController.offset;
    final screenHeight = MediaQuery.of(context).size.height;
    
    // Get section positions
    final homePos = _getSectionPosition(_homeKey);
    final featuresPos = _getSectionPosition(_featuresKey);
    final howItWorksPos = _getSectionPosition(_howItWorksKey);
    final impactPos = _getSectionPosition(_impactKey);
    final bannerPos = _getSectionPosition(_bannerKey);

    // Use 30% of screen height as threshold for section detection
    final threshold = screenHeight * 0.3;
    final currentPosition = scrollOffset + threshold;

    String newSection = 'home';
    
    if (currentPosition >= bannerPos) {
      newSection = 'banner';
    } else if (currentPosition >= impactPos) {
      newSection = 'impact';
    } else if (currentPosition >= howItWorksPos) {
      newSection = 'how-it-works';
    } else if (currentPosition >= featuresPos) {
      newSection = 'features';
    } else if (currentPosition >= homePos) {
      newSection = 'home';
    }

    if (newSection != _activeSection) {
      setState(() => _activeSection = newSection);
    }
  }

  double _getSectionPosition(GlobalKey key) {
    final context = key.currentContext;
    if (context == null) return 0;
    
    final box = context.findRenderObject() as RenderBox?;
    if (box == null) return 0;
    
    return box.localToGlobal(Offset.zero).dy + _scrollController.offset;
  }

  void _scrollToSection(String sectionId) {
    GlobalKey? targetKey;
    
    switch (sectionId) {
      case 'home':
        targetKey = _homeKey;
        break;
      case 'features':
        targetKey = _featuresKey;
        break;
      case 'how-it-works':
        targetKey = _howItWorksKey;
        break;
      case 'impact':
        targetKey = _impactKey;
        break;
      case 'banner':
        targetKey = _bannerKey;
        break;
    }

    if (targetKey?.currentContext != null) {
      final context = targetKey!.currentContext!;
      final box = context.findRenderObject() as RenderBox;
      final position = box.localToGlobal(Offset.zero).dy + _scrollController.offset;
      
      // Scroll to position minus header height (88px)
      _scrollController.animateTo(
        position - 88,
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOut,
      );
    }
  }

  // Navigation handlers
  void _handleLogin() {
    context.go('/login');
  }

  void _handleGetStarted() {
    context.go('/signup');
  }

  void _handleDownload() {
    context.go('/download');
  }

  void _handleLearnMore() {
    _scrollToSection('features');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Main scrollable content
          SingleChildScrollView(
            controller: _scrollController,
            child: Column(
              children: [
                // Add spacing for fixed header
                const SizedBox(height: 88),
                
                // HOME SECTION
                Container(
                  key: _homeKey,
                  child: IntroSection(
                    onGetStarted: _handleGetStarted,
                    onLearnMore: _handleLearnMore,
                  ),
                ),

                // FEATURES SECTION
                Container(
                  key: _featuresKey,
                  child: FeaturesSection(
                    features: _viewModel.features,
                  ),
                ),

                // HOW IT WORKS SECTION
                Container(
                  key: _howItWorksKey,
                  child: HowItWorksSection(
                    steps: _viewModel.steps,
                  ),
                ),

                // IMPACT SECTION
                Container(
                  key: _impactKey,
                  child: ImpactSection(
                    stats: _viewModel.impactStats,
                  ),
                ),

                // BANNER SECTION
                Container(
                  key: _bannerKey,
                  child: BannerSection(
                    onGetStarted: _handleGetStarted,
                    onDownload: _handleDownload,
                  ),
                ),

                // CONTACT SECTION
                ContactSection(
                  onGetStarted: _handleGetStarted,
                  onDownload: _handleDownload,
                  onNavigateToSection: _scrollToSection,
                ),
              ],
            ),
          ),

          // Fixed header at top
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: AppHeader(
              onLogin: _handleLogin,
              onGetStarted: _handleGetStarted,
              onDownload: _handleDownload,
              onBreadcrumbTap: _scrollToSection,
              activeSection: _activeSection,
              isScrolled: _isScrolled,
            ),
          ),
        ],
      ),
    );
  }
}