// lib/frontend/screens/restricted_access_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login_screen.dart';
import 'qr_refer.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_application_1/web/admin/screens/web_login_screen.dart';

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
            'This will remove you from the team completely. You will need a new invitation code to rejoin.\n\n'
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
    final screenWidth = MediaQuery.of(context).size.width;
    final isWebDesktop = kIsWeb && screenWidth > 900;

    if (isWebDesktop) {
      return _buildWebLayout();
    } else {
      return _buildMobileLayout();
    }
  }

  Widget _buildWebLayout() {
    final isArchived = widget.reason == 'archived';
    
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
                  colors: isArchived
                      ? [Colors.orange.shade700, Colors.orange.shade900]
                      : [Colors.red.shade700, Colors.red.shade900],
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
                        child: Icon(
                          isArchived ? Icons.lock : Icons.exit_to_app,
                          size: 64,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 40),
                      Text(
                        isArchived ? 'Account Archived' : 'Access Removed',
                        style: const TextStyle(
                          fontSize: 42,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        isArchived
                            ? 'Your account has been temporarily archived by an administrator. You can wait for restoration or leave the team permanently.'
                            : 'You have been removed from the team. Contact your team administrator for a new invitation code to rejoin.',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white.withValues(alpha: 0.9),
                          height: 1.6,
                        ),
                      ),
                      const SizedBox(height: 40),
                      _buildFeatureItem(
                        isArchived
                            ? 'Account temporarily disabled'
                            : 'Team access revoked',
                      ),
                      const SizedBox(height: 16),
                      _buildFeatureItem(
                        isArchived
                            ? 'Can be restored by admin'
                            : 'New invitation required',
                      ),
                      const SizedBox(height: 16),
                      _buildFeatureItem(
                        isArchived
                            ? 'Or leave permanently'
                            : 'Contact team administrator',
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Right side - Actions
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
                        Text(
                          isArchived ? 'Account Archived' : 'Team Access Removed',
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1A202C),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'What would you like to do?',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Status container
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: isArchived
                                ? Colors.orange.shade50
                                : Colors.red.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isArchived
                                  ? Colors.orange.shade200
                                  : Colors.red.shade200,
                            ),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                isArchived ? Icons.lock : Icons.exit_to_app,
                                size: 64,
                                color: isArchived
                                    ? Colors.orange.shade700
                                    : Colors.red.shade700,
                              ),
                              const SizedBox(height: 20),
                              Text(
                                _getMessage(),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 15,
                                  color: isArchived
                                      ? Colors.orange.shade900
                                      : Colors.red.shade900,
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Leave Team Button (only for archived users)
                        if (isArchived) ...[
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton.icon(
                              onPressed: _isLeaving ? null : _leaveTeamPermanently,
                              icon: _isLeaving
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation(
                                          Colors.white,
                                        ),
                                      ),
                                    )
                                  : const Icon(Icons.exit_to_app),
                              label: Text(
                                _isLeaving ? 'Leaving...' : 'Leave Team Permanently',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 0,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],

                        // Back to Login Button
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: OutlinedButton.icon(
                            onPressed: _isLeaving
                                ? null
                                : () async {
                                    await FirebaseAuth.instance.signOut();
                                    if (!mounted) return;
                                    Navigator.of(context).pushAndRemoveUntil(
                                      MaterialPageRoute(
                                        builder: (context) => kIsWeb
                                            ? const WebLoginScreen()
                                            : const LoginScreen(),
                                      ),
                                      (route) => false,
                                    );
                                  },
                            icon: const Icon(Icons.arrow_back, size: 18),
                            label: const Text(
                              'Back to Login',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.teal,
                              side: const BorderSide(color: Colors.teal, width: 2),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
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
          child: const Icon(Icons.info, color: Colors.white, size: 16),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout() {
    final isArchived = widget.reason == 'archived';

    return Scaffold(
      backgroundColor: Colors.grey[50],
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
                      color: isArchived
                          ? Colors.orange.shade100
                          : Colors.red.shade100,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: isArchived
                              ? Colors.orange.withValues(alpha: 0.3)
                              : Colors.red.withValues(alpha: 0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Icon(
                      isArchived ? Icons.lock : Icons.exit_to_app,
                      size: 50,
                      color: isArchived
                          ? Colors.orange.shade700
                          : Colors.red.shade700,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Title
                  Text(
                    isArchived ? 'Account Archived' : 'Team Access Removed',
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
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                      height: 1.6,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),

                  // Info box
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isArchived
                          ? Colors.orange.shade50
                          : Colors.red.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isArchived
                            ? Colors.orange.shade200
                            : Colors.red.shade200,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: isArchived
                              ? Colors.orange.shade700
                              : Colors.red.shade700,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            isArchived
                                ? 'You can wait for admin to restore access or leave the team.'
                                : 'Contact your team administrator for a new invitation.',
                            style: TextStyle(
                              fontSize: 14,
                              color: isArchived
                                  ? Colors.orange.shade900
                                  : Colors.red.shade900,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Leave Team Button (only for archived users)
                  if (isArchived) ...[
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
                          _isLeaving ? 'Leaving...' : 'Leave Team Permanently',
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
                          elevation: 4,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Back to Login Button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: _isLeaving
                          ? null
                          : () async {
                              await FirebaseAuth.instance.signOut();
                              if (!mounted) return;
                              Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(
                                  builder: (context) => kIsWeb
                                      ? const WebLoginScreen()
                                      : const LoginScreen(),
                                ),
                                (route) => false,
                              );
                            },
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