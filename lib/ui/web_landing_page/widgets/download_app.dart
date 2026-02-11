// lib/ui/web_landing_page/views/download_app.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/ui/primary_button.dart';
import 'app_header.dart';
import 'web_header.dart';

class AppSpacing {
  static const double xs = 8.0;
  static const double sm = 12.0;
  static const double md = 16.0;
  static const double xl = 24.0;
  static const double lg = 20.0;
  static const double xxxl = 48.0;
}

class DownloadApp extends StatefulWidget {
  const DownloadApp({super.key});

  @override
  State<DownloadApp> createState() => _DownloadAppState();
}

class _DownloadAppState extends State<DownloadApp> with TickerProviderStateMixin {
  bool _isMenuOpen = false;
  late PageController _carouselController;
  late AnimationController _autoPlayController;
  int _currentCarouselIndex = 0;

  final List<String> carouselImages = [
    'assets/images/phone/7.png',
    'assets/images/phone/8.png',
    'assets/images/phone/9.png',
    'assets/images/phone/10.png',
    'assets/images/phone/11.png',
    'assets/images/phone/12.png',
    'assets/images/phone/13.png',
    'assets/images/phone/14.png',
  ];

  @override
  void initState() {
    super.initState();
    _carouselController = PageController(
      initialPage: 0,
      viewportFraction: 0.95,
    );
    
    _autoPlayController = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    )..repeat();
    
    _setupAutoPlay();
  }

  void _setupAutoPlay() {
    _autoPlayController.addListener(() {
      if (_autoPlayController.isCompleted) {
        _nextCarouselPage();
        _autoPlayController.reset();
        _autoPlayController.forward();
      }
    });
  }

  void _nextCarouselPage() {
    if (_carouselController.hasClients) {
      _carouselController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousCarouselPage() {
    if (_carouselController.hasClients) {
      _carouselController.previousPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void dispose() {
    _carouselController.dispose();
    _autoPlayController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 900;
    
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: Image.asset(
              'assets/images/bg.png',
              fit: BoxFit.cover,
              cacheHeight: 1000,
              cacheWidth: 1000,
              colorBlendMode: BlendMode.modulate,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        const Color(0xFF22C55E).withValues(alpha: 0.1),
                        const Color(0xFF16A34A).withValues(alpha: 0.15),
                      ],
                    ),
                  )
                );
              },
            ),
          ),
          // Main content with responsive layout
          SafeArea(
            child: Column(
              children: [
                // Conditional header based on screen size
                if (isMobile)
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AppHeader(
                        onHomeTap: () {
                          setState(() => _isMenuOpen = false);
                          context.go('/');
                        },
                        onMenuTap: () => setState(() => _isMenuOpen = !_isMenuOpen),
                        isScrolled: true,
                      ),
                      // Menu dropdown
                      if (_isMenuOpen)
                        _MobileMenu(
                          onLogin: () {
                            setState(() => _isMenuOpen = false);
                            context.go('/login');
                          },
                          onGetStarted: () {
                            setState(() => _isMenuOpen = false);
                            context.go('/signup');
                          },
                          onNavigateHome: () {
                            setState(() => _isMenuOpen = false);
                            context.go('/');
                          },
                          onToggleMenu: () => setState(() => _isMenuOpen = false),
                        ),
                    ],
                  )
                else
                  WebHeader(
                    onBreadcrumbTap: (section) {
                      context.go('/');
                    },
                    onLogin: () {
                      context.go('/login');
                    },
                    onGetStarted: () {
                      context.go('/signup');
                    },
                    activeSection: 'download',
                    isScrolled: true,
                    showActions: true,
                  ),
                // Main content area - responsive layout
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final isMobile = constraints.maxWidth < 900;
                      
                      if (isMobile) {
                        // Mobile layout - content on top, carousel below
                        return ScrollConfiguration(
                          behavior: ScrollConfiguration.of(context).copyWith(
                            scrollbars: false,
                          ),
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                // Mobile content on top
                                _buildMobileContentSection(constraints),
                                // Mobile carousel below
                                _buildMobileCarousel(constraints),
                              ],
                            ),
                          ),
                        );
                      } else {
                        // Desktop layout - carousel on left, content on right
                        return Row(
                          children: [
                            // Left side - Carousel
                            Expanded(
                              flex: 1,
                              child: _buildDesktopCarousel(constraints),
                            ),
                            // Right side - Content
                            Expanded(
                              flex: 1,
                              child: _buildDesktopContentSection(constraints),
                            ),
                          ],
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
          // Image courtesy credit - bottom right
          Positioned(
            bottom: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Image courtesy of A1 Organics',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopCarousel(BoxConstraints constraints) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xxxl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Carousel container with shadow effect
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF22C55E).withValues(alpha: 0.3),
                    blurRadius: 40,
                    spreadRadius: 2,
                  ),
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Stack(
                  children: [
                    // Carousel pages
                    PageView.builder(
                      controller: _carouselController,
                      onPageChanged: (index) {
                        setState(() => _currentCarouselIndex = index);
                        _autoPlayController.reset();
                        _autoPlayController.forward();
                      },
                      itemCount: carouselImages.length,
                      itemBuilder: (context, index) {
                        return _buildCarouselItem(carouselImages[index]);
                      },
                    ),
                    // Gradient overlay for depth
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withValues(alpha: 0.1),
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.15),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          // Navigation controls
          _buildCarouselControls(),
        ],
      ),
    );
  }

  Widget _buildMobileCarousel(BoxConstraints constraints) {
    return Container(
      height: 500,
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg, horizontal: AppSpacing.sm),
      child: Column(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: PageView.builder(
                controller: _carouselController,
                onPageChanged: (index) {
                  setState(() => _currentCarouselIndex = index);
                  _autoPlayController.reset();
                  _autoPlayController.forward();
                },
                itemCount: carouselImages.length,
                itemBuilder: (context, index) {
                  return _buildCarouselItem(carouselImages[index]);
                },
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          _buildCarouselControls(),
        ],
      ),
    );
  }

  Widget _buildCarouselItem(String imagePath) {
    return Container(
      color: Colors.white.withValues(alpha: 0.05),
      child: Center(
        child: Hero(
          tag: imagePath,
          child: Image.asset(
            imagePath,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: Colors.grey.withValues(alpha: 0.2),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.image_not_supported_outlined,
                        color: Colors.white.withValues(alpha: 0.5),
                        size: 48,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Image not found',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.5),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildCarouselControls() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Previous button
          _buildNavButton(
            icon: Icons.chevron_left,
            onPressed: _previousCarouselPage,
          ),
          // Indicator dots
          Expanded(
            child: Center(
              child: ScrollConfiguration(
                behavior: ScrollConfiguration.of(context).copyWith(
                  scrollbars: false,
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(
                      carouselImages.length,
                      (index) => GestureDetector(
                        onTap: () {
                          _carouselController.animateToPage(
                            index,
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.easeInOut,
                          );
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          height: 8,
                          width: _currentCarouselIndex == index ? 24 : 8,
                          decoration: BoxDecoration(
                            color: _currentCarouselIndex == index
                                ? const Color(0xFF22C55E)
                                : Colors.white.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Next button
          _buildNavButton(
            icon: Icons.chevron_right,
            onPressed: _nextCarouselPage,
          ),
        ],
      ),
    );
  }

  Widget _buildNavButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.3),
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(12),
            color: Colors.white.withValues(alpha: 0.08),
          ),
          child: Icon(
            icon,
            color: const Color(0xFF22C55E),
            size: 20,
          ),
        ),
      ),
    );
  }

  // Mobile content section - minimal padding, compact layout
  Widget _buildMobileContentSection(BoxConstraints constraints) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.lg),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: TextStyle(
                fontFamily: 'dm-sans',
                fontSize: 32,
                fontWeight: FontWeight.w800,
                height: 1.2,
                color: Colors.white,
              ),
              children: const [
                TextSpan(text: 'Download the\n'),
                TextSpan(
                  text: 'Accel-O-Rot App',
                  style: TextStyle(
                    color: Color(0xFF22C55E),
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Get our AI-powered mobile app to monitor your composting system, '
            'receive real-time insights, and manage your organic waste efficiently.\n'
            'Available for Android.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              height: 1.6,
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.85,
            height: 56,
            child: PrimaryButton(
              text: 'Download APK v1.0.0',
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Downloading Accel-O-Rot v1.0.0.apk'),
                    backgroundColor: Color(0xFF22C55E),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Desktop content section - original styling
  Widget _buildDesktopContentSection(BoxConstraints constraints) {
    return Center(
      child: SingleChildScrollView(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: AppSpacing.xxxl,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: const TextStyle(
                    fontFamily: 'dm-sans',
                    fontSize: 48,
                    fontWeight: FontWeight.w800,
                    height: 1.2,
                    color: Colors.white,
                  ),
                  children: const [
                    TextSpan(text: 'Download the\n'),
                    TextSpan(
                      text: 'Accel-O-Rot App',
                      style: TextStyle(
                        color: Color(0xFF22C55E),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: Text(
                  'Get our AI-powered mobile app to monitor your composting system, '
                  'receive real-time insights, and manage your organic waste efficiently.\n'
                  'Available for Android.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    height: 1.6,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xxxl),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 280),
                child: SizedBox(
                  width: 260,
                  height: 56,
                  child: PrimaryButton(
                    text: 'Download APK v1.0.0',
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Downloading Accel-O-Rot v1.0.0.apk'),
                          backgroundColor: Color(0xFF22C55E),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MobileMenu extends StatelessWidget {
  final VoidCallback onLogin;
  final VoidCallback onGetStarted;
  final VoidCallback onNavigateHome;
  final VoidCallback onToggleMenu;

  const _MobileMenu({
    required this.onLogin,
    required this.onGetStarted,
    required this.onNavigateHome,
    required this.onToggleMenu,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 8,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: double.infinity,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height - 64,
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
        child: ScrollConfiguration(
          behavior: ScrollConfiguration.of(context).copyWith(
            scrollbars: false,
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Back to Home
                _buildMenuItem(
                  'Back to Home',
                  () {
                    onNavigateHome();
                    onToggleMenu();
                  },
                ),
                
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
      ),
    );
  }

  Widget _buildMenuItem(String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Color(0xFF4B5563),
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