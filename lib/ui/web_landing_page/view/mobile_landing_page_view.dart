// lib/ui/web_landing_page/views/mobile_landing_page_view.dart

import 'package:flutter/material.dart';
import '../widgets/app_header.dart';
import '../widgets/banner_section.dart';
import '../widgets/contact_section.dart';

class MobileLandingPageView extends StatefulWidget {
  const MobileLandingPageView({super.key});

  @override
  State<MobileLandingPageView> createState() => _MobileLandingPageView();
}

class _MobileLandingPageView extends State<MobileLandingPageView> {
  final ScrollController _scrollController = ScrollController();

  final _homeKey = GlobalKey();
  final _featuresKey = GlobalKey();
  final _howItWorksKey = GlobalKey();
  final _impactKey = GlobalKey();
  final _bannerKey = GlobalKey();
  final _contactKey = GlobalKey();

  String _activeSection = 'home';
  bool _isScrolled = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_handleScroll);
  }

  void _handleScroll() {
    setState(() {
      _isScrolled = _scrollController.offset > 20;
    });
    _updateActiveSection();
  }

  void _updateActiveSection() {
    final sections = {
      'home': _homeKey,
      'features': _featuresKey,
      'how-it-works': _howItWorksKey,
      'impact': _impactKey,
      'banner': _bannerKey,
      'contact': _contactKey,
    };

    for (final entry in sections.entries) {
      final ctx = entry.value.currentContext;
      if (ctx == null) continue;

      final box = ctx.findRenderObject() as RenderBox;
      final offset = box.localToGlobal(Offset.zero).dy;

      if (offset <= 140 && offset >= -200) {
        if (_activeSection != entry.key) {
          setState(() => _activeSection = entry.key);
        }
        break;
      }
    }
  }

  void _scrollTo(GlobalKey key) {
    final context = key.currentContext;
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 700),
        curve: Curves.easeInOut,
      );
    }
  }

  void _onBreadcrumbTap(String section) {
    switch (section) {
      case 'home':
        _scrollTo(_homeKey);
        break;
      case 'features':
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          /// PAGE CONTENT
          SingleChildScrollView(
            controller: _scrollController,
            child: Column(
              children: [
                const SizedBox(height: 96),

                Container(key: _homeKey, height: 600, color: Colors.transparent),

                Container(
                  key: _featuresKey,
                  height: 600,
                  color: const Color(0xFFF8FAFC),
                ),

                Container(
                  key: _howItWorksKey,
                  height: 600,
                  color: Colors.white,
                ),

                Container(
                  key: _impactKey,
                  height: 600,
                  color: const Color(0xFFF1F5F9),
                ),

                Container(
                  key: _bannerKey,
                  child: BannerSection(
                    onGetStarted: () {},
                    onDownload: () {},
                  ),
                ),

                Container(
                  key: _contactKey,
                  child: ContactSection(
                    onGetStarted: () {},
                  ),
                ),
              ],
            ),
          ),

          /// FIXED HEADER
          AppHeader(
            isScrolled: _isScrolled,
            activeSection: _activeSection,
            onBreadcrumbTap: _onBreadcrumbTap,
            onLogin: () {},
            onGetStarted: () {},
            onDownload: () {},
          ),
        ],
      ),
    );
  }
}
