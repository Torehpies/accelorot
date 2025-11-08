import 'package:flutter/material.dart';
import 'package:flutter_application_1/frontend/components/edit_profile_modal.dart';
import 'package:flutter_application_1/frontend/screens/admin/operator_management/operator_view_service.dart';

class PersonalInfoScreen extends StatefulWidget {
  final String? viewingOperatorId;

  const PersonalInfoScreen({super.key, this.viewingOperatorId});

  @override
  State<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends State<PersonalInfoScreen> {
  Map<String, dynamic>? _userData;
  bool _loading = true;
  bool _isViewingAsAdmin = false;

  @override
  void initState() {
    super.initState();
    _isViewingAsAdmin = widget.viewingOperatorId != null;
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    if (widget.viewingOperatorId != null) {
      final data = await OperatorViewService.getOperatorDetails(widget.viewingOperatorId!);
      if (mounted) {
        setState(() {
          _userData = data;
          _loading = false;
        });
      }
    } else {
      // Load current user data (implement your existing logic here)
      setState(() {
        _userData = {
          'firstname': 'Miguel Andres',
          'lastname': 'Reyes',
          'email': 'miguelreyes@email.com',
          'role': 'User',
        };
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Personal Info"),
          backgroundColor: Colors.green.shade700,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final firstName = _userData?['firstname'] ?? '';
    final lastName = _userData?['lastname'] ?? '';
    final fullName = '$firstName $lastName'.trim();
    final email = _userData?['email'] ?? '';
    final role = _userData?['role'] ?? 'User';
    final username = fullName.replaceAll(' ', '');

    return Scaffold(
      appBar: AppBar(
        title: const Text("Personal Info"),
        backgroundColor: Colors.green.shade700,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          // Only show edit button if not viewing as admin
          if (!_isViewingAsAdmin)
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.white),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => EditProfileModal(
                    firstName: firstName,
                    lastName: lastName,
                    username: username,
                    role: role,
                  ),
                );
              },
            ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar + Name + Email
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: NetworkImage(
                        'https://via.placeholder.com/150/2E7D32/FFFFFF?text=${firstName.isNotEmpty ? firstName[0] : 'M'}',
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      fullName.isNotEmpty ? fullName : 'No name',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      email,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    // Show viewing badge if admin is viewing
                    if (_isViewingAsAdmin)
                      Container(
                        margin: const EdgeInsets.only(top: 12),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          border: Border.all(color: Colors.blue.shade200),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          '👁️ Viewing as Admin',
                          style: TextStyle(
                            color: Colors.blue,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              _buildInfoRow("Username", username),
              const SizedBox(height: 16),
              _buildInfoRow("Full Name", fullName),
              const SizedBox(height: 16),
              _buildInfoRow("Email Address", email),
              const SizedBox(height: 16),
              _buildInfoRow("Role", role),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value.isNotEmpty ? value : 'N/A',
          style: const TextStyle(
            fontSize: 16,
            color: Colors.black,
          ),
        ),
        const Divider(height: 24),
      ],
    );
  }
}