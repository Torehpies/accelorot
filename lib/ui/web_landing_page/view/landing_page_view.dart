// lib/ui/web_landing_page/view/landing_page_view.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../view_models/landing_page_view_model.dart';
import '../widgets/app_header.dart';
import '../widgets/intro_section.dart';
import '../widgets/features_section.dart';
import '../widgets/contact_section.dart';
import '../widgets/how_it_works_section.dart';
import '../widgets/impact_section.dart';
import '../widgets/download_modal.dart';
import '../widgets/fade_in_on_scroll.dart';

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

  // Keys for scrollable sections
  final GlobalKey _homeKey = GlobalKey();
  final GlobalKey _featuresKey = GlobalKey();
  final GlobalKey _howItWorksKey = GlobalKey();
  final GlobalKey _impactKey = GlobalKey();
  final GlobalKey _contactKey = GlobalKey();

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
    if (!mounted) return;

    final scrollOffset = _scrollController.offset;

    // Define scroll positions for each section
    // Adjust these based on your actual section heights
    String newActive = 'home';

    if (scrollOffset >= 4000) {
      newActive = 'contact';
    } else if (scrollOffset >= 3000) {
      newActive = 'impact';
    } else if (scrollOffset >= 1900) {
      newActive = 'how-it-works';
    } else if (scrollOffset >= 900) {
      newActive = 'features';
    } else {
      newActive = 'home';
    }

    if (_activeSection != newActive) {
      setState(() => _activeSection = newActive);
    }
  }

  void _scrollToSection(GlobalKey key) {
    final context = key.currentContext;
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOut,
        alignment: 0.0,
      );
    }
  }

  void _onBreadcrumbTap(String section) {
    if (mounted) {
      setState(() => _activeSection = section);
    }

    switch (section) {
      case 'home':
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOut,
        );
        break;
      case 'features':
        _scrollToSection(_featuresKey);
        break;
      case 'how-it-works':
        _scrollToSection(_howItWorksKey);
        break;
      case 'impact':
        _scrollToSection(_impactKey);
        break;
      case 'contact':
        _scrollToSection(_contactKey);
        break;
    }
  }

  void _onLogin() {
    context.go('/signin');
  }

  void _onGetStarted() {
    context.go('/signup');
  }

  void _onLearnMore() {
    _scrollToSection(_featuresKey);
  }

  void _onDownload() {
    if (mounted) {
      setState(() => _showDownloadModal = true);
    }
  }

  void _closeDownloadModal() {
    if (mounted) {
      setState(() => _showDownloadModal = false);
    }
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
                onDownload: _onDownload,
                onBreadcrumbTap: _onBreadcrumbTap,
                activeSection: _activeSection,
              ),
              // Scrollable Content
              Expanded(
                child: SingleChildScrollView(
                  controller: _scrollController,
                  child: Column(
                    children: [
                      // Home Section
                      FadeInOnScroll(
                        child: SizedBox(
                          key: _homeKey,
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
                      // CTA Section (not in breadcrumbs)
                      FadeInOnScroll(
                        child: CtaSection(
                          onGetStarted: _onGetStarted,
                          onDownload: _onDownload,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          // Download Modal
          if (_showDownloadModal)
            DownloadModal(
              onClose: _closeDownloadModal,
            ),
        ],
      ),
    );
  }
}