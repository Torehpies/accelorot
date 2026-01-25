import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../view_models/landing_page_view_model.dart';
import '../widgets/app_header.dart';
import '../widgets/intro_section.dart';
import '../widgets/features_section.dart';
import '../widgets/how_it_works_section.dart';
import '../widgets/impact_section.dart';
import '../widgets/cta_section.dart';

class LandingPageView extends StatefulWidget {
  const LandingPageView({super.key});

  @override
  State<LandingPageView> createState() => _LandingPageViewState();
}

class _LandingPageViewState extends State<LandingPageView> {
  late final LandingPageViewModel _viewModel;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _viewModel = LandingPageViewModel();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  // ===================== ACTIONS =====================

  void _onLogin() {
    context.go('/signin');
  }

  void _onGetStarted() {
    context.go('/signup');
  }

  void _onDownload() {
    // TODO: add download logic (PDF / app / brochure)
  }

  void _onBreadcrumbTap(String section) {
    double offset = 0;

    switch (section) {
      case 'features':
        offset = 600;
        break;
      case 'how':
        offset = 1200;
        break;
      case 'impact':
        offset = 1800;
        break;
      default:
        offset = 0;
    }

    _scrollController.animateTo(
      offset,
      duration: const Duration(milliseconds: 700),
      curve: Curves.easeInOut,
    );
  }

  // ===================== UI =====================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          children: [
            /// HEADER
            AppHeader(
              onLogin: _onLogin,
              onGetStarted: _onGetStarted,
              onDownload: _onDownload,
              onBreadcrumbTap: _onBreadcrumbTap,
              activeSection: 'home',
            ),

            /// INTRO
            IntroSection(
              onGetStarted: _onGetStarted,
              onLearnMore: () => _onBreadcrumbTap('features'),
            ),

            /// FEATURES
            FeaturesSection(features: _viewModel.features),

            /// HOW IT WORKS
            HowItWorksSection(steps: _viewModel.steps),

            /// IMPACT
            ImpactSection(stats: _viewModel.impactStats),

            /// CTA
            CtaSection(onGetStarted: _onGetStarted),
          ],
        ),
      ),
    );
  }
}
