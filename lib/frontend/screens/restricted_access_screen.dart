// lib/frontend/screens/restricted_access_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login_screen.dart';
import 'qr_refer.dart';

class RestrictedAccessScreen extends StatefulWidget {
  final String reason;
  final String? teamName;

  const RestrictedAccessScreen({
    super.key,
    required this.reason,
    this.teamName,
  });

  @override
  State<RestrictedAccessScreen> createState() => _RestrictedAccessScreenState();
}

class _RestrictedAccessScreenState extends State<RestrictedAccessScreen> {
  bool _isLeaving = false;

  Future<void> _leaveTeamPermanently() async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Leave Team Permanently?'),
        content: const Text(
          'This will remove you from the team completely. You will need a new invitation code to rejoin.\n\n'
          'Are you sure you want to continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Leave Team'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isLeaving = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('No user logged in');
      }

      final firestore = FirebaseFirestore.instance;

      // Find the team this user is a member of
      final teamsSnapshot = await firestore.collection('teams').get();

      for (var teamDoc in teamsSnapshot.docs) {
        final memberDoc = await firestore
            .collection('teams')
            .doc(teamDoc.id)
            .collection('members')
            .doc(user.uid)
            .get();

        if (memberDoc.exists) {
          final batch = firestore.batch();

          // 1. Mark as "hasLeft" in team members
          final memberRef = firestore
              .collection('teams')
              .doc(teamDoc.id)
              .collection('members')
              .doc(user.uid);
          batch.update(memberRef, {
            'hasLeft': true,
            'leftAt': FieldValue.serverTimestamp(),
          });

          // 2. Remove teamId from user document
          final userRef = firestore.collection('users').doc(user.uid);
          batch.update(userRef, {
            'teamId': FieldValue.delete(),
          });

          await batch.commit();

          if (!mounted) return;

          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ You have left the team permanently'),
              backgroundColor: Colors.green,
            ),
          );

          // Navigate to QR Refer screen
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => const QRReferScreen(),
            ),
            (route) => false,
          );
          return;
        }
      }

      // If we get here, user wasn't found in any team
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error: Team membership not found'),
          backgroundColor: Colors.orange,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error leaving team: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLeaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Icon
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: widget.reason == 'archived'
                            ? Colors.orange.shade100
                            : Colors.red.shade100,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        widget.reason == 'archived'
                            ? Icons.lock
                            : Icons.exit_to_app,
                        size: 40,
                        color: widget.reason == 'archived'
                            ? Colors.orange.shade700
                            : Colors.red.shade700,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Title
                    Text(
                      widget.reason == 'archived'
                          ? 'Account Archived'
                          : 'Team Access Removed',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),

                    // Message
                    Text(
                      _getMessage(),
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),

                    // Leave Team Button (only for archived users)
                    if (widget.reason == 'archived') ...[
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _isLeaving ? null : _leaveTeamPermanently,
                          icon: _isLeaving
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : const Icon(Icons.exit_to_app),
                          label: Text(
                            _isLeaving
                                ? 'Leaving...'
                                : 'Leave Team Permanently',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12), 
                    ],

                    // Back to Login Button
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: _isLeaving
                            ? null
                            : () async {
                                await FirebaseAuth.instance.signOut();
                                if (!context.mounted) return;
                                Navigator.of(context).pushAndRemoveUntil(
                                  MaterialPageRoute(
                                    builder: (context) => const LoginScreen(),
                                  ),
                                  (route) => false,
                                );
                              },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.teal,
                          side: const BorderSide(color: Colors.teal),
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
      ),
    );
  }

  String _getMessage() {
    if (widget.reason == 'archived') {
      return 'Your account has been temporarily archived by an administrator.\n\n'
          'You can choose to:\n'
          '• Wait for the admin to restore your access\n'
          '• Leave the team permanently and request a new invitation';
    } else {
      return 'You have been removed from ${widget.teamName ?? 'the team'}.\n\n'
          'To rejoin, please request a new invitation code from the team administrator.';
    }
  }
}