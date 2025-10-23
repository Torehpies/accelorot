import 'package:flutter/material.dart';
import 'package:flutter_application_1/services/auth_service.dart';
import 'package:flutter_application_1/frontend/screens/qr_refer.dart';

class WaitingApprovalScreen extends StatefulWidget {
  const WaitingApprovalScreen({super.key});

  @override
  State<WaitingApprovalScreen> createState() => _WaitingApprovalScreenState();
}

class _WaitingApprovalScreenState extends State<WaitingApprovalScreen> {
  final AuthService _auth = AuthService();
  bool _loading = false;

  Future<void> _cancelRequest() async {
    final user = _auth.getCurrentUser();
    if (user == null) return;
    setState(() => _loading = true);
    await _auth.clearPendingTeamId(user.uid);
    if (!mounted) return;
    // After cancelling, send user to join screen
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const QRReferScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Waiting for Approval'),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(Icons.hourglass_top, size: 72, color: Colors.teal),
            const SizedBox(height: 24),
            const Text(
              'Your request to join a team is pending approval.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 16),
            const Text(
              'An admin will review your request. You will be added to the team once approved.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : _cancelRequest,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                child: _loading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(Colors.white),
                        ),
                      )
                    : const Text('Cancel Request'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
