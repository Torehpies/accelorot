import 'package:flutter/material.dart';
import 'package:flutter_application_1/frontend/screens/admin/admin_main_navigation.dart';
import 'package:flutter_application_1/frontend/screens/main_navigation.dart';
import '../../utils/snackbar_utils.dart';
import '../controllers/login_controller.dart';
import 'registration_screen.dart';
import 'email_verify.dart';

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
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Full-screen background (optional)
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.white, Colors.white],
              ),
            ),
          ),

          // Main content
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Logo
                Center(
                  child: Container(
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
                          color: Colors.white.withOpacity(0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.trending_up, size: 36, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 24),

                // Title
                Center(
  child: Column(
    children: [
      Text(
        'Welcome Back!',
        style: const TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: Colors.teal,
        ),
      ),
      const SizedBox(height: 8),
      Text(
        'Sign in to continue',
        style: const TextStyle(fontSize: 16, color: Colors.teal),
      ),
    ],
  ),
),
const SizedBox(height: 32),

                // Form
                Form(
                  key: _controller.formKey,
                  child: Column(
                    children: [

                      // Email
                      TextFormField(
  controller: _controller.emailController,
  keyboardType: TextInputType.emailAddress,
  textInputAction: TextInputAction.next,
  style: const TextStyle(color: Colors.teal),
  decoration: InputDecoration(
    labelText: 'Email Address',
    labelStyle: const TextStyle(color: Colors.teal),
    filled: true,
    fillColor: Colors.grey.shade50,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
  ),
  validator: _controller.validateEmail,
 ),
const SizedBox(height: 16),

                      // Password
                     TextFormField(
  controller: _controller.passwordController,
  obscureText: _controller.obscurePassword,
  textInputAction: TextInputAction.done,
  onFieldSubmitted: (_) => _controller.loginUser(),
  style: const TextStyle(color: Colors.teal),
  decoration: InputDecoration(
    labelText: 'Password',
    labelStyle: const TextStyle(color: Colors.teal),
    filled: true,
    fillColor: Colors.grey.shade50,
    suffixIcon: IconButton(
      icon: Icon(
        _controller.obscurePassword
            ? Icons.visibility_outlined
            : Icons.visibility_off_outlined,
        color: Colors.grey,
      ),
      onPressed: _controller.togglePasswordVisibility,
    ),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
  ),
  validator: _controller.validatePassword,
),
const SizedBox(height: 8),

                      // Forgot Password
                     Align(
  alignment: Alignment.centerRight,
  child: TextButton(
    onPressed: _controller.handleForgotPassword,
    style: TextButton.styleFrom(
      foregroundColor: Colors.teal, // This sets the text color
    ),
    child: const Text('Forgot Password?'),
  ),
),

                      // Login Button
                      SizedBox(
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
                          ),
                          child: _controller.isLoading
                              ? const CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation(Colors.white),
                                )
                              : const Text(
                                  'Sign In',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Sign Up Link
                      Row(
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
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Top-left Home button
          Positioned(
            top: 40,
            left: 16,
            child: IconButton(
              icon: const Icon(Icons.home, color: Colors.white, size: 28),
              style: IconButton.styleFrom(
                backgroundColor: Colors.teal,
                shape: const CircleBorder(),
                padding: const EdgeInsets.all(12),
                shadowColor: Colors.black.withOpacity(0.1),
                elevation: 6,
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

          // Top-right Admin button
          Positioned(
            top: 40,
            right: 16,
            child: IconButton(
              icon: const Icon(Icons.admin_panel_settings, color: Colors.white, size: 28),
              style: IconButton.styleFrom(
                backgroundColor: Colors.teal,
                shape: const CircleBorder(),
                padding: const EdgeInsets.all(12),
                shadowColor: Colors.black.withOpacity(0.1),
                elevation: 6,
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
        ],
      ),
    );
  }
}