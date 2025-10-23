import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../services/auth_service.dart';
import 'package:flutter_application_1/frontend/screens/main_navigation.dart';

class QRReferScreen extends StatefulWidget {
  const QRReferScreen({super.key});

  @override
  State<QRReferScreen> createState() => _QRReferScreenState();
}

class _QRReferScreenState extends State<QRReferScreen> {
  final AuthService _auth = AuthService();
  bool _loading = true;
  String? _teamId;
  String? _pendingTeamId;
  bool _scanning = false;
  String _manualCode = '';

  @override
  void initState() {
    super.initState();
    _checkTeamStatus();
  }

  Future<void> _checkTeamStatus() async {
    final user = _auth.getCurrentUser();
    if (user == null) {
      // If no user, navigate to login or show simple message
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
      // Navigate to main navigation (operator dashboard)
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
      await _auth.setPendingTeamId(user.uid, code);
      if (!mounted) return;
      setState(() {
        _pendingTeamId = code;
      });
      // Show waiting for approval
    } catch (e) {
      // show simple error
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to submit code: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _scanning = false;
        });
      }
    }
  }

  Widget _buildWaiting() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.hourglass_top, size: 72, color: Colors.orange),
            const SizedBox(height: 16),
            const Text(
              'Waiting for Approval',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Your request to join the team is pending. An admin will review and approve your request shortly.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final user = _auth.getCurrentUser();
                if (user == null) return;
                await _auth.clearPendingTeamId(user.uid);
                setState(() {
                  _pendingTeamId = null;
                });
              },
              child: const Text('Cancel Request'),
            ),
          ],
        ),
      ),
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
              decoration: const InputDecoration(
                labelText: 'Referral Code',
                border: OutlineInputBorder(),
              ),
              onChanged: (v) => _manualCode = v.trim(),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _manualCode.isNotEmpty
                  ? () => _submitReferralCode(_manualCode)
                  : null,
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
      // should have already navigated, but show placeholder
      return const Scaffold(body: Center(child: Text('Redirecting to dashboard...')));
    }

    if (_pendingTeamId != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Team Status')),
        body: _buildWaiting(),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Join a Team')),
      body: _buildJoinTeam(),
    );
  }
}