import 'package:flutter/material.dart';
import 'package:flutter_application_1/frontend/screens/admin/admin_screens/admin_main_navigation.dart';
import 'package:flutter_application_1/frontend/screens/main_navigation.dart';
import '../../utils/snackbar_utils.dart';
import '../controllers/login_controller.dart';
import 'registration_screen.dart';
import 'email_verify.dart';
import 'forgot_pass.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late LoginController _controller;

  @override
  void initState() {
    super.initState();
    _controller = LoginController();

    // Set up callbacks
    _controller.setCallbacks(
      onLoadingChanged: (isLoading) => setState(() {}),
      onPasswordVisibilityChanged: (obscured) => setState(() {}),

      onLoginSuccess: (result) {
        if (result['needsVerification'] == true) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => EmailVerifyScreen(
                email: _controller.emailController.text.trim(),
              ),
            ),
          );
          return;
        }
        Map<String, dynamic> userData = result['userData'] as Map<String, dynamic>;
        String userRole = userData['role'] ?? 'User';

        // Navigate based on role
        if (userRole == 'Admin') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const AdminMainNavigation(),
            ),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const MainNavigation()),
          );
        }
      },
      onLoginError: (message) {
        showSnackbar(context, message, isError: true);
      },
    );

    // Remove modal popups on load
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Stack(
        children: [
          // Main login UI
          SafeArea(
            child: Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 500),
                padding: const EdgeInsets.all(24),
                child: Card(
                  elevation: 10,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Form(
                      key: _controller.formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Logo
                          _buildLogo(),
                          const SizedBox(height: 24),
                          // Title
                          _buildTitle(theme),
                          const SizedBox(height: 32),
                          // Email Field
                          _buildEmailField(),
                          const SizedBox(height: 16),
                          // Password Field
                          _buildPasswordField(),
                          const SizedBox(height: 16),
                          // Forgot Password
                          _buildForgotPassword(),
                          const SizedBox(height: 24),
                          // Login Button
                          _buildLoginButton(),
                          const SizedBox(height: 24),
                          // Sign Up Link
                          _buildSignUpLink(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Button at top right for Admin Panel
          Positioned(
            top: 24,
            right: 24,
            child: IconButton(
              icon: const Icon(
                Icons.admin_panel_settings,
                color: Colors.white,
                size: 28,
              ),
              style: IconButton.styleFrom(
                backgroundColor: Colors.teal,
                shape: const CircleBorder(),
                padding: const EdgeInsets.all(12),
                shadowColor: Colors.black.withValues(alpha: 0.08),
                elevation: 8,
              ),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AdminMainNavigation(),
                  ),
                );
              },
            ),
          ),
          // Button at top left for Home
          Positioned(
            top: 24,
            left: 24,
            child: IconButton(
              icon: const Icon(Icons.home, color: Colors.white, size: 28),
              style: IconButton.styleFrom(
                backgroundColor: Colors.teal,
                shape: const CircleBorder(),
                padding: const EdgeInsets.all(12),
                shadowColor: Colors.black.withValues(alpha: 0.08),
                elevation: 8,
              ),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MainNavigation(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
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
            color: Colors.teal..withValues(alpha: 0.3),
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
        const SizedBox(height: 8),
        Text(
          'Sign in to continue',
          style: TextStyle(fontSize: 16, color: theme.hintColor),
        ),
      ],
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
      controller: _controller.emailController,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        labelText: 'Email Address',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      validator: _controller.validateEmail,
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _controller.passwordController,
      obscureText: _controller.obscurePassword,
      textInputAction: TextInputAction.done,
      onFieldSubmitted: (_) => _controller.loginUser(),
      decoration: InputDecoration(
        labelText: 'Password',
        suffixIcon: IconButton(
          icon: Icon(
            _controller.obscurePassword
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
            color: Colors.grey,
          ),
          onPressed: _controller.togglePasswordVisibility,
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      validator: _controller.validatePassword,
    );
  }

  Widget _buildForgotPassword() {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const ForgotPassScreen()),
          );
        },
        child: const Text('Forgot Password?'),
      ),
    );
  }

  Widget _buildLoginButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _controller.isLoading ? null : _controller.loginUser,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.teal,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
        ),
        child: _controller.isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation(Colors.white),
                ),
              )
            : const Text(
                'Sign In',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
      ),
    );
  }

  Widget _buildSignUpLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Don't have an account? "),
        TextButton(
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const RegistrationScreen(),
              ),
            );
          },
          child: const Text(
            "Sign up",
            style: TextStyle(color: Colors.teal, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
