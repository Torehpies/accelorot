import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../view_models/landing_page_view_model.dart';
import '../widgets/app_header.dart';
import '../widgets/intro_section.dart';
import '../widgets/features_section.dart';
import '../widgets/how_it_works_section.dart';
import '../widgets/impact_section.dart';
import '../widgets/cta_section.dart';
import '../widgets/download_modal.dart';
import '../widgets/fade_in_on_scroll.dart';
import '../widgets/contact_section.dart';

class LandingPageView extends StatefulWidget {
  const LandingPageView({super.key});

  @override
  State<LandingPageView> createState() => _LandingPageViewState();
}

class _LandingPageViewState extends State<LandingPageView> {
  late final LandingPageViewModel _viewModel;
  final ScrollController _scrollController = ScrollController();
  bool _showDownloadModal = false;
  String _activeSection = 'home';

  // Section keys for scroll-to-view
  final GlobalKey _introKey = GlobalKey();
  final GlobalKey _featuresKey = GlobalKey();
  final GlobalKey _howItWorksKey = GlobalKey();
  final GlobalKey _impactKey = GlobalKey();
  final GlobalKey _contactKey = GlobalKey();
  final GlobalKey _ctaKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _viewModel = LandingPageViewModel();
    _scrollController.addListener(_updateActiveSection);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_updateActiveSection);
    _scrollController.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  void _updateActiveSection() {
    // Get the positions of each section
    final introPos = _getKeyPosition(_introKey);
    final featuresPos = _getKeyPosition(_featuresKey);
    final howItWorksPos = _getKeyPosition(_howItWorksKey);
    final impactPos = _getKeyPosition(_impactKey);
    final contactPos = _getKeyPosition(_contactKey);
    final ctaPos = _getKeyPosition(_ctaKey);

    final scrollPosition = _scrollController.offset;
    final centerViewport = scrollPosition + MediaQuery.of(context).size.height / 2;

    String newSection = 'home';

    if (centerViewport >= ctaPos) {
      newSection = 'cta';
    } else if (centerViewport >= contactPos) {
      newSection = 'contact';
    } else if (centerViewport >= impactPos) {
      newSection = 'impact';
    } else if (centerViewport >= howItWorksPos) {
      newSection = 'how-it-works';
    } else if (centerViewport >= featuresPos) {
      newSection = 'features';
    } else if (centerViewport >= introPos) {
      newSection = 'home';
    }

    if (_activeSection != newSection) {
      setState(() => _activeSection = newSection);
    }
  }

  double _getKeyPosition(GlobalKey key) {
    final context = key.currentContext;
    if (context != null) {
      final box = context.findRenderObject() as RenderBox?;
      if (box != null) {
        return box.localToGlobal(Offset.zero).dy;
      }
    }
    return 0;
  }

  void _onBreadcrumbTap(String section) {
    setState(() => _activeSection = section);

    switch (section) {
      case 'home':
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOut,
        );
        break;
      case 'features':
        _scrollToKey(_featuresKey);
        break;
      case 'how-it-works':
        _scrollToKey(_howItWorksKey);
        break;
      case 'impact':
        _scrollToKey(_impactKey);
        break;
      case 'contact':
        _scrollToKey(_contactKey);
        break;
      case 'cta':
        _scrollToKey(_ctaKey);
        break;
      case 'download':
        setState(() => _showDownloadModal = true);
        break;
    }
  }

  void _scrollToKey(GlobalKey key) {
    final context = key.currentContext;
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOut,
        alignment: 0.1,
      );
    }
  }

  void _onLogin() {
    context.go('/signin');
  }

  void _onGetStarted() {
    context.go('/signup');
  }

  void _onLearnMore() {
    _scrollToKey(_featuresKey);
  }

  void _closeDownloadModal() {
    setState(() {
      _showDownloadModal = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              // Fixed Header
              AppHeader(
                onLogin: _onLogin,
                onGetStarted: _onGetStarted,
                onDownload: () => _onBreadcrumbTap('download'),
                onBreadcrumbTap: _onBreadcrumbTap,
                activeSection: _activeSection,
              ),
              // Scrollable Content
              Expanded(
                child: SingleChildScrollView(
                  controller: _scrollController,
                  child: Column(
                    children: [
                      // Intro Section - Home
                      FadeInOnScroll(
                        child: SizedBox(
                          key: _introKey,
                          child: IntroSection(
                            onGetStarted: _onGetStarted,
                            onLearnMore: _onLearnMore,
                          ),
                        ),
                      ),
                      // Features Section
                      FadeInOnScroll(
                        child: SizedBox(
                          key: _featuresKey,
                          child: FeaturesSection(
                            features: _viewModel.features,
                          ),
                        ),
                      ),
                      // How It Works Section
                      FadeInOnScroll(
                        child: SizedBox(
                          key: _howItWorksKey,
                          child: HowItWorksSection(
                            steps: _viewModel.steps,
                          ),
                        ),
                      ),
                      // Impact Section
                      FadeInOnScroll(
                        child: SizedBox(
                          key: _impactKey,
                          child: ImpactSection(
                            stats: _viewModel.impactStats,
                          ),
                        ),
                      ),
                      // Contact Section
                      FadeInOnScroll(
                        child: SizedBox(
                          key: _contactKey,
                          child: const ContactSection(),
                        ),
                      ),
                      // CTA Section
                      FadeInOnScroll(
                      child: SizedBox(
                        key: _ctaKey,
                        child: CtaSection(
                          onGetStarted: _onGetStarted,
                          onDownload: () => _onBreadcrumbTap('download'),
                        ),
                      ),
                    ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          if (_showDownloadModal)
            DownloadModal(
              onClose: _closeDownloadModal,
            ),
        ],
      ),
    );
  }
}