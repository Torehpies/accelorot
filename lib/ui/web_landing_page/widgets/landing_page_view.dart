// lib/ui/landing_page/widgets/landing_page_view.dart

import 'package:flutter/material.dart';
import '../view_models/landing_page_view_model.dart';
import 'app_header.dart';
import 'hero_section.dart';
import 'features_section.dart';
import 'how_it_works_section.dart';
import 'impact_section.dart';
import 'cta_section.dart';

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

  // Navigation methods that use context
  void _onLogin() {
    Navigator.pushNamed(context, '/login');
  }

  void _onGetStarted() {
    Navigator.pushNamed(context, '/signup');
  }

  void _onLearnMore() {
    // Smooth scroll to features section
    _scrollController.animateTo(
      800, // Approximate position of features section
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          children: [
            // Header (Fixed for web)
            AppHeader(
              onLogin: _onLogin,
              onGetStarted: _onGetStarted,
            ),
            
            // Hero Section
            HeroSection(
              onGetStarted: _onGetStarted,
              onLearnMore: _onLearnMore,
            ),
            
            // Features Section
            FeaturesSection(
              features: _viewModel.features,
            ),
            
            // How It Works Section
            HowItWorksSection(
              steps: _viewModel.steps,
            ),
            
            // Impact Section
            ImpactSection(
              stats: _viewModel.impactStats,
            ),
            
            // CTA Section
            CtaSection(
              onGetStarted: _onGetStarted,
            ),
          ],
        ),
      ),
    );
  }
}