import 'package:flutter/material.dart';
import 'package:flutter_application_1/frontend/components/google_signin_button.dart';
import 'package:flutter_application_1/frontend/components/or_divider.dart';
import 'package:flutter_application_1/repositories/team_repository.dart';
import 'package:flutter_application_1/ui/core/themes/app_theme.dart';
import 'package:flutter_application_1/ui/core/ui/primary_button.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const double kMaxFormWidth = 450.0;

/// Simple class to bundle all the methods/controllers/state needed by the UI.
class RegistrationHandlers {
  final GlobalKey<FormState> formKey;
  final TextEditingController firstNameController;
  final TextEditingController lastNameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;

  final AsyncValue<List<Team>> asyncTeamList;

  final String? selectedTeamId;
  final bool isLoading;
  final bool isGoogleLoading;
  final bool obscurePassword;
  final bool obscureConfirmPassword;

  final void Function(String?) onTeamSelected;
  final VoidCallback togglePasswordVisibility;
  final VoidCallback toggleConfirmPasswordVisibility;
  final VoidCallback onSubmitRegistration;
  final VoidCallback onGoogleSignIn;
  final VoidCallback onNavigateToLogin;

  RegistrationHandlers({
    required this.formKey,
    required this.firstNameController,
    required this.lastNameController,
    required this.emailController,
    required this.passwordController,
    required this.confirmPasswordController,

    required this.asyncTeamList,
    required this.selectedTeamId,
    required this.onTeamSelected,

    required this.isLoading,
    required this.isGoogleLoading,
    required this.obscurePassword,
    required this.obscureConfirmPassword,
    required this.togglePasswordVisibility,
    required this.toggleConfirmPasswordVisibility,
    required this.onSubmitRegistration,
    required this.onGoogleSignIn,
    required this.onNavigateToLogin,
  });

  // --- Validators ---
  String? nameValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Name is required';
    }
    return null;
  }

  String? emailValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
      return 'Enter a valid email address';
    }
    return null;
  }

  String? passwordValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    return null;
  }

  String? confirmPasswordValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    // Check against the current state's password value, not the controller.
    // However, since the controller updates the state, checking the controller is fine
    // as long as the check happens on form submit.
    if (value != passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }
}

// --- Shared Form UI Component ---

class RegistrationFormContent extends ConsumerWidget {
  final RegistrationHandlers handlers;
  final bool isDesktop;

  const RegistrationFormContent({
    super.key,
    required this.handlers,
    this.isDesktop = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    // Common Text Field Decoration style (based on your original screen)
    InputDecoration inputDecoration(
      String labelText, {
      Widget? suffixIcon,
      Icon? prefixIcon,
    }) => InputDecoration(
      labelText: labelText,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.green100, width: 2),
      ),
    );

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (!isDesktop) Center(child: _buildLogo()),
        const SizedBox(height: 10),
        Center(child: _buildTitle(theme)),
        SizedBox(height: isDesktop ? 10 : 32),

        Form(
          key: handlers.formKey,
          child: Column(
            children: [
              // First Name and Last Name Row
              Row(
                children: [
                  // First Name Field
                  Expanded(
                    child: TextFormField(
                      controller: handlers.firstNameController,
                      textInputAction: TextInputAction.next,
                      decoration: inputDecoration('First Name'),
                      validator: handlers.nameValidator,
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Last Name Field
                  Expanded(
                    child: TextFormField(
                      controller: handlers.lastNameController,
                      textInputAction: TextInputAction.next,
                      decoration: inputDecoration('Last Name'),
                      validator: handlers.nameValidator,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Email Field
              TextFormField(
                controller: handlers.emailController,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                decoration: inputDecoration(
                  'Email Address',
                  prefixIcon: const Icon(Icons.email_outlined),
                ),
                validator: handlers.emailValidator,
              ),
              const SizedBox(height: 16),

              // Password Field
              TextFormField(
                controller: handlers.passwordController,
                obscureText: handlers.obscurePassword,
                textInputAction: TextInputAction.next,
                decoration: inputDecoration(
                  'Password',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      handlers.obscurePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: Colors.grey,
                    ),
                    onPressed: handlers.togglePasswordVisibility,
                  ),
                ),
                validator: handlers.passwordValidator,
              ),
              const SizedBox(height: 16),

              // Confirm Password Field
              TextFormField(
                controller: handlers.confirmPasswordController,
                obscureText: handlers.obscureConfirmPassword,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => handlers.onSubmitRegistration(),
                decoration: inputDecoration(
                  'Confirm Password',
                  prefixIcon: const Icon(Icons.lock_open_outlined),
                  suffixIcon: IconButton(
                    icon: Icon(
                      handlers.obscureConfirmPassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: Colors.grey,
                    ),
                    onPressed: handlers.toggleConfirmPasswordVisibility,
                  ),
                ),
                validator: handlers.confirmPasswordValidator,
              ),
              const SizedBox(height: 16),
              buildTeamDropdown(context, isDesktop),
              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                child: PrimaryButton(
                  text: 'Register',
                  isLoading: handlers.isLoading,
                  onPressed: handlers.onSubmitRegistration,
                ),
              ),
              const SizedBox(height: 24),

              const OrDivider(),
              const SizedBox(height: 10),

              // Google Sign-In Button
              GoogleSignInButton(
                isLoading: handlers.isGoogleLoading,
                onPressed: handlers.onGoogleSignIn,
              ),

              // Sign In Link
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Already have an account? "),
                  TextButton(
                    onPressed: handlers.onNavigateToLogin,
                    child: const Text(
                      "Sign in",
                      style: TextStyle(
                        color: Colors.teal,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildTeamDropdown(BuildContext context, bool isDesktop) {
    return handlers.asyncTeamList.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Text(
        'Error loading teams: $err',
        style: TextStyle(color: Colors.red),
      ),
      data: (teams) {
        if (teams.isEmpty) {
          return const Text(
            'No teams available.',
            style: TextStyle(color: Colors.orange),
          );
        }

        return DropdownButtonFormField<String>(
          key: const ValueKey('team-dropdown'),
          initialValue: handlers.selectedTeamId,
          decoration: InputDecoration(
            labelText: 'Select Team',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.green100, width: 2),
            ),
          ),
          hint: const Text('Choose your team'),
          items: teams.map((team) {
            return DropdownMenuItem<String>(
              value: team.id,
              child: Text(team.name),
            );
          }).toList(),
          onChanged: handlers.onTeamSelected,
        );
      },
    );
  }

  Widget _buildLogo() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.teal.shade400, Colors.teal.shade700],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.teal.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: const Icon(Icons.trending_up, size: 36, color: Colors.white),
    );
  }

  Widget _buildTitle(ThemeData theme) {
    return Column(
      children: [
        Text(
          'Create Account',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppColors.green100,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Join us to get started',
          style: TextStyle(fontSize: 16, color: theme.hintColor),
        ),
      ],
    );
  }
}
