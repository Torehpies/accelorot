import 'package:flutter/material.dart';
import 'package:flutter_application_1/frontend/components/google_signin_button.dart';
import 'package:flutter_application_1/frontend/components/or_divider.dart';
import 'package:flutter_application_1/widgets/common/primary_button.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const double kMaxFormWidth = 450.0;

/// Simple class to bundle all the methods/controllers/state needed by the UI.
class LoginHandlers {
  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool isLoading;
  final bool obscurePassword;
  final VoidCallback togglePasswordVisibility;
  final VoidCallback onSubmitLogin;
  final VoidCallback onGoogleSignIn;
  final VoidCallback onNavigateToForgotPass;
  final VoidCallback onNavigateToRegistration;

  LoginHandlers({
    required this.formKey,
    required this.emailController,
    required this.passwordController,
    required this.isLoading,
    required this.obscurePassword,
    required this.togglePasswordVisibility,
    required this.onSubmitLogin,
    required this.onGoogleSignIn,
    required this.onNavigateToForgotPass,
    required this.onNavigateToRegistration,
  });
}

class LoginFormContent extends ConsumerWidget {
  final LoginHandlers handlers;
  final bool isDesktop;

  const LoginFormContent({
    super.key,
    required this.handlers,
    this.isDesktop = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(child: _buildLogo()),
        const SizedBox(height: 16),
        Center(child: _buildTitle(theme)),
        SizedBox(height: isDesktop ? 40 : 32),

        Form(
          key: handlers.formKey,
          child: Column(
            children: [
              // Email Field
              TextFormField(
                controller: handlers.emailController,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  labelText: 'Email Address',
                  prefixIcon: Icon(Icons.email_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Email is required';
                  }
                  if (!value.contains('@')) {
                    return 'Enter a valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Password Field
              TextFormField(
                controller: handlers.passwordController,
                obscureText: handlers.obscurePassword,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => handlers.onSubmitLogin(),
                decoration: InputDecoration(
                  labelText: 'Password',
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
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Password is required';
                  }
                  if (value.length < 8) {
                    return 'Password must be at least 8 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 8),

              // Forgot Password
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: handlers.onNavigateToForgotPass,
                  child: const Text('Forgot Password?'),
                ),
              ),

              // Login Button
              SizedBox(
                width: double.infinity,
                child: PrimaryButton(
                  text: 'Login',
                  isLoading: handlers.isLoading,
                  onPressed: handlers.onSubmitLogin,
                ),
              ),
              const SizedBox(height: 24),

              const OrDivider(),
              const SizedBox(height: 20),

              // Google Sign-In Button
              GoogleSignInButton(
                isLoading: handlers.isLoading,
                onPressed: handlers.onGoogleSignIn,
              ),

              // Sign Up Link
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Don't have an account? "),
                  TextButton(
                    onPressed: handlers.onNavigateToRegistration,
                    child: const Text(
                      "Sign up",
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

  // --- Helper Widgets ---
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
          'Welcome Back!',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: theme.primaryColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Sign in to continue',
          style: TextStyle(fontSize: 16, color: theme.hintColor),
        ),
      ],
    );
  }
}
