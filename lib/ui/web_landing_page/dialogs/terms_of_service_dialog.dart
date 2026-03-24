import 'package:flutter/material.dart';
import '../../core/constants/spacing.dart';
import 'policy_bottom_sheet.dart' show PolicyBottomSheet, PolicyType;

class TermsOfServiceDialog extends StatefulWidget {
  const TermsOfServiceDialog({super.key});

  static void showModal(BuildContext context) {
    final isMobile = MediaQuery.sizeOf(context).width < 768;
    if (isMobile) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        useRootNavigator: true,
        backgroundColor: Colors.transparent,
        builder: (_) => const PolicyBottomSheet(policyType: PolicyType.terms),
      );
    } else {
      showDialog(
        context: context,
        builder: (_) => const TermsOfServiceDialog(),
      );
    }
  }

  @override
  State<TermsOfServiceDialog> createState() => _TermsOfServiceDialogState();
}

class _TermsOfServiceDialogState extends State<TermsOfServiceDialog> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.sizeOf(context).width < 600;

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
          maxHeight: MediaQuery.sizeOf(context).height * 0.85,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context, isMobile),
            const Divider(height: 1, color: Color(0xFFE5E7EB)),
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                padding: EdgeInsets.all(isMobile ? AppSpacing.md : AppSpacing.lg),
                child: TermsOfServiceBody(isMobile: isMobile),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isMobile) {
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
}


class TermsOfServiceBody extends StatelessWidget {
  final bool isMobile;
  const TermsOfServiceBody({super.key, required this.isMobile});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _title(isMobile),
        const SizedBox(height: AppSpacing.xs),
        _lastUpdated(),
        const SizedBox(height: AppSpacing.xl),
        
        _section('1. Acceptance of Terms',
            'By accessing or using the Accel-O-Rot mobile application and associated digital services ("Service"), you agree to be bound by these Terms of Service. If you do not agree to these terms, please do not access or use the Service.',
            isMobile),
        
        _section('2. Description of Service',
            'Accel-O-Rot provides a smart composting solution that includes:',
            isMobile),
        _bullets([
          'Automated rotary drum composting system',
          'IoT-enabled monitoring sensors for temperature and moisture',
          'Mobile application for real-time monitoring and control',
          'Data analytics and reporting features',
        ], isMobile),
        
        _section('3. User Responsibilities',
            'As a user of our Service, you agree to:', isMobile),
        _bullets([
          'Provide accurate and complete registration information',
          'Maintain the security of your account credentials',
          'Use the composting system according to provided guidelines',
          'Not misuse or tamper with the monitoring equipment',
          'Comply with all applicable environmental regulations',
        ], isMobile),
        
        _section('4. Acceptable Use', 'You agree not to:', isMobile),
        _bullets([
          'Use the Service for any unlawful purpose',
          'Attempt to gain unauthorized access to our systems',
          'Interfere with or disrupt the Service',
          'Reverse engineer or attempt to extract source code',
          'Use the composting system for hazardous or prohibited materials',
        ], isMobile),
        
        _section('5. Intellectual Property',
            'All content, features, and functionality of the Service, including but not limited to text, graphics, logos, and software, are the exclusive property of Accel-O-Rot and are protected by Philippine and international copyright, trademark, and other intellectual property laws.',
            isMobile),
        
        _section('6. Warranty Disclaimer',
            'The Service is provided "as is" and "as available" without warranties of any kind, either express or implied. We do not guarantee that the Service will be uninterrupted, secure, or error-free.',
            isMobile),
        
        _section('7. Limitation of Liability',
            'To the fullest extent permitted by law, Accel-O-Rot shall not be liable for any indirect, incidental, special, consequential, or punitive damages arising from your use of the Service.',
            isMobile),
        
        _section('8. Compliance with RA 9003',
            'Our Service is designed to support compliance with Republic Act No. 9003 (Ecological Solid Waste Management Act of 2000). Users are responsible for ensuring their use of the Service aligns with local waste management regulations and requirements.',
            isMobile),
        
        _section('9. Modifications to Terms',
            'We reserve the right to modify these Terms at any time. We will notify users of significant changes via email or through the mobile application. Continued use of the Service after changes constitutes acceptance of the new Terms.',
            isMobile),
        
        _section('10. Governing Law',
            'These Terms shall be governed by and construed in accordance with the laws of the Republic of the Philippines, without regard to its conflict of law provisions.',
            isMobile),
        
        _section('11. Contact Information',
            'For questions about these Terms, please contact us at:', isMobile),
        _contactInfo(isMobile),
        const SizedBox(height: AppSpacing.lg),
      ],
    );
  }

  // Helper Widgets
  Widget _title(bool isMobile) => Text(
        'Terms of Service',
        style: TextStyle(
          fontSize: isMobile ? 20 : 24,
          fontWeight: FontWeight.w900,
          color: const Color(0xFF1F2937),
          height: 1.2,
        ),
      );

  Widget _lastUpdated() => Text(
        'Last updated: February 1, 2026',
        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
      );

  Widget _section(String title, String content, bool isMobile) => Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: TextStyle(
                  fontSize: isMobile ? 14 : 16,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1F2937),
                  height: 1.4,
                )),
            const SizedBox(height: AppSpacing.xs),
            Text(content,
                style: TextStyle(
                  fontSize: isMobile ? 12 : 14,
                  color: const Color(0xFF4B5563),
                  height: 1.6,
                )),
          ],
        ),
      );

  Widget _bullets(List<String> items, bool isMobile) => Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: items
              .map((item) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('• ',
                            style: TextStyle(
                                fontSize: 14,
                                color: Color(0xFF4B5563),
                                height: 1.6)),
                        Expanded(
                          child: Text(item,
                              style: TextStyle(
                                fontSize: isMobile ? 12 : 14,
                                color: const Color(0xFF4B5563),
                                height: 1.6,
                              )),
                        ),
                      ],
                    ),
                  ))
              .toList(),
        ),
      );

  Widget _contactInfo(bool isMobile) => Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _contactLine('Email:', 'accelorot.management@gmail.com', isMobile),
            const SizedBox(height: AppSpacing.xs),
            _contactLine('Phone:', '+63 951 000 7296', isMobile),
            const SizedBox(height: AppSpacing.xs),
            _contactLine(
                'Address:',
                'Congressional Rd Ext, Barangay 171, Caloocan City, Philippines',
                isMobile),
          ],
        ),
      );

  Widget _contactLine(String label, String value, bool isMobile) => RichText(
        text: TextSpan(
          style: TextStyle(
            fontSize: isMobile ? 12 : 14,
            color: const Color(0xFF4B5563),
            height: 1.6,
          ),
          children: [
            TextSpan(
                text: '$label ',
                style: const TextStyle(fontWeight: FontWeight.w600)),
            TextSpan(text: value),
          ],
        ),
      );
}