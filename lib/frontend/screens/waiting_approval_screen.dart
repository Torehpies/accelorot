import 'package:flutter/material.dart';
import 'package:flutter_application_1/services/auth_service.dart';
import 'package:flutter_application_1/frontend/screens/qr_refer.dart';
import 'package:flutter_application_1/frontend/screens/login_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class WaitingApprovalScreen extends StatefulWidget {
  const WaitingApprovalScreen({super.key});

  @override
  State<WaitingApprovalScreen> createState() => _WaitingApprovalScreenState();
}

class _WaitingApprovalScreenState extends State<WaitingApprovalScreen> {
  final AuthService _auth = AuthService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _loading = false;

  Future<void> _cancelRequest() async {
    final user = _auth.getCurrentUser();
    if (user == null) return;
    
    setState(() => _loading = true);

    try {
      // Get the pendingTeamId before clearing it
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      final pendingTeamId = userDoc.data()?['pendingTeamId'] as String?;

      if (pendingTeamId != null) {
        final batch = _firestore.batch();

        // 1. Remove from pending_members subcollection
        final pendingRef = _firestore
            .collection('teams')
            .doc(pendingTeamId)
            .collection('pending_members')
            .doc(user.uid);
        batch.delete(pendingRef);

        // 2. Clear pendingTeamId from user document
        final userRef = _firestore.collection('users').doc(user.uid);
        batch.update(userRef, {
          'pendingTeamId': FieldValue.delete(),
        });

        await batch.commit();
      }

      if (!mounted) return;
      
      // Navigate back to QR refer screen on next frame to ensure context is valid
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const QRReferScreen()),
        );
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error canceling request: $e')),
        );
      });
    }
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
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
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
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () async {
                  await _auth.signOut();
                  if (!mounted) return;
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (!mounted) return;
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                    );
                  });
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.teal),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Back to Login'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}