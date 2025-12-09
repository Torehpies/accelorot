import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../services/auth_wrapper.dart';
import '../view_model/profile_notifier.dart';
import 'profile_edit_form.dart';
import 'profile_info_card.dart';
import '../../../frontend/operator/profile/change_password_dialog.dart';

class ProfileView extends ConsumerStatefulWidget {
  const ProfileView({super.key});

  @override
  ConsumerState<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends ConsumerState<ProfileView> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(profileProvider.notifier).initialize(),
    );
  }

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
  Widget build(BuildContext context) {
    final state = ref.watch(profileProvider);
    final notifier = ref.read(profileProvider.notifier);
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;

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
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.profile == null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 64, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(
                        state.errorMessage ?? 'Failed to load profile',
                        style: const TextStyle(fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => notifier.initialize(),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: EdgeInsets.all(outerPadding),
                  child: Column(
                    children: [
                      Card(
                        elevation: 4,
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(cardPadding),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Profile Header (matching old design exactly)
                              Center(
                                child: Column(
                                  children: [
                                    CircleAvatar(
                                      radius: avatarRadius,
                                      backgroundImage: NetworkImage(
                                        'https://via.placeholder.com/150/2E7D32/FFFFFF?text=${state.profile!.initials}',
                                      ),
                                    ),
                                    SizedBox(height: verticalSpacing),
                                    Text(
                                      state.profile!.displayName,
                                      style: TextStyle(
                                        fontSize: isSmallScreen ? 20 : 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: verticalSpacing * 0.5),
                                    Text(
                                      state.profile!.email,
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
                                        state.profile!.role,
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
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      fontSize: isSmallScreen ? 18 : 22,
                                      color: Colors.grey[800],
                                    ),
                              ),
                              SizedBox(height: sectionSpacing),

                              // Form or Info Display
                              if (state.isEditing)
                                ProfileEditForm(
                                  profile: state.profile!,
                                  isSmallScreen: isSmallScreen,
                                  verticalSpacing: verticalSpacing,
                                  sectionSpacing: sectionSpacing,
                                )
                              else
                                ProfileInfoCard(
                                  profile: state.profile!,
                                  isSmallScreen: isSmallScreen,
                                  verticalSpacing: verticalSpacing,
                                ),
                            ],
                          ),
                        ),
                      ),

                      // Bottom Buttons (matching old design exactly)
                      if (!state.isEditing) ...[
                        SizedBox(height: verticalSpacing),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () => notifier.setEditing(true),
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
}