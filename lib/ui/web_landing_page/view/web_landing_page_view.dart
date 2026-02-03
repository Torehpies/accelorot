import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/app_header.dart';
import '../widgets/intro_section.dart';
import '../widgets/features_section.dart';
import '../widgets/how_it_works_section.dart';
import '../widgets/impact_section.dart';
import '../widgets/download_section.dart';
import '../widgets/contact_section.dart';
import '../widgets/faqs_section.dart';
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
  final GlobalKey _faqKey = GlobalKey();
  final GlobalKey _downloadKey = GlobalKey(); 

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
    final scrolled = _scrollController.offset > 50;
    if (scrolled != _isScrolled) {
      setState(() => _isScrolled = scrolled);
    }

    _updateActiveSection();
  }

  void _updateActiveSection() {
    final scrollOffset = _scrollController.offset;
    final screenHeight = MediaQuery.of(context).size.height;
    final homePos = _getSectionPosition(_homeKey);
    final featuresPos = _getSectionPosition(_featuresKey);
    final howItWorksPos = _getSectionPosition(_howItWorksKey);
    final impactPos = _getSectionPosition(_impactKey);
    final faqPos = _getSectionPosition(_faqKey); 
    final downloadPos = _getSectionPosition(_downloadKey);

    final threshold = screenHeight * 0.3;
    final currentPosition = scrollOffset + threshold;

    String newSection = 'home';
    
    // Order matters: check from bottom to top
    if (currentPosition >= faqPos) {
      newSection = 'faq';
    } else if (currentPosition >= downloadPos) { 
      newSection = 'download'; // ✅ CRITICAL FIX: Match breadcrumb ID 'download' (was 'banner')
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
      case 'faq': 
        targetKey = _faqKey;
        break; 
      case 'download':
        targetKey = _downloadKey;
        break;
    }

    if (targetKey?.currentContext != null) {
      final context = targetKey!.currentContext!;
      final box = context.findRenderObject() as RenderBox;
      final position = box.localToGlobal(Offset.zero).dy + _scrollController.offset;
      
      _scrollController.animateTo(
        position - 88,
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOut,
      );
    }
  }

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
          SingleChildScrollView(
            controller: _scrollController,
            child: Column(
              children: [
                const SizedBox(height: 88),
                
                Container(key: _homeKey, child: IntroSection(onGetStarted: _handleGetStarted, onLearnMore: _handleLearnMore)),
                Container(key: _featuresKey, child: FeaturesSection(features: _viewModel.features)),
                Container(key: _howItWorksKey, child: HowItWorksSection(steps: _viewModel.steps)),
                Container(key: _impactKey, child: ImpactSection(stats: _viewModel.impactStats)),
                Container(key: _downloadKey, child: DownloadSection(onDownload: _handleDownload)), // Key matches navigation logic
                Container(key: _faqKey, child: const FaqSection()),
                
                // ✅ FIXED: Only pass onNavigateToSection
                ContactSection(
                  onNavigateToSection: _scrollToSection,
                ),
              ],
            ),
          ),

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