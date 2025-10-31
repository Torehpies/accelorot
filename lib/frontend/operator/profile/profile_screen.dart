import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../components/edit_profile_modal.dart';
import '../../components/change_password_modal.dart';
import '../../screens/personal_info_screen.dart';
import 'package:flutter_application_1/services/sess_service.dart';
import 'package:flutter_application_1/frontend/screens/admin/operator_management/operator_view_service.dart';

class ProfileScreen extends StatefulWidget {
  final String? viewingOperatorId;
  
  const ProfileScreen({super.key, this.viewingOperatorId});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final SessionService _session = SessionService();
  Map<String, dynamic>? _userData;
  bool _loading = true;
  bool _isViewingAsAdmin = false;

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
  }

  @override
  void initState() {
    super.initState();
    _isViewingAsAdmin = widget.viewingOperatorId != null;
    _loadUser();
  }

  Future<void> _loadUser() async {
    setState(() => _loading = true);
    
    Map<String, dynamic>? data;
    
    // If viewing as admin, fetch the operator's data
    if (widget.viewingOperatorId != null) {
      data = await OperatorViewService.getOperatorDetails(widget.viewingOperatorId!);
    } else {
      // Otherwise, fetch current user's data
      data = await _session.getCurrentUserData();
    }
    
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

    // Build initials for avatar placeholder
    final initials = ((first.isNotEmpty ? first[0] : '') + (last.isNotEmpty ? last[0] : '')).toUpperCase();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              height: 180,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF2E7D32),
                    Color(0xFF4CAF50),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: NetworkImage(
                        'https://via.placeholder.com/150/2E7D32/FFFFFF?text=${initials.isNotEmpty ? initials : 'M'}',
                      ),
                    ),
                    const SizedBox(height: 16),
                    _loading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                            displayName.isNotEmpty ? displayName : 'No name',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                    const SizedBox(height: 4),
                    Text(
                      email,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                    // Show viewing badge if admin is viewing
                    if (_isViewingAsAdmin)
                      Container(
                        margin: const EdgeInsets.only(top: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          '👁️ Viewing as Admin',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // Body Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    // Disable edit actions when viewing as admin
                    _buildButton(
                      context,
                      label: "Edit Profile",
                      onPressed: _isViewingAsAdmin
                          ? null
                          : () {
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
                    _buildButton(
                      context,
                      label: "Change Password",
                      onPressed: _isViewingAsAdmin
                          ? null
                          : () {
                              showDialog(
                                context: context,
                                builder: (context) => const ChangePasswordModal(),
                              );
                            },
                    ),
                    _buildButton(
                      context,
                      label: "Personal Info",
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PersonalInfoScreen(
                              viewingOperatorId: widget.viewingOperatorId,
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 32),

                    // Only show Log Out button if not viewing as admin
                    if (!_isViewingAsAdmin)
                      ElevatedButton(
                        onPressed: () async {
                          await _signOut();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2E7D32),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text("Log Out", style: TextStyle(fontSize: 16)),
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

  Widget _buildButton(BuildContext context, {required String label, VoidCallback? onPressed}) {
    final isDisabled = onPressed == null;
    
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(
          color: isDisabled ? Colors.grey.shade300 : Color(0xFF4CAF50),
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        title: Text(
          label,
          style: TextStyle(
            color: isDisabled ? Colors.grey : Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: isDisabled ? Colors.grey : Color(0xFF4CAF50),
        ),
        onTap: onPressed,
        enabled: !isDisabled,
      ),
    );
  }
}
