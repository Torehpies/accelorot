import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../services/auth_service.dart';
import 'package:flutter_application_1/frontend/operator/main_navigation.dart';
import 'waiting_approval_screen.dart';
import 'login_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_application_1/web/admin/screens/web_login_screen.dart';

class QRReferScreen extends StatefulWidget {
  const QRReferScreen({super.key});

  @override
  State<QRReferScreen> createState() => _QRReferScreenState();
}

class _QRReferScreenState extends State<QRReferScreen> {
  final AuthService _auth = AuthService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _loading = true;
  String? _teamId;
  String? _pendingTeamId;
  bool _scanning = false;
  String _manualCode = '';
  final TextEditingController _codeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _checkTeamStatus();
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _checkTeamStatus() async {
    final user = _auth.getCurrentUser();
    if (user == null) {
      if (!mounted) return;
      setState(() {
        _loading = false;
      });
      return;
    }

    final status = await _auth.getUserTeamStatus(user.uid);
    if (!mounted) return;
    setState(() {
      _teamId = status['teamId'] as String?;
      _pendingTeamId = status['pendingTeamId'] as String?;
      _loading = false;
    });

    // Redirect immediately if already assigned
    if (_teamId != null) {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => const MainNavigation(),
        ),
      );
    }
  }

  void _onDetect(BarcodeCapture capture) async {
    if (_scanning) return;
    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;
    final code = barcodes.first.rawValue ?? '';
    if (code.isEmpty) return;
    setState(() {
      _scanning = true;
    });
    await _submitReferralCode(code);
  }

  Future<void> _submitReferralCode(String code) async {
    final user = _auth.getCurrentUser();
    if (user == null) return;

    try {
      // 1. Find the team with this joinCode
      final teamsQuery = await _firestore
          .collection('teams')
          .where('joinCode', isEqualTo: code)
          .limit(1)
          .get();

      if (teamsQuery.docs.isEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid referral code')),
        );
        setState(() => _scanning = false);
        return;
      }

      final teamDoc = teamsQuery.docs.first;
      final teamId = teamDoc.id;
      final teamData = teamDoc.data();

      // 2. Check if code is expired
      final expiresAt = teamData['joinCodeExpiresAt'] as Timestamp?;
      if (expiresAt != null && expiresAt.toDate().isBefore(DateTime.now())) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('This referral code has expired')),
        );
        setState(() => _scanning = false);
        return;
      }

      // 3. Add to pending_members subcollection
      await _firestore
          .collection('teams')
          .doc(teamId)
          .collection('pending_members')
          .doc(user.uid)
          .set({
        'requestorId': user.uid,
        'requestorEmail': user.email ?? '',
        'requestedAt': FieldValue.serverTimestamp(),
      });

      // 4. Set pendingTeamId in user document
      await _auth.setPendingTeamId(user.uid, teamId);

      if (!mounted) return;
      setState(() {
        _pendingTeamId = teamId;
        _scanning = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Request submitted! Waiting for approval.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to submit code: $e')),
      );
      setState(() => _scanning = false);
    }
  }

  Future<void> _handleBackToLogin() async {
    await _auth.signOut();
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => kIsWeb
            ? const WebLoginScreen()
            : const LoginScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWebDesktop = kIsWeb && screenWidth > 900;

    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_teamId != null) {
      return const Scaffold(body: Center(child: Text('Redirecting to dashboard...')));
    }

    if (_pendingTeamId != null) {
      return const WaitingApprovalScreen();
    }

    if (isWebDesktop) {
      return _buildWebLayout();
    } else {
      return _buildMobileLayout();
    }
  }

  Widget _buildWebLayout() {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Row(
        children: [
          // Left side - Branding
          Expanded(
            flex: 5,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.teal.shade700,
                    Colors.teal.shade900,
                  ],
                ),
              ),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(60),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(
                          Icons.qr_code_scanner,
                          size: 64,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 40),
                      const Text(
                        'Join Your Team',
                        style: TextStyle(
                          fontSize: 42,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Enter your team\'s invitation code to request access. An administrator will review your request.',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white.withValues(alpha: 0.9),
                          height: 1.6,
                        ),
                      ),
                      const SizedBox(height: 40),
                      _buildFeatureItem('Secure team access'),
                      const SizedBox(height: 16),
                      _buildFeatureItem('Admin approval required'),
                      const SizedBox(height: 16),
                      _buildFeatureItem('One-time invitation code'),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Right side - Form
          Expanded(
            flex: 4,
            child: Container(
              color: Colors.white,
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(60),
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 480),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Join a Team',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1A202C),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Enter your team invitation code below',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Manual code entry
                        TextField(
                          controller: _codeController,
                          decoration: InputDecoration(
                            labelText: 'Invitation Code',
                            hintText: 'Enter code here',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            prefixIcon: const Icon(Icons.qr_code),
                            filled: true,
                            fillColor: Colors.grey[50],
                          ),
                          onChanged: (v) {
                            setState(() {
                              _manualCode = v.trim();
                            });
                          },
                        ),
                        const SizedBox(height: 24),

                        // Submit button
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton.icon(
                            onPressed: _manualCode.isNotEmpty
                                ? () => _submitReferralCode(_manualCode)
                                : null,
                            icon: const Icon(Icons.login),
                            label: const Text(
                              'Submit Code',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.teal,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Info box
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.blue.shade100),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.info_outline, color: Colors.blue.shade700),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'QR code scanning is not available on web. Please ask your team administrator for the invitation code.',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.blue.shade900,
                                    height: 1.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Back to Login
                        Center(
                          child: TextButton.icon(
                            onPressed: _handleBackToLogin,
                            icon: const Icon(Icons.arrow_back, size: 18),
                            label: const Text(
                              'Back to Login',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.grey[700],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(String text) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(6),
          ),
          child: const Icon(Icons.check, color: Colors.white, size: 16),
        ),
        const SizedBox(width: 12),
        Text(
          text,
          style: TextStyle(
            fontSize: 16,
            color: Colors.white.withValues(alpha: 0.9),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout() {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Join a Team'),
        backgroundColor: Colors.teal,
        elevation: 0,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 500),
              child: Column(
                children: [
                  // Icon
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.teal.shade400, Colors.teal.shade700],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.teal.withValues(alpha: 0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.qr_code_scanner, size: 40, color: Colors.white),
                  ),
                  const SizedBox(height: 24),

                  const Text(
                    'Join Your Team',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),

                  const Text(
                    'Enter a referral code or scan a team QR code to request joining.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 24),

                  // Manual code entry
                  TextField(
                    controller: _codeController,
                    decoration: InputDecoration(
                      labelText: 'Invitation Code',
                      hintText: 'Enter code here',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.qr_code),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    onChanged: (v) {
                      setState(() {
                        _manualCode = v.trim();
                      });
                    },
                  ),
                  const SizedBox(height: 16),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _manualCode.isNotEmpty
                          ? () => _submitReferralCode(_manualCode)
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 4,
                      ),
                      child: const Text(
                        'Submit Code',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 12),

                  Text(
                    kIsWeb ? 'Or enter QR code manually' : 'Or scan QR code',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),

                  // Scanner preview (hide on web)
                  if (!kIsWeb) ...[
                    SizedBox(
                      height: 300,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: MobileScanner(
                          onDetect: _onDetect,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (_scanning) const Center(child: CircularProgressIndicator()),
                  ] else
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.qr_code_scanner,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'QR scanning is not available on web.\nPlease enter the code manually above.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 24),

                  // Back to Login button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: _handleBackToLogin,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.teal,
                        side: const BorderSide(color: Colors.teal, width: 2),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Back to Login',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}