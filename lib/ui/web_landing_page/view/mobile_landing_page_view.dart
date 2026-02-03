import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../widgets/intro_section.dart';
import '../widgets/features_section.dart';
import '../widgets/how_it_works_section.dart';
import '../widgets/impact_section.dart';
import '../widgets/download_section.dart';
import '../widgets/contact_section.dart';
import '../widgets/faqs_section.dart';
import '../view_models/landing_page_view_model.dart';

class MobileLandingPageView extends StatefulWidget {
  const MobileLandingPageView({super.key});

  @override
  State<MobileLandingPageView> createState() => _MobileLandingPageViewState();
}

class _MobileLandingPageViewState extends State<MobileLandingPageView> {
  final ScrollController _scrollController = ScrollController();
  final LandingPageViewModel _viewModel = LandingPageViewModel();

  static const double _headerHeight = 72;

  final _homeKey = GlobalKey();
  final _featuresKey = GlobalKey();
  final _howItWorksKey = GlobalKey();
  final _impactKey = GlobalKey();
  final _downloadKey = GlobalKey();
  final _faqKey = GlobalKey();
  final _contactKey = GlobalKey();

  String _activeSection = 'home';
  bool _isScrolled = false;
  bool _isMenuOpen = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
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
      'download': _downloadKey,
      'faq': _faqKey,
      'contact': _contactKey,
    };

    for (final entry in sections.entries) {
      final context = entry.value.currentContext;
      if (context == null) continue;

      final box = context.findRenderObject() as RenderBox?;
      if (box == null) continue;

      final offset = box.localToGlobal(Offset.zero).dy;

      if (offset <= _headerHeight + 40 && offset >= -200) {
        if (_activeSection != entry.key) {
          setState(() => _activeSection = entry.key);
        }
        break;
      }
    }
  }

  void _scrollToSection(String sectionId) {
    final sectionMap = {
      'home': _homeKey,
      'features': _featuresKey,
      'how-it-works': _howItWorksKey,
      'impact': _impactKey,
      'download': _downloadKey,
      'faq': _faqKey,
      'contact': _contactKey,
    };

    final key = sectionMap[sectionId];
    if (key?.currentContext == null) return;

    setState(() {
      _activeSection = sectionId;
      _isMenuOpen = false;
    });

    Scrollable.ensureVisible(
      key!.currentContext!,
      duration: const Duration(milliseconds: 650),
      curve: Curves.easeInOut,
      alignment: 0,
    );
  }

  void _handleLogin() => context.go('/login');
  void _handleGetStarted() => context.go('/signup');
  void _handleDownload() => context.go('/download');
  void _handleLearnMore() => _scrollToSection('features');

  Widget _section({required Key key, required Widget child}) {
    return Padding(
      key: key,
      padding: const EdgeInsets.only(top: _headerHeight),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          /// CONTENT
          SingleChildScrollView(
            controller: _scrollController,
            child: Column(
              children: [
                _section(
                  key: _homeKey,
                  child: IntroSection(
                    onGetStarted: _handleGetStarted,
                    onLearnMore: _handleLearnMore,
                  ),
                ),
                _section(
                  key: _featuresKey,
                  child: FeaturesSection(features: _viewModel.features),
                ),
                _section(
                  key: _howItWorksKey,
                  child: HowItWorksSection(steps: _viewModel.steps),
                ),
                _section(
                  key: _impactKey,
                  child: ImpactSection(stats: _viewModel.impactStats),
                ),
                _section(
                  key: _downloadKey,
                  child: DownloadSection(onDownload: _handleDownload),
                ),
                _section(
                  key: _faqKey,
                  child: const FaqSection(),
                ),
                _section(
                  key: _contactKey,
                  child: ContactSection(
                    onNavigateToSection: _scrollToSection,
                  ),
                ),
              ],
            ),
          ),

          /// HEADER
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: _MobileHeader(
              isScrolled: _isScrolled,
              isMenuOpen: _isMenuOpen,
              activeSection: _activeSection,
              onBreadcrumbTap: _scrollToSection,
              onLogin: _handleLogin,
              onGetStarted: _handleGetStarted,
              onToggleMenu: () =>
                  setState(() => _isMenuOpen = !_isMenuOpen),
            ),
          ),
        ],
      ),
    );
  }
}


class _MobileHeader extends StatefulWidget {
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
  State<_MobileHeader> createState() => _MobileHeaderState();
}

class _MobileHeaderState extends State<_MobileHeader> {
  bool _isLogoHovered = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      decoration: BoxDecoration(
        color: widget.isScrolled && !widget.isMenuOpen ? Colors.white : null,
        gradient: widget.isScrolled && !widget.isMenuOpen
            ? null
            : const LinearGradient(
                colors: [Color(0xFFE0F2FE), Color(0xFFCCFBF1)],
              ),
        boxShadow: widget.isScrolled && !widget.isMenuOpen
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                )
              ]
            : [],
      ),
      child: Column(
        children: [
          Container(
            height: 72,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  onEnter: (_) => setState(() => _isLogoHovered = true),
                  onExit: (_) => setState(() => _isLogoHovered = false),
                  child: GestureDetector(
                    onTap: () => widget.onBreadcrumbTap('home'),
                    child: AnimatedScale(
                      duration: const Duration(milliseconds: 200),
                      scale: _isLogoHovered ? 1.05 : 1.0,
                      child: Row(
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            child: SvgPicture.asset(
                              'assets/images/accel-o-rot.svg', // ✅ CHANGED FILENAME
                              width: 32,
                              height: 32,
                            ),
                          ),
                          const SizedBox(width: 8),
                          AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 200),
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: _isLogoHovered 
                                  ? Colors.green 
                                  : Colors.green,
                            ),
                            child: const Text('Accel-O-Rot'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: Icon(widget.isMenuOpen ? Icons.close : Icons.menu),
                  onPressed: widget.onToggleMenu,
                ),
              ],
            ),
          ),

          if (widget.isMenuOpen)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _MenuItem('Home', 'home', widget.activeSection, widget.onBreadcrumbTap),
                  _MenuItem('Features', 'features', widget.activeSection, widget.onBreadcrumbTap),
                  _MenuItem('How It Works', 'how-it-works', widget.activeSection, widget.onBreadcrumbTap),
                  _MenuItem('Impact', 'impact', widget.activeSection, widget.onBreadcrumbTap),
                  _MenuItem('Downloads', 'download', widget.activeSection, widget.onBreadcrumbTap),
                  _MenuItem('FAQ', 'faq', widget.activeSection, widget.onBreadcrumbTap),
                  _MenuItem('Contact', 'contact', widget.activeSection, widget.onBreadcrumbTap),
                  const SizedBox(height: 24),
                  TextButton(onPressed: widget.onLogin, child: const Text('Login')),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: widget.onGetStarted,
                    child: const Text('Get Started'),
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

  const _MenuItem(this.label, this.id, this.active, this.onTap);

  @override
  Widget build(BuildContext context) {
    final isActive = active == id;

    return InkWell(
      onTap: () => onTap(id),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(
          color: isActive ? Colors.green.withValues(alpha: 0.1) : null,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
            color: isActive ? Colors.green : const Color(0xFF374151),
          ),
        ),
      ),
    );
  }
}