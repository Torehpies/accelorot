
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_application_1/web/admin/screens/web_login_screen.dart' show WebLoginScreen;
import '../../../services/auth_wrapper.dart';
import '../../../services/sess_service.dart';


import '../../../web/admin/screens/web_login_screen.dart';


class WebProfileScreen extends StatefulWidget {
  final String? viewingOperatorId;
  
  const WebProfileScreen({super.key, this.viewingOperatorId});

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

      // Parse the full name into first and last name
      final nameParts = _fullNameController.text.trim().split(' ');
      final newFirstName = nameParts.isNotEmpty ? nameParts.first : '';
      final newLastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';

      // Update in Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({
        'firstname': newFirstName,
        'lastname': newLastName,
      });

      // Reload user data
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
    _fullNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 56, 136, 132),
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.teal,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.teal),
            onPressed: () {},
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(32.0),
              child: Card(
                elevation: 4,
                color: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 40,
                            backgroundImage: NetworkImage(
                              'https://via.placeholder.com/150/2E7D32/FFFFFF?text=$initials',
                            ),
                          ),
                          const SizedBox(width: 32),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  displayName,
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  email,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.teal[50],
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    role,
                                    style: TextStyle(
                                      color: Colors.teal[800],
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (!_isEditing)
                            ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  _isEditing = true;
                                  // Reset controllers when entering edit mode
                                  _usernameController.text = displayName;
                                  _fullNameController.text = fullName;
                                });
                              },
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
                      const SizedBox(height: 32),
                      Divider(color: Colors.grey[300]),
                      const SizedBox(height: 24),
                      Text(
                        'Personal Information',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[800],
                            ),
                      ),
                      const SizedBox(height: 24),
                      if (_isEditing)
                        Form(
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      controller: _usernameController,
                                      decoration: const InputDecoration(
                                        labelText: 'Username',
                                        border: OutlineInputBorder(),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 24),
                                  Expanded(
                                    child: TextFormField(
                                      controller: _fullNameController,
                                      decoration: const InputDecoration(
                                        labelText: 'Full Name',
                                        border: OutlineInputBorder(),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      initialValue: email,
                                      decoration: InputDecoration(
                                        labelText: 'Email Address',
                                        border: const OutlineInputBorder(),
                                        filled: true,
                                        fillColor: Colors.grey[200],
                                      ),
                                      enabled: false,
                                    ),
                                  ),
                                  const SizedBox(width: 24),
                                  Expanded(
                                    child: TextFormField(
                                      initialValue: role,
                                      decoration: InputDecoration(
                                        labelText: 'Role',
                                        border: const OutlineInputBorder(),
                                        filled: true,
                                        fillColor: Colors.grey[200],
                                      ),
                                      enabled: false,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 32),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  TextButton(
                                    onPressed: () {
                                      setState(() {
                                        _isEditing = false;
                                        // Reset controllers to original values
                                        _usernameController.text = displayName;
                                        _fullNameController.text = fullName;
                                      });
                                    },
                                    child: const Text('Discard'),
                                  ),
                                  const SizedBox(width: 16),
                                  ElevatedButton(
                                    onPressed: _saveProfile,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.teal,
                                      foregroundColor: Colors.white,
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
                            Row(
                              children: [
                                Expanded(
                                  child: _buildInfoField('Username', displayName),
                                ),
                                const SizedBox(width: 24),
                                Expanded(
                                  child: _buildInfoField('Full Name', fullName),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildInfoField('Email Address', email),
                                ),
                                const SizedBox(width: 24),
                                Expanded(
                                  child: _buildInfoField('Role', role),
                                ),
                              ],
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildInfoField(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
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
              fontSize: 14,
              color: Colors.grey[600],

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWideScreen = screenWidth > 800;

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

    // Build initials for avatar placeholder
    final initials = ((first.isNotEmpty ? first[0] : '') + (last.isNotEmpty ? last[0] : '')).toUpperCase();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'Profile',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        elevation: 2,
        centerTitle: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(isWideScreen ? 32 : 24),
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 800),
              child: Column(
                children: [
                  // Profile Header Card
                  Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF2E7D32),
                          const Color(0xFF4CAF50),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.teal.withValues(alpha: 0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 60,
                          backgroundColor: Colors.white,
                          child: CircleAvatar(
                            radius: 56,
                            backgroundImage: NetworkImage(
                              'https://via.placeholder.com/150/2E7D32/FFFFFF?text=${initials.isNotEmpty ? initials : 'M'}',
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        _loading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : Text(
                                displayName.isNotEmpty ? displayName : 'No name',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                        const SizedBox(height: 8),
                        Text(
                          email,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            _userData?['role'] ?? 'Operator',
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
                  const SizedBox(height: 32),

                  // Action Buttons Card
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 15,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _buildButton(
                          context,
                          label: "Edit Profile",
                          icon: Icons.edit,
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
                        const SizedBox(height: 12),
                        _buildButton(
                          context,
                          label: "Change Password",
                          icon: Icons.lock,
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => const ChangePasswordModal(),
                            );
                          },
                        ),
                        const SizedBox(height: 12),
                        _buildButton(
                          context,
                          label: "Personal Info",
                          icon: Icons.person,
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const PersonalInfoScreen(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Log Out Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _signOut,
                      icon: const Icon(Icons.logout),
                      label: const Text(
                        "Log Out",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2E7D32),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 4,
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

  Widget _buildButton(
    BuildContext context, {
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFF4CAF50)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4CAF50).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: const Color(0xFF4CAF50),
                    size: 22,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    label,
                    style: const TextStyle(
                      color: Colors.black87,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Color(0xFF4CAF50),
                ),
              ],

            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}