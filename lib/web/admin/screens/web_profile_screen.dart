// lib/web/screens/web_profile_screen.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../../../services/auth_wrapper.dart';
import '../../../frontend/components/edit_profile_modal.dart';
import '../../../frontend/components/change_password_modal.dart';
import '../../../frontend/screens/personal_info_screen.dart';
import '../../../services/sess_service.dart';
import 'web_login_screen.dart';

class WebProfileScreen extends StatefulWidget {
  const WebProfileScreen({super.key});

  @override
  State<WebProfileScreen> createState() => _WebProfileScreenState();
}

class _WebProfileScreenState extends State<WebProfileScreen> {
  final SessionService _session = SessionService();
  Map<String, dynamic>? _userData;
  bool _loading = true;

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => kIsWeb ? const WebLoginScreen() : const AuthWrapper()),
        (route) => false,
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final data = await _session.getCurrentUserData();
    if (mounted) {
      setState(() {
        _userData = data;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Compute display values with safe fallbacks
    final first = _userData != null && _userData!['firstname'] is String
        ? _userData!['firstname'] as String
        : FirebaseAuth.instance.currentUser?.displayName?.split(' ').first ?? '';
    final last = _userData != null && _userData!['lastname'] is String
        ? _userData!['lastname'] as String
        : FirebaseAuth.instance.currentUser?.displayName?.split(' ').skip(1).join(' ') ?? '';
    final displayName = [first, last].where((s) => s.isNotEmpty).join(' ').trim();
    final email = _userData != null && _userData!['email'] is String
        ? _userData!['email'] as String
        : FirebaseAuth.instance.currentUser?.email ?? '';

    // build initials for avatar placeholder
    final initials = ((first.isNotEmpty ? first[0] : '') + (last.isNotEmpty ? last[0] : '')).toUpperCase();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF2E7D32),
                      const Color(0xFF4CAF50),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    // Avatar
                    CircleAvatar(
                      radius: 60,
                      backgroundImage: NetworkImage(
                        'https://via.placeholder.com/150/2E7D32/FFFFFF?text=${initials.isNotEmpty ? initials : 'M'}',
                      ),
                    ),
                    const SizedBox(width: 32),

                    // User Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _loading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : Text(
                                  displayName.isNotEmpty ? displayName : 'No name',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                          const SizedBox(height: 8),
                          Text(
                            email,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              _userData?['role'] ?? 'User',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Profile Actions Grid
            Text(
              "Account Settings",
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.teal[800],
              ),
            ),
            const SizedBox(height: 16),

            GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 24,
              mainAxisSpacing: 24,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildActionCard(
                  context,
                  icon: Icons.edit,
                  title: "Edit Profile",
                  description: "Update your personal information",
                  onPressed: () {
                    final first = _userData != null && _userData!['firstname'] is String
                        ? _userData!['firstname'] as String
                        : FirebaseAuth.instance.currentUser?.displayName?.split(' ').first ?? '';
                    final last = _userData != null && _userData!['lastname'] is String
                        ? _userData!['lastname'] as String
                        : FirebaseAuth.instance.currentUser?.displayName?.split(' ').skip(1).join(' ') ?? '';

                    showDialog(
                      context: context,
                      builder: (context) => EditProfileModal(
                        firstName: first.isNotEmpty ? first : 'Miguel Andres',
                        lastName: last.isNotEmpty ? last : 'Reyes',
                        username: FirebaseAuth.instance.currentUser?.displayName ?? '',
                        role: _userData?['role'] ?? 'User',
                      ),
                    );
                  },
                ),

                _buildActionCard(
                  context,
                  icon: Icons.lock,
                  title: "Change Password",
                  description: "Update your account security",
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => const ChangePasswordModal(),
                    );
                  },
                ),

                _buildActionCard(
                  context,
                  icon: Icons.info,
                  title: "Personal Info",
                  description: "View detailed account information",
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PersonalInfoScreen(),
                      ),
                    );
                  },
                ),

                _buildActionCard(
                  context,
                  icon: Icons.help,
                  title: "Help & Support",
                  description: "Get help and contact support",
                  onPressed: () {
                    // TODO: Implement help screen
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Help & Support coming soon!')),
                    );
                  },
                ),
              ],
            ),

            const SizedBox(height: 48),

            // Account Actions
            Text(
              "Account Actions",
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.teal[800],
              ),
            ),
            const SizedBox(height: 16),

            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  children: [
                    const Icon(
                      Icons.logout,
                      color: Colors.red,
                      size: 28,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Sign Out",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                          ),
                          Text(
                            "Sign out of your account",
                            style: TextStyle(
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        await _signOut();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text("Sign Out"),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required VoidCallback onPressed,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.teal[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: Colors.teal[700],
                  size: 24,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}