// lib/ui/web_landing_page/views/terms_of_service_page.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'app_header.dart';
import 'web_header.dart';

class AppSpacing {
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 20.0;
  static const double xl = 24.0;
  static const double xxxl = 48.0;
}

class TermsOfServicePage extends StatefulWidget {
  const TermsOfServicePage({super.key});

  @override
  State<TermsOfServicePage> createState() => _TermsOfServicePageState();
}

class _TermsOfServicePageState extends State<TermsOfServicePage> {
  bool _isMenuOpen = false;

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 900;
    
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
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
                activeSection: 'terms-of-service',
                isScrolled: true,
                showActions: true,
              ),

            // Scrollable content
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(isMobile ? AppSpacing.lg : AppSpacing.xxxl),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final maxWidth = constraints.maxWidth > 800 ? 800.0 : constraints.maxWidth;
                    
                    return Center(
                      child: Container(
                        constraints: BoxConstraints(maxWidth: maxWidth),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Title
                            Text(
                              'Terms of Service',
                              style: TextStyle(
                                fontSize: isMobile ? 28 : 36,
                                fontWeight: FontWeight.w900,
                                color: const Color(0xFF1F2937),
                                height: 1.2,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.md),
                            Text(
                              'Last updated: February 1, 2026',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xxxl),

                            // Sections
                            _buildSection(
                              '1. Acceptance of Terms',
                              'By accessing or using the Accel-O-Rot mobile application and associated digital services ("Service"), you agree to be bound by these Terms of Service. If you do not agree to these terms, please do not access or use the Service.',
                              isMobile,
                            ),

                            _buildSection(
                              '2. Description of Service',
                              'Accel-O-Rot provides a smart composting solution that includes:',
                              isMobile,
                            ),
                            _buildBulletList([
                              'Automated rotary drum composting system',
                              'IoT-enabled monitoring sensors for temperature and moisture',
                              'Mobile application for real-time monitoring and control',
                              'Data analytics and reporting features',
                            ], isMobile),

                            _buildSection(
                              '3. User Responsibilities',
                              'As a user of our Service, you agree to:',
                              isMobile,
                            ),
                            _buildBulletList([
                              'Provide accurate and complete registration information',
                              'Maintain the security of your account credentials',
                              'Use the composting system according to provided guidelines',
                              'Not misuse or tamper with the monitoring equipment',
                              'Comply with all applicable environmental regulations',
                            ], isMobile),

                            _buildSection(
                              '4. Acceptable Use',
                              'You agree not to:',
                              isMobile,
                            ),
                            _buildBulletList([
                              'Use the Service for any unlawful purpose',
                              'Attempt to gain unauthorized access to our systems',
                              'Interfere with or disrupt the Service',
                              'Reverse engineer or attempt to extract source code',
                              'Use the composting system for hazardous or prohibited materials',
                            ], isMobile),

                            _buildSection(
                              '5. Intellectual Property',
                              'All content, features, and functionality of the Service, including but not limited to text, graphics, logos, and software, are the exclusive property of Accel-O-Rot and are protected by Philippine and international copyright, trademark, and other intellectual property laws.',
                              isMobile,
                            ),

                            _buildSection(
                              '6. Warranty Disclaimer',
                              'The Service is provided "as is" and "as available" without warranties of any kind, either express or implied. We do not guarantee that the Service will be uninterrupted, secure, or error-free.',
                              isMobile,
                            ),

                            _buildSection(
                              '7. Limitation of Liability',
                              'To the fullest extent permitted by law, Accel-O-Rot shall not be liable for any indirect, incidental, special, consequential, or punitive damages arising from your use of the Service.',
                              isMobile,
                            ),

                            _buildSection(
                              '8. Compliance with RA 9003',
                              'Our Service is designed to support compliance with Republic Act No. 9003 (Ecological Solid Waste Management Act of 2000). Users are responsible for ensuring their use of the Service aligns with local waste management regulations and requirements.',
                              isMobile,
                            ),

                            _buildSection(
                              '9. Modifications to Terms',
                              'We reserve the right to modify these Terms at any time. We will notify users of significant changes via email or through the mobile application. Continued use of the Service after changes constitutes acceptance of the new Terms.',
                              isMobile,
                            ),

                            _buildSection(
                              '10. Governing Law',
                              'These Terms shall be governed by and construed in accordance with the laws of the Republic of the Philippines, without regard to its conflict of law provisions.',
                              isMobile,
                            ),

                            _buildSection(
                              '11. Contact Information',
                              'For questions about these Terms, please contact us at:',
                              isMobile,
                            ),
                            _buildContactInfo(isMobile),

                            const SizedBox(height: AppSpacing.xxxl),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content, bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: isMobile ? 18 : 20,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1F2937),
            height: 1.4,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          content,
          style: TextStyle(
            fontSize: isMobile ? 14 : 16,
            color: const Color(0xFF4B5563),
            height: 1.6,
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
      ],
    );
  }

  Widget _buildBulletList(List<String> items, bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var item in items)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm, left: AppSpacing.lg),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '• ',
                  style: TextStyle(
                    fontSize: isMobile ? 14 : 16,
                    color: const Color(0xFF4B5563),
                    height: 1.6,
                  ),
                ),
                Expanded(
                  child: Text(
                    item,
                    style: TextStyle(
                      fontSize: isMobile ? 14 : 16,
                      color: const Color(0xFF4B5563),
                      height: 1.6,
                    ),
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: AppSpacing.lg),
      ],
    );
  }

  Widget _buildContactInfo(bool isMobile) {
    return Padding(
      padding: const EdgeInsets.only(left: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildContactLine('Email:', 'accelorot.management@gmail.com', isMobile),
          const SizedBox(height: AppSpacing.sm),
          _buildContactLine('Phone:', '+63 951 000 7296', isMobile),
          const SizedBox(height: AppSpacing.sm),
          _buildContactLine('Address:', 'Congressional Rd Ext, Barangay 171, Caloocan City, Philippines', isMobile),
        ],
      ),
    );
  }

  Widget _buildContactLine(String label, String value, bool isMobile) {
    return RichText(
      text: TextSpan(
        style: TextStyle(
          fontSize: isMobile ? 14 : 16,
          color: const Color(0xFF4B5563),
          height: 1.6,
        ),
        children: [
          TextSpan(
            text: '$label ',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
          TextSpan(text: value),
        ],
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