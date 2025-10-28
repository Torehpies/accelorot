import 'package:flutter/material.dart';
import 'package:flutter_application_1/frontend/components/google_signin_button.dart';
import 'package:flutter_application_1/frontend/components/or_divider.dart';
import 'package:flutter_application_1/widgets/common/primary_button.dart';

const double kMaxFormWidth = 450.0;

/// Simple class to bundle all the methods/controllers/state needed by the UI.
class LoginHandlers {
  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool isLoading;
  final bool isGoogleLoading;
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
    required this.isGoogleLoading,
    required this.obscurePassword,
    required this.togglePasswordVisibility,
    required this.onSubmitLogin,
    required this.onGoogleSignIn,
    required this.onNavigateToForgotPass,
    required this.onNavigateToRegistration,
  });
}

/// Encapsulates the core login form content, receiving data via LoginHandlers.
/// This widget is used by both MobileLoginView and DesktopLoginView.
class LoginFormContent extends StatelessWidget {
  final LoginHandlers handlers;
  final bool isDesktop;

  const LoginFormContent({
    super.key,
    required this.handlers,
    this.isDesktop = false,
  });

  @override
  Widget build(BuildContext context) {
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
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Email is required' : null,
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
                validator: (value) => value == null || value.isEmpty
                    ? 'Password is required'
                    : null,
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
                  onPressed: handlers.isLoading ? null : handlers.onSubmitLogin,
                  isLoading: handlers.isLoading,
                ),
              ),
              const SizedBox(height: 24),

              const OrDivider(),
              const SizedBox(height: 20),

              // Google Sign-In Button
              GoogleSignInButton(
                onPressed: handlers.onGoogleSignIn,
                isLoading: handlers.isGoogleLoading,
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
