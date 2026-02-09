// lib/ui/mobile_landing_page/views/mobile_landing_page_view.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../widgets/app_header.dart';
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

  static const double _headerHeight = 64;

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

  void _handleLogin() {
    setState(() => _isMenuOpen = false);
    context.go('/login');
  }

  void _handleGetStarted() {
    setState(() => _isMenuOpen = false);
    context.go('/signup');
  }

  void _handleDownload() => context.go('/download');
  void _handleLearnMore() => _scrollToSection('features');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          /// MAIN CONTENT - Scrollable
          SingleChildScrollView(
            controller: _scrollController,
            child: Column(
              children: [
                // Header spacing
                SizedBox(height: _headerHeight),
                
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
                  child: FeaturesSection(features: _viewModel.features),
                ),
                
                // HOW IT WORKS SECTION
                Container(
                  key: _howItWorksKey,
                  child: HowItWorksSection(steps: _viewModel.steps),
                ),
                
                // IMPACT SECTION
                Container(
                  key: _impactKey,
                  child: ImpactSection(stats: _viewModel.impactStats),
                ),
                
                // DOWNLOAD SECTION
                Container(
                  key: _downloadKey,
                  child: DownloadSection(onDownload: _handleDownload),
                ),
                
                // FAQ SECTION
                Container(
                  key: _faqKey,
                  child: const FaqSection(),
                ),
                
                // CONTACT SECTION
                Container(
                  key: _contactKey,
                  child: ContactSection(
                    onNavigateToSection: _scrollToSection,
                  ),
                ),
              ],
            ),
          ),

          /// FIXED HEADER AT TOP
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppHeader(
                  onHomeTap: () {
                    _scrollToSection('home');
                    if (_isMenuOpen) setState(() => _isMenuOpen = false);
                  },
                  onMenuTap: () => setState(() => _isMenuOpen = !_isMenuOpen),
                  isScrolled: _isScrolled,
                ),
                
                /// Menu dropdown with proper constraints and scrolling
                if (_isMenuOpen)
                  _MobileMenu(
                    activeSection: _activeSection,
                    onBreadcrumbTap: _scrollToSection,
                    onLogin: _handleLogin,
                    onGetStarted: _handleGetStarted,
                    onToggleMenu: () => setState(() => _isMenuOpen = false),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MobileMenu extends StatelessWidget {
  final String activeSection;
  final Function(String) onBreadcrumbTap;
  final VoidCallback onLogin;
  final VoidCallback onGetStarted;
  final VoidCallback onToggleMenu;

  const _MobileMenu({
    required this.activeSection,
    required this.onBreadcrumbTap,
    required this.onLogin,
    required this.onGetStarted,
    required this.onToggleMenu,
  });

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    // Maximum height for menu dropdown - leave room for header and some content visibility
    final maxMenuHeight = screenHeight - 120;

    return Material(
      elevation: 8,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: double.infinity,
        // 👈 CRITICAL FIX: Use max height constraint to prevent cropping
        constraints: BoxConstraints(
          maxHeight: maxMenuHeight,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        // 👈 CRITICAL FIX: SingleChildScrollView allows menu to scroll when it exceeds max height
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Navigation Items
              _buildMenuItem('Home', 'home', activeSection, onBreadcrumbTap, onToggleMenu),
              _buildMenuItem('Features', 'features', activeSection, onBreadcrumbTap, onToggleMenu),
              _buildMenuItem('How It Works', 'how-it-works', activeSection, onBreadcrumbTap, onToggleMenu),
              _buildMenuItem('Impact', 'impact', activeSection, onBreadcrumbTap, onToggleMenu),
              _buildMenuItem('Downloads', 'download', activeSection, onBreadcrumbTap, onToggleMenu),
              _buildMenuItem('FAQ', 'faq', activeSection, onBreadcrumbTap, onToggleMenu),
              _buildMenuItem('Contact', 'contact', activeSection, onBreadcrumbTap, onToggleMenu),
              
              const Divider(height: 32, thickness: 1, color: Color(0xFFE5E7EB)),
              
              // Legal Links
              _buildLegalLink(
                context,
                'Privacy Policy',
                () {
                  onToggleMenu();
                  context.go('/privacy-policy');
                },
              ),
              _buildLegalLink(
                context,
                'Terms of Service',
                () {
                  onToggleMenu();
                  context.go('/terms-of-service');
                },
              ),
              
              const SizedBox(height: 24),
              
              // Action Buttons
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton(
                  onPressed: onLogin,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF22C55E),
                    side: const BorderSide(color: Color(0xFF22C55E), width: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Login',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: onGetStarted,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF22C55E),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Get Started',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    String label,
    String id,
    String active,
    Function(String) onTap,
    VoidCallback onToggleMenu,
  ) {
    final isActive = active == id;
    return InkWell(
      onTap: () {
        onTap(id);
        onToggleMenu();
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFFDCFCE7) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
            color: isActive ? const Color(0xFF22C55E) : const Color(0xFF4B5563),
          ),
        ),
      ),
    );
  }

  Widget _buildLegalLink(BuildContext context, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF6B7280),
          ),
        ),
      ),
    );
  }
}