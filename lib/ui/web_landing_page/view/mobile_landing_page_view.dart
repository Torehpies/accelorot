// lib/ui/web_landing_page/views/mobile_landing_page_view.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../widgets/intro_section.dart';
import '../widgets/features_section.dart';
import '../widgets/how_it_works_section.dart';
import '../widgets/impact_section.dart';
import '../widgets/banner_section.dart';
import '../widgets/contact_section.dart';
import '../view_models/landing_page_view_model.dart';
import '../../core/themes/web_text_styles.dart';
import '../../core/themes/web_colors.dart';
import '../../core/ui/primary_button.dart';

class MobileLandingPageView extends StatefulWidget {
  const MobileLandingPageView({super.key});

  @override
  State<MobileLandingPageView> createState() => _MobileLandingPageView();
}

class _MobileLandingPageView extends State<MobileLandingPageView> {
  final ScrollController _scrollController = ScrollController();
  final LandingPageViewModel _viewModel = LandingPageViewModel();

  final _homeKey = GlobalKey();
  final _featuresKey = GlobalKey();
  final _howItWorksKey = GlobalKey();
  final _impactKey = GlobalKey();
  final _bannerKey = GlobalKey();
  final _contactKey = GlobalKey();

  String _activeSection = 'home';
  bool _isScrolled = false;
  bool _isMenuOpen = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_handleScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_handleScroll);
    _scrollController.dispose();
    super.dispose();
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

      final box = ctx.findRenderObject() as RenderBox?;
      if (box == null) continue;

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
      // Close menu after navigation
      if (_isMenuOpen) {
        setState(() => _isMenuOpen = false);
      }
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

  // Navigation handlers
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
    _scrollTo(_featuresKey);
  }

  void _toggleMenu() {
    setState(() {
      _isMenuOpen = !_isMenuOpen;
    });
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
                // Add spacing for fixed header
                SizedBox(height: _isMenuOpen ? 480 : 72),

                // HOME SECTION
                Container(
                  key: _homeKey,
                  child: IntroSection(
                    onGetStarted: _handleGetStarted,
                    onLearnMore: _handleLearnMore,
                  ),
                ),

                // FEATURES SECTION
                Container(
                  key: _featuresKey,
                  child: FeaturesSection(
                    features: _viewModel.features,
                  ),
                ),

                // HOW IT WORKS SECTION
                Container(
                  key: _howItWorksKey,
                  child: HowItWorksSection(
                    steps: _viewModel.steps,
                  ),
                ),

                // IMPACT SECTION
                Container(
                  key: _impactKey,
                  child: ImpactSection(
                    stats: _viewModel.impactStats,
                  ),
                ),

                // BANNER SECTION
                Container(
                  key: _bannerKey,
                  child: BannerSection(
                    onGetStarted: _handleGetStarted,
                    onDownload: _handleDownload,
                  ),
                ),

                // CONTACT SECTION
                Container(
                  key: _contactKey,
                  child: ContactSection(
                    onGetStarted: _handleGetStarted,
                    onDownload: _handleDownload,
                    onNavigateToSection: _onBreadcrumbTap,
                  ),
                ),
              ],
            ),
          ),

          /// FIXED MOBILE HEADER WITH INLINE MENU
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: _MobileHeader(
              isScrolled: _isScrolled,
              isMenuOpen: _isMenuOpen,
              activeSection: _activeSection,
              onBreadcrumbTap: _onBreadcrumbTap,
              onLogin: _handleLogin,
              onGetStarted: _handleGetStarted,
              onToggleMenu: _toggleMenu,
            ),
          ),
        ],
      ),
    );
  }
}

class _MobileHeader extends StatelessWidget {
  final bool isScrolled;
  final bool isMenuOpen;
  final String activeSection;
  final Function(String) onBreadcrumbTap;
  final VoidCallback onLogin;
  final VoidCallback onGetStarted;
  final VoidCallback onToggleMenu;

  const _MobileHeader({
    required this.isScrolled,
    required this.isMenuOpen,
    required this.activeSection,
    required this.onBreadcrumbTap,
    required this.onLogin,
    required this.onGetStarted,
    required this.onToggleMenu,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      decoration: BoxDecoration(
        gradient: isScrolled && !isMenuOpen
            ? null
            : const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFE0F2FE),
                  Color(0xFFCCFBF1),
                ],
              ),
        color: isScrolled && !isMenuOpen ? Colors.white : null,
        border: isScrolled && !isMenuOpen
            ? const Border(
                bottom: BorderSide(
                  color: Color(0xFFE5E7EB),
                  width: 1,
                ),
              )
            : null,
        boxShadow: isScrolled && !isMenuOpen
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 16,
                  spreadRadius: 0,
                  offset: const Offset(0, 4),
                ),
              ]
            : [],
      ),
      child: Column(
        children: [
          // Header bar
          Container(
            height: 72,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                /// Logo
                GestureDetector(
                  onTap: () => onBreadcrumbTap('home'),
                  child: Row(
                    children: [
                      SvgPicture.asset(
                        'assets/images/Accel-O-Rot Logo.svg',
                        width: 32,
                        height: 32,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Accel-O-Rot',
                        style: WebTextStyles.h3.copyWith(
                          fontWeight: FontWeight.w800,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                /// Hamburger/Close Menu Icon
                IconButton(
                  icon: Icon(
                    isMenuOpen ? Icons.close : Icons.menu,
                    size: 28,
                  ),
                  onPressed: onToggleMenu,
                  color: const Color(0xFF374151),
                ),
              ],
            ),
          ),

          // Inline menu
          if (isMenuOpen)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(
                    color: const Color(0xFFE5E7EB),
                    width: 1,
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Navigation Items
                  _MenuItem(
                    label: 'Home',
                    id: 'home',
                    active: activeSection,
                    onTap: onBreadcrumbTap,
                  ),
                  const SizedBox(height: 4),
                  _MenuItem(
                    label: 'Features',
                    id: 'features',
                    active: activeSection,
                    onTap: onBreadcrumbTap,
                  ),
                  const SizedBox(height: 4),
                  _MenuItem(
                    label: 'How It Works',
                    id: 'how-it-works',
                    active: activeSection,
                    onTap: onBreadcrumbTap,
                  ),
                  const SizedBox(height: 4),
                  _MenuItem(
                    label: 'Impact',
                    id: 'impact',
                    active: activeSection,
                    onTap: onBreadcrumbTap,
                  ),
                  const SizedBox(height: 4),
                  _MenuItem(
                    label: 'Join Us',
                    id: 'banner',
                    active: activeSection,
                    onTap: onBreadcrumbTap,
                  ),

                  const SizedBox(height: 32),

                  // Action Buttons
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextButton(
                        onPressed: onLogin,
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: Text(
                          'Login',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: WebColors.textBody,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 50,
                        child: PrimaryButton(
                          text: 'Get Started',
                          onPressed: onGetStarted,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final String label;
  final String id;
  final String active;
  final Function(String) onTap;

  const _MenuItem({
    required this.label,
    required this.id,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isActive = active == id;

    return InkWell(
      onTap: () => onTap(id),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        decoration: BoxDecoration(
          color: isActive
              ? WebColors.success.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
            color: isActive
                ? WebColors.success
                : const Color(0xFF374151),
          ),
        ),
      ),
    );
  }
}