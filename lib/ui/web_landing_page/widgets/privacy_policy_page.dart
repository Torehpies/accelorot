import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppSpacing {
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 20.0;
  static const double xl = 24.0;
  static const double xxxl = 48.0;
}

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

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
                              'Privacy Policy',
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
                              '1. Introduction',
                              'Accel-O-Rot ("we," "our," or "us") is committed to protecting your privacy. This Privacy Policy explains how we collect, use, disclose, and safeguard your information when you use our Smart Rotary Drum System and mobile application.',
                            ),

                            // Section 2
                            _buildSection(
                              '2. Information We Collect',
                              '',
                            ),
                            _buildSubsection(
                              'Personal Information',
                              'We may collect personally identifiable information, including:',
                            ),
                            _buildBulletList([
                              'Name and contact information (email, phone number)',
                              'Organization or barangay affiliation',
                              'Account credentials',
                              'Device location (with your consent)',
                            ]),
                            _buildSubsection(
                              'Composting System Data',
                              'Our IoT sensors automatically collect:',
                            ),
                            _buildBulletList([
                              'Temperature readings inside the drum',
                              'Moisture levels of organic materials',
                              'Rotation frequency and duration',
                              'Waste volume and processing metrics',
                              'System alerts and maintenance logs',
                            ]),
                            _buildSubsection(
                              'Usage Data',
                              'We automatically collect information about your interaction with our app, including:',
                            ),
                            _buildBulletList([
                              'Device type and operating system',
                              'App usage patterns and preferences',
                              'Log data and error reports',
                            ]),

                            // Section 3
                            _buildSection(
                              '3. How We Use Your Information',
                              'We use the collected information for:',
                            ),
                            _buildBulletList([
                              'Operating and maintaining the composting system',
                              'Sending real-time alerts and notifications',
                              'Generating composting reports and analytics',
                              'Improving our products and services',
                              'Communicating updates and support information',
                              'Complying with RA 9003 reporting requirements',
                              'Research and development of sustainable waste solutions',
                            ]),

                            // Section 4
                            _buildSection(
                              '4. Data Sharing and Disclosure',
                              'We may share your information with:',
                            ),
                            _buildBulletList([
                              'Local Government Units (LGUs): Aggregated waste management data for compliance reporting',
                              'Service Providers: Third parties who assist in operating our service',
                              'Research Partners: Anonymized data for environmental research',
                              'Legal Requirements: When required by Philippine law or government agencies',
                            ]),
                            const Padding(
                              padding: EdgeInsets.only(bottom: AppSpacing.xl),
                              child: Text(
                                'We do not sell your personal information to third parties.',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Color(0xFF4B5563),
                                  height: 1.6,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),

                            // Section 5
                            _buildSection(
                              '5. Data Security',
                              'We implement appropriate technical and organizational security measures to protect your information, including:',
                            ),
                            _buildBulletList([
                              'Encryption of data in transit and at rest',
                              'Secure authentication protocols',
                              'Regular security assessments and updates',
                              'Access controls and monitoring',
                            ]),

                            // Section 6
                            _buildSection(
                              '6. Data Retention',
                              'We retain your personal information for as long as your account is active or as needed to provide services. Composting data is retained for a minimum of 5 years for compliance and research purposes. You may request deletion of your account data at any time.',
                            ),

                            // Section 7
                            _buildSection(
                              '7. Your Rights',
                              'Under the Data Privacy Act of 2012 (RA 10173), you have the right to:',
                            ),
                            _buildBulletList([
                              'Access your personal data',
                              'Correct inaccurate information',
                              'Object to data processing',
                              'Request data deletion',
                              'Data portability',
                              'Lodge complaints with the National Privacy Commission',
                            ]),

                            // Section 8
                            _buildSection(
                              '8. Children\'s Privacy',
                              'Our Service is not intended for children under 18 years of age. We do not knowingly collect personal information from children. If you believe we have collected information from a child, please contact us immediately.',
                            ),

                            // Section 9
                            _buildSection(
                              '9. Changes to This Policy',
                              'We may update this Privacy Policy periodically. We will notify you of significant changes through the app or via email. Your continued use of the Service after changes indicates acceptance of the updated policy.',
                            ),

                            // Section 10
                            _buildSection(
                              '10. Contact Us',
                              'For privacy-related inquiries or to exercise your data rights, please contact our Data Protection Officer:',
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
        if (content.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.md),
          Text(
            content,
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF4B5563),
              height: 1.6,
            ),
          ),
        ],
        const SizedBox(height: AppSpacing.xl),
      ],
    );
  }

  Widget _buildSubsection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1F2937),
            height: 1.4,
          ),
        ),
        if (content.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.sm),
          Text(
            content,
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF4B5563),
              height: 1.6,
            ),
          ),
        ],
        const SizedBox(height: AppSpacing.md),
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