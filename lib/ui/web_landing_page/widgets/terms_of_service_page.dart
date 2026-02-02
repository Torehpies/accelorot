import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppSpacing {
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 20.0;
  static const double xl = 24.0;
  static const double xxxl = 48.0;
}

class TermsOfServicePage extends StatelessWidget {
  const TermsOfServicePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header with back button
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 32,
                    height: 32,
                    child: IconButton(
                      onPressed: () => context.go('/'),
                      icon: const Icon(Icons.arrow_back_ios_new, size: 18),
                      padding: EdgeInsets.zero,
                      tooltip: 'Back to Home',
                      splashRadius: 16,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    'Back to Home',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ),

            // Scrollable content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.xxxl),
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
                            const Text(
                              'Terms of Service',
                              style: TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF1F2937),
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
                              '1. Acceptance of Terms',
                              'By accessing and using the Accel-O-Rot Smart Rotary Drum System and associated mobile application ("Service"), you agree to be bound by these Terms of Service. If you do not agree to these terms, please do not use our Service.',
                            ),

                            // Section 2
                            _buildSection(
                              '2. Description of Service',
                              'Accel-O-Rot provides a smart composting solution that includes:',
                            ),
                            _buildBulletList([
                              'Automated rotary drum composting system',
                              'IoT-enabled monitoring sensors for temperature and moisture',
                              'Mobile application for real-time monitoring and control',
                              'Data analytics and reporting features',
                            ]),

                            // Section 3
                            _buildSection(
                              '3. User Responsibilities',
                              'As a user of our Service, you agree to:',
                            ),
                            _buildBulletList([
                              'Provide accurate and complete registration information',
                              'Maintain the security of your account credentials',
                              'Use the composting system according to provided guidelines',
                              'Not misuse or tamper with the monitoring equipment',
                              'Comply with all applicable environmental regulations',
                            ]),

                            // Section 4
                            _buildSection(
                              '4. Acceptable Use',
                              'You agree not to:',
                            ),
                            _buildBulletList([
                              'Use the Service for any unlawful purpose',
                              'Attempt to gain unauthorized access to our systems',
                              'Interfere with or disrupt the Service',
                              'Reverse engineer or attempt to extract source code',
                              'Use the composting system for hazardous or prohibited materials',
                            ]),

                            // Section 5
                            _buildSection(
                              '5. Intellectual Property',
                              'All content, features, and functionality of the Service, including but not limited to text, graphics, logos, and software, are the exclusive property of Accel-O-Rot and are protected by Philippine and international copyright, trademark, and other intellectual property laws.',
                            ),

                            // Section 6
                            _buildSection(
                              '6. Warranty Disclaimer',
                              'The Service is provided "as is" and "as available" without warranties of any kind, either express or implied. We do not guarantee that the Service will be uninterrupted, secure, or error-free.',
                            ),

                            // Section 7
                            _buildSection(
                              '7. Limitation of Liability',
                              'To the fullest extent permitted by law, Accel-O-Rot shall not be liable for any indirect, incidental, special, consequential, or punitive damages arising from your use of the Service.',
                            ),

                            // Section 8
                            _buildSection(
                              '8. Compliance with RA 9003',
                              'Our Service is designed to support compliance with Republic Act No. 9003 (Ecological Solid Waste Management Act of 2000). Users are responsible for ensuring their use of the Service aligns with local waste management regulations and requirements.',
                            ),

                            // Section 9
                            _buildSection(
                              '9. Modifications to Terms',
                              'We reserve the right to modify these Terms at any time. We will notify users of significant changes via email or through the mobile application. Continued use of the Service after changes constitutes acceptance of the new Terms.',
                            ),

                            // Section 10
                            _buildSection(
                              '10. Governing Law',
                              'These Terms shall be governed by and construed in accordance with the laws of the Republic of the Philippines, without regard to its conflict of law provisions.',
                            ),

                            // Section 11
                            _buildSection(
                              '11. Contact Information',
                              'For questions about these Terms, please contact us at:',
                            ),
                            _buildContactInfo(),

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

  Widget _buildSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1F2937),
            height: 1.4,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          content,
          style: const TextStyle(
            fontSize: 16,
            color: Color(0xFF4B5563),
            height: 1.6,
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
      ],
    );
  }

  Widget _buildBulletList(List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var item in items)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm, left: AppSpacing.lg),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '• ',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF4B5563),
                    height: 1.6,
                  ),
                ),
                Expanded(
                  child: Text(
                    item,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(0xFF4B5563),
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

  Widget _buildContactInfo() {
    return Padding(
      padding: const EdgeInsets.only(left: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildContactLine('Email:', 'accelorot.management@gmail.com'),
          const SizedBox(height: AppSpacing.sm),
          _buildContactLine('Phone:', '+63 951 000 7296'),
          const SizedBox(height: AppSpacing.sm),
          _buildContactLine('Address:', 'Congressional Rd Ext, Barangay 171, Caloocan City, Philippines'),
        ],
      ),
    );
  }

  Widget _buildContactLine(String label, String value) {
    return RichText(
      text: TextSpan(
        style: const TextStyle(
          fontSize: 16,
          color: Color(0xFF4B5563),
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