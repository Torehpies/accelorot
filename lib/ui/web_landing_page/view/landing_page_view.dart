// lib/ui/web_landing_page/landing_page_view.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';
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
  Timer? _scrollDebounce;

  // Keys for scrollable sections ONLY
  final GlobalKey _homeKey = GlobalKey();
  final GlobalKey _featuresKey = GlobalKey();
  final GlobalKey _howItWorksKey = GlobalKey();
  final GlobalKey _impactKey = GlobalKey();
  final GlobalKey _contactKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _viewModel = LandingPageViewModel();
    _scrollController.addListener(_debouncedUpdate);
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateActiveSection());
  }

  @override
  void dispose() {
    _scrollDebounce?.cancel();
    _scrollController.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  void _debouncedUpdate() {
    _scrollDebounce?.cancel();
    _scrollDebounce = Timer(const Duration(milliseconds: 100), _updateActiveSection);
  }

  void _updateActiveSection() {
    final center = _scrollController.offset + MediaQuery.of(context).size.height / 2;
    final sections = [
      ('home', _homeKey),
      ('features', _featuresKey),
      ('how-it-works', _howItWorksKey),
      ('impact', _impactKey),
      ('contact', _contactKey),
    ];

    String newActive = 'home';
    for (final (name, key) in sections) {
      final bounds = _getBounds(key);
      if (bounds != null && center >= bounds.top && center <= bounds.bottom) {
        newActive = name;
        break;
      }
    }

    if (_activeSection != newActive) {
      setState(() => _activeSection = newActive);
    }
  }

  Rect? _getBounds(GlobalKey key) {
    final context = key.currentContext;
    if (context == null) return null;
    final box = context.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return null;
    final top = box.localToGlobal(Offset.zero).dy;
    final bottom = top + box.size.height;
    return Rect.fromLTWH(0, top, 1, bottom - top);
  }

  void _scrollTo(GlobalKey key) {
    final context = key.currentContext;
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOut,
        alignment: 0.5,
      );
    }
  }

  void _onBreadcrumbTap(String section) {
    setState(() => _activeSection = section);
    switch (section) {
      case 'home': _scrollController.animateTo(0, duration: const Duration(milliseconds: 800), curve: Curves.easeInOut); break;
      case 'features': _scrollTo(_featuresKey); break;
      case 'how-it-works': _scrollTo(_howItWorksKey); break;
      case 'impact': _scrollTo(_impactKey); break;
      case 'contact': _scrollTo(_contactKey); break;
    }
  }

  void _onLogin() => context.go('/signin');
  void _onGetStarted() => context.go('/signup');
  void _onLearnMore() => _scrollTo(_featuresKey);
  void _onDownload() => setState(() => _showDownloadModal = true);
  void _closeDownloadModal() => setState(() => _showDownloadModal = false);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              AppHeader(
                onLogin: _onLogin,
                onGetStarted: _onGetStarted,
                onDownload: _onDownload,
                onBreadcrumbTap: _onBreadcrumbTap,
                activeSection: _activeSection,
              ),
              Expanded(
                child: SingleChildScrollView(
                  controller: _scrollController,
                  child: Column(
                    children: [
                      FadeInOnScroll(child: SizedBox(key: _homeKey, child: IntroSection(onGetStarted: _onGetStarted, onLearnMore: _onLearnMore))),
                      FadeInOnScroll(child: SizedBox(key: _featuresKey, child: FeaturesSection(features: _viewModel.features))),
                      FadeInOnScroll(child: SizedBox(key: _howItWorksKey, child: HowItWorksSection(steps: _viewModel.steps))),
                      FadeInOnScroll(child: SizedBox(key: _impactKey, child: ImpactSection(stats: _viewModel.impactStats))),
                      FadeInOnScroll(child: SizedBox(key: _contactKey, child: const ContactSection())),
                      // CTA is NOT part of breadcrumbs
                      FadeInOnScroll(child: CtaSection(onGetStarted: _onGetStarted, onDownload: _onDownload)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          if (_showDownloadModal) DownloadModal(onClose: _closeDownloadModal),
        ],
      ),
    );
  }
}