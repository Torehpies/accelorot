// lib/ui/web_landing_page/view/landing_page_view.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../view_models/landing_page_view_model.dart';
import '../widgets/app_header.dart';
import '../widgets/intro_section.dart';
import '../widgets/features_section.dart';
import '../widgets/how_it_works_section.dart';
import '../widgets/impact_section.dart';
import '../widgets/banner_section.dart'; 
import '../widgets/contact_section.dart';
import '../widgets/fade_in_on_scroll.dart';

class LandingPageView extends StatefulWidget {
  const LandingPageView({super.key});

  @override
  State<LandingPageView> createState() => _LandingPageViewState();
}

class _LandingPageViewState extends State<LandingPageView> {
  late final LandingPageViewModel _viewModel;
  final ScrollController _scrollController = ScrollController();

  bool _isScrolled = false;
  String _activeSection = 'home';

  // SECTION KEYS
  final GlobalKey _homeKey = GlobalKey();
  final GlobalKey<FeaturesSectionState> _featuresKey =
      GlobalKey<FeaturesSectionState>();
  final GlobalKey _howItWorksKey = GlobalKey();
  final GlobalKey _impactKey = GlobalKey();
  final GlobalKey _bannerKey = GlobalKey();
  final GlobalKey _contactKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _viewModel = LandingPageViewModel();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final offset = _scrollController.offset;

    final scrolled = offset > 8;
    if (_isScrolled != scrolled) {
      setState(() => _isScrolled = scrolled);
    }

    String section = 'home';
    if (offset >= 4600) {
      section = 'contact';
    } else if (offset >= 3600) {
      section = 'banner';
    } else if (offset >= 3000) {
      section = 'impact';
    } else if (offset >= 1900) {
      section = 'how-it-works';
    } else if (offset >= 900) {
      section = 'features';
    }

    if (_activeSection != section) {
      setState(() => _activeSection = section);
    }
  }

  void _scrollTo(GlobalKey key) {
    final context = key.currentContext;
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 900),
        curve: Curves.easeInOut,
        alignment: 0.08,
      );
    }
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
        _featuresKey.currentState?.resetCarousel();
        _scrollTo(_featuresKey);
        break;

      case 'how-it-works':
        _scrollTo(_howItWorksKey);
        break;

      case 'impact':
        _scrollTo(_impactKey);
        break;

      case 'banner':
        _scrollTo(_bannerKey);
        break;

      case 'contact':
        _scrollTo(_contactKey);
        break;
    }
  }

  void _navigateToDownloadApp(BuildContext context) {
    // Option 1: Use named route (recommended if you have /download defined)
    context.go('/download');

    // Option 2: Push directly (if you don't want to define a route)
    // Navigator.of(context).push(
    //   MaterialPageRoute(builder: (_) => const DownloadAppPage()),
    // );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          AppHeader(
            onLogin: () => context.go('/signin'),
            onGetStarted: () => context.go('/signup'),
            onDownload: () => _navigateToDownloadApp(context),
            onBreadcrumbTap: _onBreadcrumbTap,
            activeSection: _activeSection,
            isScrolled: _isScrolled,
          ),
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              child: Column(
                children: [
                  FadeInOnScroll(
                    child: SizedBox(
                      key: _homeKey,
                      child: IntroSection(
                        onGetStarted: () => context.go('/signup'),
                        onLearnMore: () => _scrollTo(_featuresKey),
                      ),
                    ),
                  ),
                  FadeInOnScroll(
                    child: FeaturesSection(
                      key: _featuresKey,
                      features: _viewModel.features,
                    ),
                  ),
                  FadeInOnScroll(
                    child: SizedBox(
                      key: _howItWorksKey,
                      child: HowItWorksSection(
                        steps: _viewModel.steps,
                      ),
                    ),
                  ),
                  FadeInOnScroll(
                    child: SizedBox(
                      key: _impactKey,
                      child: ImpactSection(
                        stats: _viewModel.impactStats,
                      ),
                    ),
                  ),
                  FadeInOnScroll(
                    child: SizedBox(
                      key: _bannerKey,
                      child: BannerSection(
                        onGetStarted: () => context.go('/signup'),
                        onDownload: () => _navigateToDownloadApp(context),
                      ),
                    ),
                  ),
                  FadeInOnScroll(
                    child: SizedBox(
                      key: _contactKey,
                      child: ContactSection(
                        onGetStarted: () => context.go('/signup'),
                        onDownload: () => _navigateToDownloadApp(context),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}