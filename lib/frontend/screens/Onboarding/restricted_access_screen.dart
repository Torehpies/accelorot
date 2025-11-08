import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login_screen.dart';
import 'team_selection_screen.dart';

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
      builder: (context) {
        final screenWidth = MediaQuery.of(context).size.width;
        final isDesktop = screenWidth > 600;

        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Leave Team Permanently?',
            style: TextStyle(
              fontSize: isDesktop ? 22 : 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'This will remove you from the team completely. You can request to join another team or rejoin this one later.\n\n'
            'Are you sure you want to continue?',
            style: TextStyle(
              fontSize: isDesktop ? 16 : 14,
              height: 1.5,
            ),
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
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Leave Team'),
            ),
          ],
        );
      },
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

          // Navigate to Team Selection screen
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => const TeamSelectionScreen(),
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
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 600;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Center(
          child: Container(
            constraints: BoxConstraints(
              maxWidth: isDesktop ? 600 : double.infinity,
            ),
            padding: EdgeInsets.all(isDesktop ? 32.0 : 24.0),
            child: Card(
              elevation: isDesktop ? 10 : 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: EdgeInsets.all(isDesktop ? 48.0 : 32.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Icon
                    Container(
                      width: isDesktop ? 100 : 80,
                      height: isDesktop ? 100 : 80,
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
                        size: isDesktop ? 50 : 40,
                        color: widget.reason == 'archived'
                            ? Colors.orange.shade700
                            : Colors.red.shade700,
                      ),
                    ),
                    SizedBox(height: isDesktop ? 32 : 24),

                    // Title
                    Text(
                      widget.reason == 'archived'
                          ? 'Account Archived'
                          : 'Team Access Removed',
                      style: TextStyle(
                        fontSize: isDesktop ? 28 : 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: isDesktop ? 20 : 16),

                    // Message
                    Text(
                      _getMessage(),
                      style: TextStyle(
                        fontSize: isDesktop ? 16 : 14,
                        color: Colors.grey[700],
                        height: 1.6,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: isDesktop ? 48 : 32),

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
                            style: TextStyle(
                              fontSize: isDesktop ? 16 : 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(
                              vertical: isDesktop ? 18 : 16,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 4,
                          ),
                        ),
                      ),
                      SizedBox(height: isDesktop ? 16 : 12),
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
                          side: const BorderSide(color: Colors.teal, width: 2),
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

  String _getMessage() {
    if (widget.reason == 'archived') {
      return 'Your account has been temporarily archived by an administrator.\n\n'
          'You can choose to:\n'
          '• Wait for the admin to restore your access\n'
          '• Leave the team permanently and request to join another team';
    } else {
      return 'You have been removed from ${widget.teamName ?? 'the team'}.\n\n'
          'To rejoin or join another team, please select from the available teams.';
    }
  }
}
