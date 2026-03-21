import 'package:flutter/material.dart';
import '../../core/constants/spacing.dart';

class PrivacyPolicyDialog extends StatefulWidget {
  const PrivacyPolicyDialog({super.key});

  @override
  State<PrivacyPolicyDialog> createState() => _PrivacyPolicyDialogState();
}

class _PrivacyPolicyDialogState extends State<PrivacyPolicyDialog> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(
        horizontal: isMobile ? AppSpacing.md : AppSpacing.xl,
        vertical: isMobile ? AppSpacing.md : AppSpacing.xl,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.25),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        constraints: BoxConstraints(
          maxWidth: isMobile ? double.infinity : 700,
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with close button
            _buildHeader(isMobile),
            
            const Divider(height: 1, color: Color(0xFFE5E7EB)),
            
            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                padding: EdgeInsets.all(isMobile ? AppSpacing.md : AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTitle(isMobile),
                    const SizedBox(height: AppSpacing.xs),
                    _buildLastUpdated(),
                    const SizedBox(height: AppSpacing.lg),

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
                      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                      child: Text(
                        'We do not sell your personal information to third parties.',
                        style: TextStyle(
                          fontSize: isMobile ? 12 : 14,
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
                    const SizedBox(height: AppSpacing.lg),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isMobile) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? AppSpacing.md : AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close, color: Color(0xFF6B7280), size: 20),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            tooltip: 'Close',
          ),
        ],
      ),
    );
  }

  Widget _buildTitle(bool isMobile) {
    return Text(
      'Privacy Policy',
      style: TextStyle(
        fontSize: isMobile ? 20 : 24,
        fontWeight: FontWeight.w900,
        color: const Color(0xFF1F2937),
        height: 1.2,
      ),
    );
  }

  Widget _buildLastUpdated() {
    return Text(
      'Last updated: February 1, 2026',
      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
    );
  }

  Widget _buildSection(String title, String content, bool isMobile) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: isMobile ? 14 : 16,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1F2937),
              height: 1.4,
            ),
          ),
          if (content.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              content,
              style: TextStyle(
                fontSize: isMobile ? 12 : 14,
                color: const Color(0xFF4B5563),
                height: 1.6,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSubsection(String title, String content, bool isMobile) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.md, bottom: AppSpacing.xs),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: isMobile ? 13 : 15,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1F2937),
              height: 1.4,
            ),
          ),
          if (content.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              content,
              style: TextStyle(
                fontSize: isMobile ? 12 : 14,
                color: const Color(0xFF4B5563),
                height: 1.6,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBulletList(List<String> items, bool isMobile) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var item in items)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.xs),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '• ',
                    style: TextStyle(fontSize: 14, color: Color(0xFF4B5563), height: 1.6),
                  ),
                  Expanded(
                    child: Text(
                      item,
                      style: TextStyle(
                        fontSize: isMobile ? 12 : 14,
                        color: const Color(0xFF4B5563),
                        height: 1.6,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildContactInfo(bool isMobile) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildContactLine('Email:', 'accelorot.management@gmail.com', isMobile),
          const SizedBox(height: AppSpacing.xs),
          _buildContactLine('Phone:', '+63 951 000 7296', isMobile),
          const SizedBox(height: AppSpacing.xs),
          _buildContactLine(
            'Address:',
            'Congressional Rd Ext, Barangay 171, Caloocan City, Philippines',
            isMobile,
          ),
        ],
      ),
    );
  }

  Widget _buildContactLine(String label, String value, bool isMobile) {
    return RichText(
      text: TextSpan(
        style: TextStyle(
          fontSize: isMobile ? 12 : 14,
          color: const Color(0xFF4B5563),
          height: 1.6,
        ),
        children: [
          TextSpan(text: '$label ', style: const TextStyle(fontWeight: FontWeight.w600)),
          TextSpan(text: value),
        ],
      ),
    );
  }
}