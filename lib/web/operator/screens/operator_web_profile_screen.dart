// lib/frontend/operator/web/web_profile_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_application_1/frontend/screens/Onboarding/login_screen.dart';
import '../../../services/auth_wrapper.dart';
import '../../../services/sess_service.dart';
import '../../operator/widgets/profile_header_widget.dart';
import '../../operator/widgets/profile_edit_form_widget.dart';
import '../../operator/widgets/profile_info_view_widget.dart';

class WebProfileScreen extends StatefulWidget {
  const WebProfileScreen({super.key});

  @override
  State<WebProfileScreen> createState() => _WebProfileScreenState();
}

class _WebProfileScreenState extends State<WebProfileScreen> {
  final SessionService _session = SessionService();
  Map<String, dynamic>? _userData;
  bool _loading = true;
  bool _isEditing = false;

  // Controllers for form fields
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _fullNameController = TextEditingController();

  // ignore: unused_element
  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => kIsWeb ? const LoginScreen() : const AuthWrapper()),
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
        _usernameController.text = displayName;
        _fullNameController.text = fullName;
      });
    }
  }

  // Compute display values with safe fallbacks
  String get firstName => _userData != null && _userData!['firstname'] is String
      ? _userData!['firstname'] as String
      : FirebaseAuth.instance.currentUser?.displayName?.split(' ').first ?? 'Miguel';

  String get lastName => _userData != null && _userData!['lastname'] is String
      ? _userData!['lastname'] as String
      : FirebaseAuth.instance.currentUser?.displayName?.split(' ').skip(1).join(' ') ?? 'Reyes';

  String get email => _userData != null && _userData!['email'] is String
      ? _userData!['email'] as String
      : FirebaseAuth.instance.currentUser?.email ?? 'user@example.com';

  String get role => _userData?['role'] ?? 'User';

  String get displayName => [firstName, lastName].where((s) => s.isNotEmpty).join(' ').trim();

  String get fullName => '$firstName $lastName'.trim();

  String get initials => ((firstName.isNotEmpty ? firstName[0] : '') + (lastName.isNotEmpty ? lastName[0] : '')).toUpperCase();

  Future<void> _saveProfile() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final nameParts = _fullNameController.text.trim().split(' ');
      final newFirstName = nameParts.isNotEmpty ? nameParts.first : '';
      final newLastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({
        'firstname': newFirstName,
        'lastname': newLastName,
      });

      await _loadUser();

      if (mounted) {
        setState(() {
          _isEditing = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully!'),
            backgroundColor: Colors.teal,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving profile: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _handleDiscard() {
    setState(() {
      _isEditing = false;
      _usernameController.text = displayName;
      _fullNameController.text = fullName;
    });
  }

  void _handleEdit() {
    setState(() {
      _isEditing = true;
      _usernameController.text = displayName;
      _fullNameController.text = fullName;
    });
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _fullNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
  title: const Text(
    'Profile',
    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
  ),
  automaticallyImplyLeading: false,
  centerTitle: false,
  flexibleSpace: Container(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [Colors.teal.shade700, Colors.teal.shade900],
      ),
    ),
  ),
  foregroundColor: Colors.white,
  elevation: 0,
  actions: [], // <-- Now empty; notification icon removed
),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(32.0),
              child: Align(
                alignment: Alignment.center,
                child: Card(
                  elevation: 4,
                  color: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ProfileHeaderWidget(
                          initials: initials,
                          displayName: displayName,
                          email: email,
                          role: role,
                        ),
                        const SizedBox(height: 32),
                        Divider(color: Colors.grey[300]),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Personal Information',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey[800],
                                  ),
                            ),
                            if (!_isEditing)
                              ElevatedButton(
                                onPressed: _handleEdit,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.teal,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: const Text('Edit Profile'),
                              ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        if (_isEditing)
                          ProfileEditFormWidget(
                            usernameController: _usernameController,
                            fullNameController: _fullNameController,
                            email: email,
                            role: role,
                            onSave: _saveProfile,
                            onDiscard: _handleDiscard,
                          )
                        else
                          ProfileInfoViewWidget(
                            displayName: displayName,
                            fullName: fullName,
                            email: email,
                            role: role,
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
