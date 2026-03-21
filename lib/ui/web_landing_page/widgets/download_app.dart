// lib/ui/web_landing_page/views/download_app.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'app_header.dart';
import 'web_header.dart';
import '../../core/themes/app_theme.dart';

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

class _DownloadAppState extends State<DownloadApp> {
  bool _isMenuOpen = false;

  Future<void> _downloadApk() async {
    final Uri url = Uri.parse(
      "https://firebasestorage.googleapis.com/v0/b/accel-o-rot.firebasestorage.app/o/accel-o-rot-app.apk?alt=media&token=56490298-4701-45b9-bd35-ba6a39748465",
    );
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not start download. Please try again.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 900;

    return Scaffold(
      backgroundColor: AppColors.background1,
      body: SafeArea(
        child: Column(
          children: [
            // Header (responsive)
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
                onBreadcrumbTap: (_) => context.go('/'),
                onLogin: () => context.go('/login'),
                onGetStarted: () => context.go('/signup'),
                activeSection: 'download',
                isScrolled: true,
                showActions: true,
              ),

            // Main Content - Split Screen Design
            Expanded(
              child: isMobile
                  ? _buildMobileLayout()
                  : _buildDesktopLayout(),
            ),
          ],
        ),
      ),
    );
  }

  // ───────────────────────────────────────────────────────────
  // Desktop Layout: Split Row (Content | Mockup)
  // ───────────────────────────────────────────────────────────
  Widget _buildDesktopLayout() {
    return Row(
      children: [
        // LEFT: Content Section (flex: 3)
        Expanded(
          flex: 3,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 60),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.background, Colors.white],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: AppSpacing.xl),

                  // Title
                  const Text(
                    "Download the Accel-O-Rot App",
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.w800,
                      color: AppColors.green100,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Subtitle
                  const Text(
                    "Get our AI-powered mobile app to monitor your composting system, "
                    "receive real-time insights, and manage your organic waste efficiently.\n"
                    "Available for Android.",
                    style: TextStyle(
                      fontSize: 18,
                      height: 1.6,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxxl),

                  // Download Button
                  SizedBox(
                    width: 260,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _downloadApk,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.green100,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "Download APK v1.0",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Optional secondary action (e.g., view features)
                  TextButton(
                    onPressed: () => context.go('/features'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.black54,
                      padding: EdgeInsets.zero,
                    ),
                    child: const Text(
                      "View all features →",
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // RIGHT: Mockup Image (flex: 2)
        Expanded(
          flex: 2,
          child: Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/mockup.png"),
                fit: BoxFit.cover,
                alignment: Alignment.center,
              ),
            ),
            child: Container(
              // Optional overlay for depth
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.05),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ───────────────────────────────────────────────────────────
  // Mobile Layout: Stacked (Content on Top | Mockup Below)
  // ───────────────────────────────────────────────────────────
  Widget _buildMobileLayout() {
    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
      child: SingleChildScrollView(
        child: Column(
          children: [
            // Content Section
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xl,
                vertical: AppSpacing.xxxl,
              ),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.background, Colors.white],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: AppSpacing.xl),

                  // Title
                  RichText(
                    textAlign: TextAlign.center,
                    text: const TextSpan(
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        height: 1.2,
                        color: Colors.black87,
                      ),
                      children: [
                        TextSpan(text: 'Download the\n'),
                        TextSpan(
                          text: 'Accel-O-Rot App',
                          style: TextStyle(color: AppColors.green100),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Subtitle
                  Text(
                    'Get our AI-powered mobile app to monitor your composting system, '
                    'receive real-time insights, and manage your organic waste efficiently.\n'
                    'Available for Android.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.6,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxxl),

                  // Download Button (full width on mobile)
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _downloadApk,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.green100,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "Download APK v1.0.0",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  TextButton(
                    onPressed: () => context.go('/features'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.black54,
                      padding: EdgeInsets.zero,
                    ),
                    child: const Text(
                      "View all features →",
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),

            // Mockup Image Section
            Container(
              height: 400,
              width: double.infinity,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/images/mockup.png"),
                  fit: BoxFit.cover,
                  alignment: Alignment.topCenter,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ───────────────────────────────────────────────────────────
// Mobile Menu (unchanged from original, kept for functionality)
// ───────────────────────────────────────────────────────────
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
          behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildMenuItem('Back to Home', () {
                  onNavigateHome();
                  onToggleMenu();
                }),
                const Divider(height: 32, thickness: 1, color: Color(0xFFE5E7EB)),
                _buildLegalLink(context, 'Privacy Policy', () {
                  onToggleMenu();
                  context.go('/privacy-policy');
                }),
                _buildLegalLink(context, 'Terms of Service', () {
                  onToggleMenu();
                  context.go('/terms-of-service');
                }),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton(
                    onPressed: onLogin,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.green100,
                      side: const BorderSide(color: AppColors.green100, width: 2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Login',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
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
                      backgroundColor: AppColors.green100,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Get Started',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
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