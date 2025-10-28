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

  Widget _buildJoinTeam() {
    final isWeb = kIsWeb;
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 600;

    return Center(
      child: Container(
        constraints: BoxConstraints(
          maxWidth: isDesktop ? 600 : double.infinity,
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(isDesktop ? 32.0 : 24.0),
            child: Card(
              elevation: isDesktop ? 8 : 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(isDesktop ? 20 : 0),
              ),
              child: Padding(
                padding: EdgeInsets.all(isDesktop ? 40.0 : 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Logo
                    if (isDesktop) ...[
                      Center(
                        child: Container(
                          width: 80,
                          height: 80,
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
                          child: const Icon(Icons.trending_up, size: 36, color: Colors.white),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ] else
                      const SizedBox(height: 24),

                    Text(
                      'Join a Team',
                      style: TextStyle(
                        fontSize: isDesktop ? 32 : 26,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: isDesktop ? 16 : 12),
                    Text(
                      'Enter a referral code or scan a team QR code to request joining.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: isDesktop ? 16 : 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: isDesktop ? 32 : 24),

                    // Manual code entry
                    TextField(
                      controller: _codeController,
                      decoration: InputDecoration(
                        labelText: 'Referral Code',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.qr_code),
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
                          padding: EdgeInsets.symmetric(
                            vertical: isDesktop ? 18 : 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 4,
                        ),
                        child: Text(
                          'Submit Code',
                          style: TextStyle(
                            fontSize: isDesktop ? 16 : 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: isDesktop ? 32 : 24),

                    const Divider(),
                    SizedBox(height: isDesktop ? 20 : 12),

                    Text(
                      isWeb ? 'Or enter QR code manually' : 'Or scan QR code',
                      style: TextStyle(
                        fontSize: isDesktop ? 20 : 18,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: isDesktop ? 16 : 12),

                    // Scanner preview (hide on web)
                    if (!isWeb) ...[
                      SizedBox(
                        height: isDesktop ? 350 : 300,
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

                    SizedBox(height: isDesktop ? 32 : 24),

                    // Back to Login button
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: _handleBackToLogin,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.teal,
                          side: const BorderSide(color: Colors.teal),
                          padding: EdgeInsets.symmetric(
                            vertical: isDesktop ? 18 : 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Back to Login',
                          style: TextStyle(
                            fontSize: isDesktop ? 16 : 14,
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_teamId != null) {
      return const Scaffold(body: Center(child: Text('Redirecting to dashboard...')));
    }

    if (_pendingTeamId != null) {
      return const WaitingApprovalScreen();
    }

    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 600;

    return Scaffold(
      appBar: isDesktop
          ? null
          : AppBar(
              title: const Text('Join a Team'),
              backgroundColor: Colors.teal,
            ),
      body: _buildJoinTeam(),
    );
  }
}