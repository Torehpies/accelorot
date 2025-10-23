import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../services/auth_service.dart';
import 'package:flutter_application_1/frontend/screens/main_navigation.dart';
import 'waiting_approval_screen.dart';
import 'login_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  Widget _buildJoinTeam() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 24),
            const Text(
              'Join a Team',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const Text(
              'Enter a referral code or scan a team QR code to request joining.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // Manual code entry
            TextField(
              controller: _codeController,
              decoration: const InputDecoration(
                labelText: 'Referral Code',
                border: OutlineInputBorder(),
              ),
              onChanged: (v) {
                setState(() {
                  _manualCode = v.trim();
                });
              },
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _manualCode.isNotEmpty
                  ? () => _submitReferralCode(_manualCode)
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
              ),
              child: const Text('Submit Code'),
            ),

            const SizedBox(height: 24),

            const Divider(),
            const SizedBox(height: 12),

            const Text(
              'Or scan QR code',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),

            // Scanner preview
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

            const SizedBox(height: 24),

            // Back to Login button
            TextButton(
              onPressed: _handleBackToLogin,
              child: const Text(
                'Back to Login',
                style: TextStyle(
                  color: Colors.teal,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Join a Team'),
        backgroundColor: Colors.teal,
      ),
      body: _buildJoinTeam(),
    );
  }
}