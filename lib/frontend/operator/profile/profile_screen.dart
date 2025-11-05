// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../services/auth_wrapper.dart';
import 'package:flutter_application_1/services/sess_service.dart';
import 'change_password_dialog.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final SessionService _session = SessionService();
  Map<String, dynamic>? _userData;
  bool _loading = true;
  bool _isEditing = false;

  // Controllers for form fields
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _roleController = TextEditingController();

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const AuthWrapper()),
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
        _firstNameController.text = firstName;
        _lastNameController.text = lastName;
        _emailController.text = email;
        _roleController.text = role;
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

      final newFirstName = _firstNameController.text.trim();
      final newLastName = _lastNameController.text.trim();

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

  @override
  void dispose() {
    _usernameController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _roleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;
    
    // Responsive spacing values
    final cardPadding = isSmallScreen ? 16.0 : 24.0;
    final outerPadding = isSmallScreen ? 12.0 : 16.0;
    final avatarRadius = isSmallScreen ? 40.0 : 50.0;
    final verticalSpacing = isSmallScreen ? 8.0 : 12.0;
    final sectionSpacing = isSmallScreen ? 16.0 : 20.0;

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
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(outerPadding),
              child: Column(
                children: [
                  Card(
                    elevation: 4,
                    color: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: EdgeInsets.all(cardPadding),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Profile Header
                          Center(
                            child: Column(
                              children: [
                                CircleAvatar(
                                  radius: avatarRadius,
                                  backgroundImage: NetworkImage(
                                    'https://via.placeholder.com/150/2E7D32/FFFFFF?text=$initials',
                                  ),
                                ),
                                SizedBox(height: verticalSpacing),
                                Text(
                                  displayName,
                                  style: TextStyle(
                                    fontSize: isSmallScreen ? 20 : 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: verticalSpacing * 0.5),
                                Text(
                                  email,
                                  style: TextStyle(
                                    fontSize: isSmallScreen ? 14 : 16,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                SizedBox(height: verticalSpacing * 0.5),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: isSmallScreen ? 10 : 12,
                                    vertical: isSmallScreen ? 4 : 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.teal[50],
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    role,
                                    style: TextStyle(
                                      color: Colors.teal[800],
                                      fontSize: isSmallScreen ? 12 : 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: sectionSpacing),
                          Divider(color: Colors.grey[300]),
                          SizedBox(height: sectionSpacing),
                          
                          // Personal Information Header
                          Text(
                            'Personal Information',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: isSmallScreen ? 18 : 22,
                                  color: Colors.grey[800],
                                ),
                          ),
                          SizedBox(height: sectionSpacing),
                          
                          // Form Fields (Vertical Stack)
                          if (_isEditing)
                            Form(
                              child: Column(
                                children: [
                                  TextFormField(
                                    controller: _usernameController,
                                    decoration: const InputDecoration(
                                      labelText: 'Username',
                                      border: OutlineInputBorder(),
                                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                    ),
                                  ),
                                  SizedBox(height: verticalSpacing),
                                  TextFormField(
                                    controller: _firstNameController,
                                    decoration: const InputDecoration(
                                      labelText: 'First Name',
                                      border: OutlineInputBorder(),
                                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                    ),
                                  ),
                                  SizedBox(height: verticalSpacing),
                                  TextFormField(
                                    controller: _lastNameController,
                                    decoration: const InputDecoration(
                                      labelText: 'Last Name',
                                      border: OutlineInputBorder(),
                                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                    ),
                                  ),
                                  SizedBox(height: verticalSpacing),
                                  TextFormField(
                                    controller: _emailController,
                                    decoration: InputDecoration(
                                      labelText: 'Email Address',
                                      border: const OutlineInputBorder(),
                                      filled: true,
                                      fillColor: Colors.grey[200],
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                    ),
                                    enabled: false,
                                  ),
                                  SizedBox(height: verticalSpacing),
                                  TextFormField(
                                    controller: _roleController,
                                    decoration: InputDecoration(
                                      labelText: 'Role',
                                      border: const OutlineInputBorder(),
                                      filled: true,
                                      fillColor: Colors.grey[200],
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                    ),
                                    enabled: false,
                                  ),
                                  SizedBox(height: sectionSpacing),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      OutlinedButton(
                                        onPressed: () {
                                          setState(() {
                                            _isEditing = false;
                                            _usernameController.text = displayName;
                                            _firstNameController.text = firstName;
                                            _lastNameController.text = lastName;
                                          });
                                        },
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: Colors.teal,
                                          side: BorderSide(color: Colors.teal),
                                          backgroundColor: Colors.white,
                                          padding: EdgeInsets.symmetric(
                                            horizontal: isSmallScreen ? 16 : 20,
                                            vertical: isSmallScreen ? 10 : 12,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                        ),
                                        child: const Text('Discard'),
                                      ),
                                      SizedBox(width: verticalSpacing),
                                      ElevatedButton(
                                        onPressed: _saveProfile,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.teal,
                                          foregroundColor: Colors.white,
                                          padding: EdgeInsets.symmetric(
                                            horizontal: isSmallScreen ? 16 : 20,
                                            vertical: isSmallScreen ? 10 : 12,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                        ),
                                        child: const Text('Save'),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            )
                          else
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildInfoField('Username', displayName, isSmallScreen),
                                SizedBox(height: verticalSpacing),
                                _buildInfoField('Full Name', fullName, isSmallScreen),
                                SizedBox(height: verticalSpacing),
                                _buildInfoField('Email Address', email, isSmallScreen),
                                SizedBox(height: verticalSpacing),
                                _buildInfoField('Role', role, isSmallScreen),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ),
                  
                  // Bottom Buttons (Outside Card)
                  if (!_isEditing) ...[
                    SizedBox(height: verticalSpacing),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _isEditing = true;
                            _usernameController.text = displayName;
                            _firstNameController.text = firstName;
                            _lastNameController.text = lastName;
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                            horizontal: isSmallScreen ? 16 : 20,
                            vertical: isSmallScreen ? 12 : 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          'Edit Profile',
                          style: TextStyle(fontSize: isSmallScreen ? 14 : 16),
                        ),
                      ),
                    ),
                    SizedBox(height: verticalSpacing * 0.75),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () => ChangePasswordDialog.show(context),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.orange,
                          side: const BorderSide(color: Colors.orange),
                          backgroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                            horizontal: isSmallScreen ? 16 : 20,
                            vertical: isSmallScreen ? 12 : 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          'Change Password',
                          style: TextStyle(fontSize: isSmallScreen ? 14 : 16),
                        ),
                      ),
                    ),
                    SizedBox(height: verticalSpacing * 0.75),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: _signOut,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                          backgroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                            horizontal: isSmallScreen ? 16 : 20,
                            vertical: isSmallScreen ? 12 : 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          'Log Out',
                          style: TextStyle(fontSize: isSmallScreen ? 14 : 16),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
    );
  }

  Widget _buildInfoField(String label, String value, bool isSmallScreen) {
    return SizedBox(
      width: double.infinity,
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: isSmallScreen ? 10 : 12,
          horizontal: isSmallScreen ? 12 : 16,
        ),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: isSmallScreen ? 12 : 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: isSmallScreen ? 14 : 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}