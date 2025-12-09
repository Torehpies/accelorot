import 'package:flutter/material.dart';
import 'package:flutter_application_1/frontend/components/google_signin_button.dart';
import 'package:flutter_application_1/frontend/components/or_divider.dart';
import 'package:flutter_application_1/frontend/controllers/login_controller.dart';
import 'package:flutter_application_1/screens/login/login_screen.dart';
import 'package:flutter_application_1/services/auth_service.dart';
import 'package:flutter_application_1/services/google_sign_in_handler.dart';
import 'package:flutter_application_1/utils/snackbar_utils.dart';
import 'package:flutter_application_1/web/admin/screens/web_registration_screen.dart';
import 'package:flutter_application_1/ui/core/ui/primary_button.dart';

class WebLoginScreen extends StatefulWidget {
  const WebLoginScreen({super.key});

  @override
  State<WebLoginScreen> createState() => _WebLoginScreenState();
}

class _WebLoginScreenState extends State<WebLoginScreen> {
  late LoginController _controller;
  final AuthService _authService = AuthService();
  bool _isGoogleLoading = false;
  final bool _isLoading = false;

  void _setLoadingState(bool isLoading) {
    if (mounted) {
      setState(() {
        _isGoogleLoading = isLoading;
      });
    }
  }

  Future<void> _handleGoogleSignIn() async {
    if (_isGoogleLoading || _isLoading) return;

    final handler = GoogleSignInHandler(_authService, context);
    await handler.signInWithGoogle(setLoadingState: _setLoadingState);
  }

  @override
  void initState() {
    super.initState();
    _controller = LoginController();

    // Set up callbacks
    _controller.setCallbacks(
      onLoadingChanged: (isLoading) => setState(() {}),
      onPasswordVisibilityChanged: (obscured) => setState(() {}),

      onLoginSuccess: (result) {
        // Don't manually navigate - let AuthWrapper handle routing
        if (!mounted) return;

        // Replace the entire navigation stack with AuthWrapper
        // This will trigger the StreamBuilder and route correctly
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) =>  const LoginScreen()),
          (route) => false,
        );
      },
      onLoginError: (message) {
        showSnackbar(context, message, isError: true);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Center(
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
                    const SizedBox(height: 16),
                    // Title
                    _buildTitle(theme),
                    const SizedBox(height: 16),
                    // Email Field
                    _buildEmailField(),
                    const SizedBox(height: 16),
                    // Password Field
                    _buildPasswordField(),
                    const SizedBox(height: 6),
                    // Forgot Password
                    _buildForgotPassword(),
                    const SizedBox(height: 6),
                    // Login Button
                    _buildLoginButton(),
                    const SizedBox(height: 8),
                    OrDivider(),
                    GoogleSignInButton(
                      onPressed: _handleGoogleSignIn,
                      isLoading: _isGoogleLoading,
                    ),
                    // Sign Up Link
                    _buildSignUpLink(),
                  ],
                ),
              ),
            ),
          ),
        ),
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
        onPressed: _controller.handleForgotPassword,
        child: const Text('Forgot Password?'),
      ),
    );
  }

  Widget _buildLoginButton() {
    return SizedBox(
      width: double.infinity,
      child: PrimaryButton(
        text: 'Login',
        onPressed: _controller.loginUser,
        isLoading: _controller.isLoading,
      ),
      //child: ElevatedButton(
      //  onPressed: _controller.isLoading ? null : _controller.loginUser,
      //  style: ElevatedButton.styleFrom(
      //    backgroundColor: Colors.teal,
      //    foregroundColor: Colors.white,
      //    padding: const EdgeInsets.symmetric(vertical: 16),
      //    shape: RoundedRectangleBorder(
      //      borderRadius: BorderRadius.circular(12),
      //    ),
      //    elevation: 4,
      //  ),
      //  child: _controller.isLoading
      //      ? const SizedBox(
      //          width: 20,
      //          height: 20,
      //          child: CircularProgressIndicator(
      //            strokeWidth: 2,
      //            valueColor: AlwaysStoppedAnimation(Colors.white),
      //          ),
      //        )
      //      : const Text(
      //          'Sign In',
      //          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      //        ),
      //),
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
                builder: (context) => const WebRegistrationScreen(),
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
