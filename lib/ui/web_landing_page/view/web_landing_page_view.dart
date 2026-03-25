// lib/ui/web_landing_page/views/web_landing_page_view.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/web_header.dart';
import '../widgets/intro_section.dart';
import '../widgets/features_section.dart';
import '../widgets/how_it_works_section.dart';
import '../widgets/impact_section.dart';
import '../widgets/download_section.dart';
import '../widgets/contact_section.dart';
import '../widgets/faqs_section.dart';
import '../view_models/landing_page_view_model.dart';
import '../../../utils/url_updater.dart';

class WebLandingPageView extends StatefulWidget {
  final String? initialSection;

  const WebLandingPageView({super.key, this.initialSection});

  @override
  State<WebLandingPageView> createState() => _WebLandingPageState();
}

class _WebLandingPageState extends State<WebLandingPageView> {
  final ScrollController _scrollController = ScrollController();
  final LandingPageViewModel _viewModel = LandingPageViewModel();

  static const double _headerHeight = 72.0;
  static const double _headerSpacer = 80.0; 

  final GlobalKey _homeKey = GlobalKey();
  final GlobalKey _featuresKey = GlobalKey();
  final GlobalKey _howItWorksKey = GlobalKey();
  final GlobalKey _impactKey = GlobalKey();
  final GlobalKey _downloadKey = GlobalKey();
  final GlobalKey _faqKey = GlobalKey();
  final GlobalKey _contactKey = GlobalKey();

  String _activeSection = 'home';
  bool _isScrolled = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final target =
          widget.initialSection ?? getInitialSectionFromUrl();
      if (target != null && target != 'home') {
        _scrollToSection(target);
      }
    });
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
    final downloadPos = _getSectionPosition(_downloadKey);
    final faqPos = _getSectionPosition(_faqKey);
    final contactPos = _getSectionPosition(_contactKey);

    final threshold = screenHeight * 0.35;
    final currentPosition = scrollOffset + threshold;

    String newSection = 'home';

    if (currentPosition >= contactPos) {
      newSection = 'contact';
    } else if (currentPosition >= faqPos) {
      newSection = 'faq';
    } else if (currentPosition >= downloadPos) {
      newSection = 'download';
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
      updateLandingPageUrl(newSection);
    }
  }

  double _getSectionPosition(GlobalKey key) {
    final ctx = key.currentContext;
    if (ctx == null) return 0;
    final box = ctx.findRenderObject() as RenderBox?;
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
      case 'download':
        targetKey = _downloadKey;
        break;
      case 'faq':
        targetKey = _faqKey;
        break;
      case 'contact':
        targetKey = _contactKey;
        break;
    }

    if (targetKey?.currentContext != null) {
      final ctx = targetKey!.currentContext!;
      final box = ctx.findRenderObject() as RenderBox;
      // Document-level position of the section top
      final docPosition =
          box.localToGlobal(Offset.zero).dy + _scrollController.offset;
      // Scroll so the section sits just below the fixed header
      final target = (docPosition - _headerHeight).clamp(
        0.0,
        _scrollController.position.maxScrollExtent,
      );

      _scrollController.animateTo(
        target,
        duration: const Duration(milliseconds: 750),
        curve: Curves.easeInOut,
      );

      updateLandingPageUrl(sectionId);
    }
  }

  void _handleLogin() => context.go('/login');
  void _handleGetStarted() => context.go('/signup');
  void _handleDownload() => context.go('/download');
  void _handleLearnMore() => _scrollToSection('features');

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
                SizedBox(height: _headerSpacer),

                Container(
                  key: _homeKey,
                  child: IntroSection(
                    onGetStarted: _handleGetStarted,
                    onLearnMore: _handleLearnMore,
                  ),
                ),
                Container(
                  key: _featuresKey,
                  child: FeaturesSection(features: _viewModel.features),
                ),
                Container(
                  key: _howItWorksKey,
                  child: HowItWorksSection(steps: _viewModel.steps),
                ),
                Container(
                  key: _impactKey,
                  child: ImpactSection(stats: _viewModel.impactStats),
                ),
                Container(
                  key: _downloadKey,
                  child: DownloadSection(onDownload: _handleDownload),
                ),
                Container(
                  key: _faqKey,
                  child: const FaqSection(),
                ),
                Container(
                  key: _contactKey,
                  child: ContactSection(
                    onNavigateToSection: _scrollToSection,
                    onBackToTop: () => _scrollToSection('home'),
                    showBackToTop: _isScrolled,
                  ),
                ),
              ],
            ),
          ),

          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: WebHeader(
              onLogin: _handleLogin,
              onGetStarted: _handleGetStarted,
              onDownload: _handleDownload,
              onBreadcrumbTap: _scrollToSection,
              activeSection: _activeSection,
              isScrolled: _isScrolled,
              showActions: true,
            ),
          ),
        ],
      ),
    );
  }
}
