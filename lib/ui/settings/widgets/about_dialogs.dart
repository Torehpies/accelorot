import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/themes/app_theme.dart';
import '../../core/widgets/bottom_sheets/mobile_bottom_sheet_base.dart';
import '../../core/widgets/bottom_sheets/mobile_bottom_sheet_buttons.dart';

// ─── public entry-points ─────────────────────────────────────────────────────

class AboutDialogs {
  static bool _isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= kTabletBreakpoint;

  static Future<void> showPrivacyPolicy(BuildContext context) {
    if (_isDesktop(context)) {
      return showDialog(
        context: context,
        builder: (_) => const _PolicyDialog(type: _PolicyType.privacy),
      );
    }
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black54,
      builder: (_) => const _PolicyDialog(type: _PolicyType.privacy),
    );
  }

  static Future<void> showTermsOfService(BuildContext context) {
    if (_isDesktop(context)) {
      return showDialog(
        context: context,
        builder: (_) => const _PolicyDialog(type: _PolicyType.terms),
      );
    }
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black54,
      builder: (_) => const _PolicyDialog(type: _PolicyType.terms),
    );
  }

  static Future<void> showHelpSupport(BuildContext context) {
    if (_isDesktop(context)) {
      return showDialog(
        context: context,
        builder: (_) => const _HelpSupportDialog(),
      );
    }
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black54,
      builder: (_) => const _HelpSupportDialog(),
    );
  }

  static Future<void> showAppInfo(BuildContext context) {
    if (_isDesktop(context)) {
      return showDialog(
        context: context,
        builder: (_) => const _AppInfoDialog(),
      );
    }
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black54,
      builder: (_) => const _AppInfoDialog(),
    );
  }
}

// ─── shared scrollable policy dialog ─────────────────────────────────────────

enum _PolicyType { privacy, terms }

class _PolicyDialog extends StatelessWidget {
  final _PolicyType type;
  const _PolicyDialog({required this.type});

  bool _isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= kTabletBreakpoint;

  @override
  Widget build(BuildContext context) {
    return _isDesktop(context)
        ? _buildDialog(context)
        : _buildBottomSheet(context);
  }

  // ── Web ───────────────────────────────────────────────────────────────────

  Widget _buildDialog(BuildContext context) {
    final title =
        type == _PolicyType.privacy ? 'Privacy Policy' : 'Terms of Service';
    final lastUpdated = 'Last updated: February 1, 2026';

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 600,
          maxHeight: MediaQuery.of(context).size.height * 0.80,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 12, 0),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.green100.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      type == _PolicyType.privacy
                          ? Icons.privacy_tip_outlined
                          : Icons.description_outlined,
                      color: AppColors.green100,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 18)),
                        Text(lastUpdated,
                            style: TextStyle(
                                fontSize: 12, color: Colors.grey[600])),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            const Divider(height: 20),
            // Scrollable content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: type == _PolicyType.privacy
                    ? const _PrivacyContent()
                    : const _TermsContent(),
              ),
            ),
            // Footer close button
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Close'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Mobile ────────────────────────────────────────────────────────────────

  Widget _buildBottomSheet(BuildContext context) {
    final title =
        type == _PolicyType.privacy ? 'Privacy Policy' : 'Terms of Service';

    return MobileBottomSheetBase(
      title: title,
      subtitle: 'Last updated: February 1, 2026',
      body: type == _PolicyType.privacy
          ? const _PrivacyContent()
          : const _TermsContent(),
      actions: [
        BottomSheetAction.primary(
          label: 'Close',
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }
}

// ─── privacy policy content ───────────────────────────────────────────────────

class _PrivacyContent extends StatelessWidget {
  const _PrivacyContent();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _section('1. Introduction',
            'Accel-O-Rot ("we," "our," or "us") is committed to protecting your privacy. This Privacy Policy explains how we collect, use, disclose, and safeguard your information when you use our Smart Rotary Drum System and mobile application.'),
        _section('2. Information We Collect', null),
        _subsection('Personal Information',
            'We may collect personally identifiable information, including:'),
        _bullets([
          'Name and contact information (email, phone number)',
          'Organization or barangay affiliation',
          'Device location (with your consent)'
        ]),
        _subsection('Composting System Data',
            'Our IoT sensors automatically collect:'),
        _bullets([
          'Temperature readings inside the drum',
          'Moisture levels of organic materials',
          'Rotation frequency and duration',
          'Waste volume and processing metrics',
          'System alerts and maintenance logs'
        ]),
        _subsection('Usage Data',
            'We automatically collect information about your interaction with our app:'),
        _bullets([
          'Device type and operating system',
          'App usage patterns and preferences',
          'Log data and error reports'
        ]),
        _section('3. How We Use Your Information',
            'We use the collected information for:'),
        _bullets([
          'Operating and maintaining the composting system',
          'Sending real-time alerts and notifications',
          'Generating composting reports and analytics',
          'Improving our products and services',
          'Communicating updates and support information',
          'Complying with RA 9003 reporting requirements'
        ]),
        _section('4. Data Sharing and Disclosure',
            'We may share your information with:'),
        _bullets([
          'Local Government Units (LGUs): Aggregated waste management data for compliance reporting',
          'Service Providers: Third parties who assist in operating our service',
          'Research Partners: Anonymized data for environmental research',
          'Legal Requirements: When required by Philippine law or government agencies'
        ]),
        _note('We do not sell your personal information to third parties.'),
        _section('5. Data Security',
            'We implement appropriate technical and organizational security measures to protect your information, including encryption of data in transit and at rest, secure authentication protocols, regular security assessments, and access controls.'),
        _section('6. Data Retention',
            'We retain your personal information for as long as your account is active or as needed to provide services. Composting data is retained for a minimum of 5 years for compliance and research purposes.'),
        _section('7. Your Rights',
            'Under the Data Privacy Act of 2012 (RA 10173), you have the right to:'),
        _bullets([
          'Access your personal data',
          'Correct inaccurate information',
          'Object to data processing',
          'Request data deletion',
          'Data portability',
          'Lodge complaints with the National Privacy Commission'
        ]),
        _section('8. Contact Us',
            'For privacy-related inquiries:'),
        _contactInfo(),
      ],
    );
  }
}

// ─── terms content ────────────────────────────────────────────────────────────

class _TermsContent extends StatelessWidget {
  const _TermsContent();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _section('1. Acceptance of Terms',
            'By accessing or using the Accel-O-Rot mobile application and associated digital services ("Service"), you agree to be bound by these Terms of Service. If you do not agree to these terms, please do not access or use the Service.'),
        _section('2. Description of Service',
            'Accel-O-Rot provides a smart composting solution that includes:'),
        _bullets([
          'Automated rotary drum composting system',
          'IoT-enabled monitoring sensors for temperature and moisture',
          'Mobile application for real-time monitoring and control',
          'Data analytics and reporting features'
        ]),
        _section('3. User Responsibilities',
            'As a user of our Service, you agree to:'),
        _bullets([
          'Provide accurate and complete registration information',
          'Maintain the security of your account credentials',
          'Use the composting system according to provided guidelines',
          'Not misuse or tamper with the monitoring equipment',
          'Comply with all applicable environmental regulations'
        ]),
        _section('4. Acceptable Use', 'You agree not to:'),
        _bullets([
          'Use the Service for any unlawful purpose',
          'Attempt to gain unauthorized access to our systems',
          'Interfere with or disrupt the Service',
          'Reverse engineer or attempt to extract source code',
          'Use the composting system for hazardous or prohibited materials'
        ]),
        _section('5. Intellectual Property',
            'All content, features, and functionality of the Service, including text, graphics, logos, and software, are the exclusive property of Accel-O-Rot and are protected by Philippine and international copyright laws.'),
        _section('6. Warranty Disclaimer',
            'The Service is provided "as is" and "as available" without warranties of any kind. We do not guarantee that the Service will be uninterrupted, secure, or error-free.'),
        _section('7. Limitation of Liability',
            'To the fullest extent permitted by law, Accel-O-Rot shall not be liable for any indirect, incidental, special, or consequential damages arising from your use of the Service.'),
        _section('8. Compliance with RA 9003',
            'Our Service is designed to support compliance with Republic Act No. 9003 (Ecological Solid Waste Management Act of 2000). Users are responsible for ensuring their use aligns with local waste management regulations.'),
        _section('9. Governing Law',
            'These Terms shall be governed by and construed in accordance with the laws of the Republic of the Philippines.'),
        _section('10. Contact Information',
            'For questions about these Terms, please contact us at:'),
        _contactInfo(),
      ],
    );
  }
}

// ─── help & support dialog ────────────────────────────────────────────────────

class _HelpSupportDialog extends StatelessWidget {
  const _HelpSupportDialog();

  Future<void> _launchEmail(BuildContext context) async {
    const email = 'accelorot.management@gmail.com';
    const subject = 'Help & Support - Accel-O-Rot App';
    final gmailUri = Uri.parse(
        'https://mail.google.com/mail/?view=cm&fs=1&to=$email&su=$subject');
    if (!await launchUrl(gmailUri)) {
      final mailtoUri = Uri(
          scheme: 'mailto',
          path: email,
          queryParameters: {'subject': subject});
      if (!await launchUrl(mailtoUri)) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Failed to open email client')));
        }
      }
    }
  }

  bool _isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= kTabletBreakpoint;

  @override
  Widget build(BuildContext context) {
    return _isDesktop(context)
        ? _buildDialog(context)
        : _buildBottomSheet(context);
  }

  // ── Web ───────────────────────────────────────────────────────────────────

  Widget _buildDialog(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.green100.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.help_outline,
                color: AppColors.green100, size: 22),
          ),
          const SizedBox(width: 12),
          const Flexible(
            child: Text('Help & Support',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          ),
        ],
      ),
      // Wrap in SingleChildScrollView — Material 3 AlertDialog does NOT
      // auto-scroll its content, so tall content would overflow the Flexible.
      content: SingleChildScrollView(
        child: _contactContent(context),
      ),
      actions: [
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }

  // ── Mobile ────────────────────────────────────────────────────────────────

  Widget _buildBottomSheet(BuildContext context) {
    return MobileBottomSheetBase(
      title: 'Help & Support',
      subtitle: 'Need help? Reach out to the Accel-O-Rot team.',
      body: _contactContent(context),
      actions: [
        BottomSheetAction.primary(
          label: 'Close',
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }

  // ── Shared content ────────────────────────────────────────────────────────

  Widget _contactContent(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_isDesktop(context)) ...[
          Text('Need help? Reach out to the Accel-O-Rot team.',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
          const SizedBox(height: 20),
        ],
        _contactRow(
          Icons.email_outlined,
          'Email',
          'accelorot.management@gmail.com',
          onTap: () => _launchEmail(context),
          isLink: true,
        ),
        const SizedBox(height: 12),
        _contactRow(Icons.phone_outlined, 'Phone', '+63 951 000 7296'),
        const SizedBox(height: 12),
        _contactRow(
          Icons.location_on_outlined,
          'Address',
          'Congressional Rd Ext, Barangay 171,\nCaloocan City, Philippines',
        ),
      ],
    );
  }

  Widget _contactRow(IconData icon, String label, String value,
      {VoidCallback? onTap, bool isLink = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.green100, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                      color: AppColors.textSecondary)),
              const SizedBox(height: 2),
              onTap != null
                  ? GestureDetector(
                      onTap: onTap,
                      child: Text(value,
                          style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF1A73E8),
                              decoration: TextDecoration.underline,
                              decorationColor: Color(0xFF1A73E8))),
                    )
                  : Text(value,
                      style: const TextStyle(
                          fontSize: 14, color: AppColors.textPrimary)),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── app info dialog ──────────────────────────────────────────────────────────

class _AppInfoDialog extends StatelessWidget {
  const _AppInfoDialog();

  bool _isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= kTabletBreakpoint;

  @override
  Widget build(BuildContext context) {
    return _isDesktop(context)
        ? _buildDialog(context)
        : _buildBottomSheet(context);
  }

  // ── Web ───────────────────────────────────────────────────────────────────

  Widget _buildDialog(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ..._appInfoBody(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Close'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Mobile ────────────────────────────────────────────────────────────────

  Widget _buildBottomSheet(BuildContext context) {
    return MobileBottomSheetBase(
      title: 'App Info',
      subtitle: 'Version 1.0.0',
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: _appInfoBody(),
      ),
      actions: [
        BottomSheetAction.primary(
          label: 'Close',
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }

  // ── Shared content ────────────────────────────────────────────────────────

  List<Widget> _appInfoBody() {
    return [
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.green100.withValues(alpha: 0.12),
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.eco, color: AppColors.green100, size: 40),
      ),
      const SizedBox(height: 16),
      const Text('Accel-O-Rot',
          style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 17,
              color: AppColors.textPrimary)),
      const SizedBox(height: 4),
      Text('Version 1.0.0',
          style: TextStyle(fontSize: 11, color: Colors.grey[600])),
      const SizedBox(height: 16),
      const Divider(),
      const SizedBox(height: 12),
      const Text(
        'Accel-O-Rot is an IoT-enabled smart rotary drum composting system designed to accelerate the decomposition of organic waste. It uses sensors, aeration, and moisture regulation to optimize the composting process, making it faster and more efficient than traditional methods.',
        textAlign: TextAlign.justify,
        style: TextStyle(
            fontSize: 11, height: 1.6, color: AppColors.textSecondary),
      ),
      const SizedBox(height: 16),
      _infoChip(Icons.bolt_outlined, 'Compost in 14 Days'),
      const SizedBox(height: 8),
      _infoChip(Icons.monitor_heart_outlined, 'IoT-Enabled Monitoring'),
      const SizedBox(height: 8),
      _infoChip(Icons.psychology_outlined, 'AI-Powered Recommendations'),
      const SizedBox(height: 16),
    ];
  }

  Widget _infoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.greenBackground,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: AppColors.greenForeground),
          const SizedBox(width: 6),
          Text(label,
              style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.greenForeground)),
        ],
      ),
    );
  }
}

// ─── shared content helpers ───────────────────────────────────────────────────

Widget _section(String title, String? content) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(title,
          style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1F2937),
              height: 1.4)),
      if (content != null) ...[
        const SizedBox(height: 6),
        Text(content,
            style: const TextStyle(
                fontSize: 13, color: Color(0xFF4B5563), height: 1.6)),
      ],
      const SizedBox(height: 14),
    ],
  );
}

Widget _subsection(String title, String content) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(title,
          style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1F2937))),
      const SizedBox(height: 4),
      Text(content,
          style: const TextStyle(
              fontSize: 13, color: Color(0xFF4B5563), height: 1.6)),
      const SizedBox(height: 8),
    ],
  );
}

Widget _bullets(List<String> items) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      for (final item in items)
        Padding(
          padding: const EdgeInsets.only(bottom: 4, left: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('• ',
                  style: TextStyle(fontSize: 13, color: Color(0xFF4B5563))),
              Expanded(
                child: Text(item,
                    style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF4B5563),
                        height: 1.5)),
              ),
            ],
          ),
        ),
      const SizedBox(height: 12),
    ],
  );
}

Widget _note(String text) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: Text(text,
        style: const TextStyle(
            fontSize: 13,
            color: Color(0xFF4B5563),
            fontWeight: FontWeight.w600,
            height: 1.6)),
  );
}

Widget _contactInfo() {
  return Padding(
    padding: const EdgeInsets.only(left: 8, bottom: 14),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _contactLine('Email:', 'accelorot.management@gmail.com'),
        const SizedBox(height: 4),
        _contactLine('Phone:', '+63 951 000 7296'),
        const SizedBox(height: 4),
        _contactLine('Address:',
            'Congressional Rd Ext, Barangay 171, Caloocan City, Philippines'),
      ],
    ),
  );
}

Widget _contactLine(String label, String value) {
  return RichText(
    text: TextSpan(
      style: const TextStyle(
          fontSize: 13, color: Color(0xFF4B5563), height: 1.6),
      children: [
        TextSpan(
            text: '$label ',
            style: const TextStyle(fontWeight: FontWeight.w600)),
        TextSpan(text: value),
      ],
    ),
  );
}
