// lib/ui/web_landing_page/views/privacy_policy_page.dart
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

class PrivacyPolicyPage extends StatefulWidget {
  const PrivacyPolicyPage({super.key});

  @override
  State<PrivacyPolicyPage> createState() => _PrivacyPolicyPageState();
}

class _PrivacyPolicyPageState extends State<PrivacyPolicyPage> {
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
                activeSection: 'privacy-policy',
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
                              'Privacy Policy',
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

                            // Section 1
                            _buildSection(
                              '1. Introduction',
                              'Accel-O-Rot ("we," "our," or "us") is committed to protecting your privacy. This Privacy Policy explains how we collect, use, disclose, and safeguard your information when you use our Smart Rotary Drum System and mobile application.',
                              isMobile,
                            ),

                            // Section 2
                            _buildSection(
                              '2. Information We Collect',
                              '',
                              isMobile,
                            ),
                            _buildSubsection(
                              'Personal Information',
                              'We may collect personally identifiable information, including:',
                              isMobile,
                            ),
                            _buildBulletList([
                              'Name and contact information (email, phone number)',
                              'Organization or barangay affiliation',
                              'Device location (with your consent)',
                            ], isMobile),
                            _buildSubsection(
                              'Composting System Data',
                              'Our IoT sensors automatically collect:',
                              isMobile,
                            ),
                            _buildBulletList([
                              'Temperature readings inside the drum',
                              'Moisture levels of organic materials',
                              'Rotation frequency and duration',
                              'Waste volume and processing metrics',
                              'System alerts and maintenance logs',
                            ], isMobile),
                            _buildSubsection(
                              'Usage Data',
                              'We automatically collect information about your interaction with our app, including:',
                              isMobile,
                            ),
                            _buildBulletList([
                              'Device type and operating system',
                              'App usage patterns and preferences',
                              'Log data and error reports',
                            ], isMobile),

                            // Section 3
                            _buildSection(
                              '3. How We Use Your Information',
                              'We use the collected information for:',
                              isMobile,
                            ),
                            _buildBulletList([
                              'Operating and maintaining the composting system',
                              'Sending real-time alerts and notifications',
                              'Generating composting reports and analytics',
                              'Improving our products and services',
                              'Communicating updates and support information',
                              'Complying with RA 9003 reporting requirements',
                              'Research and development of sustainable waste solutions',
                            ], isMobile),

                            // Section 4
                            _buildSection(
                              '4. Data Sharing and Disclosure',
                              'We may share your information with:',
                              isMobile,
                            ),
                            _buildBulletList([
                              'Local Government Units (LGUs): Aggregated waste management data for compliance reporting',
                              'Service Providers: Third parties who assist in operating our service',
                              'Research Partners: Anonymized data for environmental research',
                              'Legal Requirements: When required by Philippine law or government agencies',
                            ], isMobile),
                            Padding(
                              padding: const EdgeInsets.only(bottom: AppSpacing.xl),
                              child: Text(
                                'We do not sell your personal information to third parties.',
                                style: TextStyle(
                                  fontSize: isMobile ? 14 : 16,
                                  color: const Color(0xFF4B5563),
                                  height: 1.6,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),

                            // Section 5
                            _buildSection(
                              '5. Data Security',
                              'We implement appropriate technical and organizational security measures to protect your information, including:',
                              isMobile,
                            ),
                            _buildBulletList([
                              'Encryption of data in transit and at rest',
                              'Secure authentication protocols',
                              'Regular security assessments and updates',
                              'Access controls and monitoring',
                            ], isMobile),

                            // Section 6
                            _buildSection(
                              '6. Data Retention',
                              'We retain your personal information for as long as your account is active or as needed to provide services. Composting data is retained for a minimum of 5 years for compliance and research purposes. You may request deletion of your account data at any time.',
                              isMobile,
                            ),

                            // Section 7
                            _buildSection(
                              '7. Your Rights',
                              'Under the Data Privacy Act of 2012 (RA 10173), you have the right to:',
                              isMobile,
                            ),
                            _buildBulletList([
                              'Access your personal data',
                              'Correct inaccurate information',
                              'Object to data processing',
                              'Request data deletion',
                              'Data portability',
                              'Lodge complaints with the National Privacy Commission',
                            ], isMobile),

                            // Section 8
                            _buildSection(
                              '8. Children\'s Privacy',
                              'Our Service is not intended for children under 18 years of age. We do not knowingly collect personal information from children. If you believe we have collected information from a child, please contact us immediately.',
                              isMobile,
                            ),

                            // Section 9
                            _buildSection(
                              '9. Changes to This Policy',
                              'We may update this Privacy Policy periodically. We will notify you of significant changes through the app or via email. Your continued use of the Service after changes indicates acceptance of the updated policy.',
                              isMobile,
                            ),

                            // Section 10
                            _buildSection(
                              '10. Contact Us',
                              'For privacy-related inquiries or to exercise your data rights, please contact our Data Protection Officer:',
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
        if (content.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.md),
          Text(
            content,
            style: TextStyle(
              fontSize: isMobile ? 14 : 16,
              color: const Color(0xFF4B5563),
              height: 1.6,
            ),
          ),
        ],
        const SizedBox(height: AppSpacing.xl),
      ],
    );
  }

  Widget _buildSubsection(String title, String content, bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: isMobile ? 16 : 18,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1F2937),
            height: 1.4,
          ),
        ),
        if (content.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.sm),
          Text(
            content,
            style: TextStyle(
              fontSize: isMobile ? 14 : 16,
              color: const Color(0xFF4B5563),
              height: 1.6,
            ),
          ),
        ],
        const SizedBox(height: AppSpacing.md),
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