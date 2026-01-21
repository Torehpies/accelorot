// lib/ui/landing_page/widgets/landing_page_view.dart

import 'package:flutter/material.dart';
import '../view_models/landing_page_view_model.dart';
import 'package:go_router/go_router.dart';
import 'app_header.dart';
import 'intro_section.dart';
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
  String _currentSection = 'Home';

  @override
  void initState() {
    super.initState();
    _viewModel = LandingPageViewModel();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    final offset = _scrollController.offset;
    String newSection = 'Home';
    
    if (offset > 2200) {
      newSection = 'Get Started';
    } else if (offset > 1600) {
      newSection = 'Impact';
    } else if (offset > 1000) {
      newSection = 'How It Works';
    } else if (offset > 500) {
      newSection = 'Features';
    }
    
    if (newSection != _currentSection) {
      setState(() => _currentSection = newSection);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  // Navigation methods that use context
  
  void _onLogin() {
     context.go('/signin'); // or RoutePath.signin.path
  }

  void _onGetStarted() {
    context.go('/signup');
  }

  void _onLearnMore() {
    // Smooth scroll to features section
    _scrollController.animateTo(
      800, // Approximate position of features section
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeInOut,
    );
  }

  void _scrollToSection(String section) {
    double targetOffset = 0;
    
    switch (section) {
      case 'Home':
        targetOffset = 0;
        break;
      case 'Features':
        targetOffset = 600;
        break;
      case 'How It Works':
        targetOffset = 1100;
        break;
      case 'Impact':
        targetOffset = 1700;
        break;
      case 'Get Started':
        targetOffset = 2300;
        break;
    }
    
    _scrollController.animateTo(
      targetOffset,
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Scrollable content with padding for fixed header
          SingleChildScrollView(
            controller: _scrollController,
            child: Column(
              children: [
                // Spacer for fixed header
                const SizedBox(height: 80),

                // Intro Section
                IntroSection(
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
          
          // Fixed Header with integrated breadcrumbs
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: AppHeader(
              onLogin: _onLogin,
              onGetStarted: _onGetStarted,
              currentSection: _currentSection,
              sections: const ['Home', 'Features', 'How It Works', 'Impact', 'Get Started'],
              onSectionTap: _scrollToSection,
            ),
          ),
        ],
      ),
    );
  }
}