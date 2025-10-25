import 'package:flutter/material.dart';
import 'package:flutter_application_1/frontend/components/google_signin_button.dart';
import 'package:flutter_application_1/frontend/components/or_divider.dart';
import 'package:flutter_application_1/frontend/screens/admin/admin_screens/admin_main_navigation.dart';
import 'package:flutter_application_1/frontend/screens/main_navigation.dart';
import 'package:flutter_application_1/frontend/screens/qr_refer.dart';
import 'package:flutter_application_1/frontend/screens/waiting_approval_screen.dart';
import 'package:flutter_application_1/services/auth_service.dart';
import 'package:flutter_application_1/services/google_sign_in_handler.dart';
import '../../utils/snackbar_utils.dart';
import '../controllers/login_controller.dart';
import 'registration_screen.dart';
import 'email_verify.dart';
import 'forgot_pass.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'restricted_access_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late LoginController _controller;
  final AuthService _authService = AuthService();
  bool _isGoogleLoading = false;
	bool _isLoading = false;

	void _setLoadingState(bool isLoading) {
		if (mounted) {
		setState(() {
				  _isGoogleLoading = isLoading;
				});
		}
	}

  @override
  void initState() {
    super.initState();
    _controller = LoginController();

    _controller.setCallbacks(
      onLoadingChanged: (isLoading) => setState(() {}),
      onPasswordVisibilityChanged: (obscured) => setState(() {}),

      onLoginSuccess: (result) async {
        // Avoid using BuildContext across async gaps by returning early if
        // the State has been unmounted.
        if (!mounted) return;

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

        final Map<String, dynamic> userData =
            (result['userData'] ?? {}) as Map<String, dynamic>;
        final String userRole = userData['role'] ?? 'Operator';

        // If admin -> admin nav immediately
        if (userRole == 'Admin') {
          if (!mounted) return;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const AdminMainNavigation(),
            ),
          );
          return;
        }

        // For non-admin users, route based on team status
        final teamId = userData['teamId'];
        final pendingTeamId = userData['pendingTeamId'];

        if (teamId != null) {
          try {
            final user = _authService.getCurrentUser();
            if (user != null) {
              // Check member status in the team
              final memberDoc = await FirebaseFirestore.instance
                  .collection('teams')
                  .doc(teamId)
                  .collection('members')
                  .doc(user.uid)
                  .get();

              if (memberDoc.exists) {
                final memberData = memberDoc.data()!;
                final isArchived = memberData['isArchived'] ?? false;
                final hasLeft = memberData['hasLeft'] ?? false;

                // Block archived users
                if (isArchived) {
                  if (!mounted) return;
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          const RestrictedAccessScreen(reason: 'archived'),
                    ),
                  );
                  return;
                }

                // If user has left, send to QR screen
                if (hasLeft) {
                  if (!mounted) return;
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const QRReferScreen(),
                    ),
                  );
                  return;
                }
              }
            }
          } catch (e) {
            // If check fails, show error
            if (!mounted) return;
            showSnackbar(
              context,
              'Error checking account status: $e',
              isError: true,
            );
            return;
          }

          // User is active member, proceed to main navigation
          if (!mounted) return;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const MainNavigation()),
          );
        } else if (pendingTeamId != null) {
          if (!mounted) return;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const WaitingApprovalScreen(),
            ),
          );
        } else {
          if (!mounted) return;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const QRReferScreen()),
          );
        }
      },
      onLoginError: (message) {
        if (!mounted) return;
        showSnackbar(context, message, isError: true);
      },
    );
  }

	Future<void> _handleGoogleSignIn() async {
		if (_isGoogleLoading || _isLoading) return;

		final handler = GoogleSignInHandler(_authService, context);
		await handler.signInWithGoogle(setLoadingState: _setLoadingState);
	}


  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
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
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 100,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Logo
                    Center(child: _buildLogo()),
                    const SizedBox(height: 24),

                    // Title
                    Center(child: _buildTitle(Theme.of(context))),
                    const SizedBox(height: 32),

                    // Form
                    Form(
                      key: _controller.formKey,
                      child: Column(
                        children: [
                          // Email
                          _buildEmailField(),
                          const SizedBox(height: 16),

                          // Password
                          _buildPasswordField(),
                          const SizedBox(height: 8),

                          // Forgot Password
                          _buildForgotPassword(),

                          // Login Button
                          _buildLoginButton(),
                          const SizedBox(height: 24),

                          OrDivider(),
                          SizedBox(height: 20),
                          GoogleSignInButton(
                            onPressed: _handleGoogleSignIn,
                            isLoading: _isGoogleLoading,
                          ),
                          // Sign Up Link
                          _buildSignUpLink(),
                        ],
                      ),
                    ),
                  ],
                ),
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
                  // ignore: deprecated_member_use
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
                icon: const Icon(
                  Icons.admin_panel_settings,
                  color: Colors.white,
                  size: 28,
                ),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.teal,
                  shape: const CircleBorder(),
                  padding: const EdgeInsets.all(12),
                  shadowColor: Colors.black.withValues(alpha: 0.1),
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
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => const ForgotPassScreen()));
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
