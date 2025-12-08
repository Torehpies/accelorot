import 'package:flutter/material.dart';
import 'package:flutter_application_1/frontend/components/google_signin_button.dart';
import 'package:flutter_application_1/frontend/components/or_divider.dart';
import 'package:flutter_application_1/frontend/screens/admin/admin_screens/admin_main_navigation.dart';
import 'package:flutter_application_1/utils/login_flow_result.dart';
import 'package:flutter_application_1/viewmodels/login_notifier.dart';
import 'package:flutter_application_1/ui/core/ui/primary_button.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_application_1/frontend/operator/main_navigation.dart';
import 'package:flutter_application_1/frontend/screens/Onboarding/waiting_approval_screen.dart';
import '../../../utils/snackbar_utils.dart';
import 'registration_screen.dart';
import 'email_verify.dart';
import 'forgot_pass.dart';
import 'restricted_access_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isGoogleLoading = false;

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  static const double _kMaxContentWidth = 450.0;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _submitLogin() async {
    if (!mounted) return;
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final email = emailController.text;
    final password = passwordController.text;

    final notifier = ref.read(loginProvider.notifier);

		final result = null;
    //final result = await notifier.loginUser(
    //  email: email,
    //  password: password,
    //);

    if (!mounted) return;

    _handleLoginFlow(result, emailController.text.trim());

    final error = ref.read(loginProvider).errorMessage;
    if (mounted && error != null) {
      showSnackbar(context, error, isError: true);
    }
  }

  void _handleLoginFlow(LoginFlowResult result, String email) {
    if (!mounted) return;

    switch (result) {
      case LoginFlowSuccess():
        showSnackbar(context, 'Login Successful!', isError: false);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainNavigation()),
        );
      case LoginFlowSuccessAdmin():
        showSnackbar(context, 'Admin Login Successful!', isError: false);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const AdminMainNavigation()),
        );
      case LoginFlowNeedsVerification():
        showSnackbar(
          context,
          'Check your email for verification!',
          isError: false,
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => EmailVerifyScreen(email: email),
          ),
        );
      case LoginFlowPendingApproval():
        showSnackbar(context, 'Waiting for team approval!', isError: false);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const WaitingApprovalScreen(),
          ),
        );
      case LoginFlowRestricted(reason: final reason):
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) =>
                RestrictedAccessScreen(reason: reason.toString()),
          ),
        );
      case LoginFlowError(message: final message):
        showSnackbar(context, message.toString(), isError: true);
    }
  }

  Future<void> _handleGoogleSignIn() async {
    if (_isGoogleLoading) return;

    setState(() => _isGoogleLoading = true);

    try {
      final notifier = ref.read(loginProvider.notifier);
      //final result = await notifier.signInWithGoogleAndCheckStatus();
			final result = null;

      _handleLoginFlow(result, '');
    } catch (e) {
      if (mounted) {
        showSnackbar(
          context,
          'A connection error occured during sign-in.',
          isError: true,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isGoogleLoading = false);
      }
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(loginProvider);
    final notifier = ref.read(loginProvider.notifier);

    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            // Full-screen background
            Container(
              decoration: const BoxDecoration(
                // Made const
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.white, Colors.white],
                ),
              ),
            ),

            // Main content: Constrained and Centered for responsiveness
            SingleChildScrollView(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: _kMaxContentWidth,
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 24.0,
                      // Use less vertical padding on wider screens to center the form better
                      vertical: screenWidth > 600 ? 48.0 : 100.0,
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
                          key: _formKey,
                          child: Column(
                            children: [
                              // Email
                              _buildEmailField(),
                              const SizedBox(height: 16),

                              // Password
                              _buildPasswordField(
                                state.obscurePassword,
                                notifier.togglePasswordVisibility,
                              ),
                              const SizedBox(height: 8),

                              // Forgot Password
                              _buildForgotPassword(),

                              // Login Button
                              _buildLoginButton(state.isLoading),
                              const SizedBox(height: 24),

                              const OrDivider(), // Made const
                              const SizedBox(height: 20),
                              GoogleSignInButton(
                                onPressed: () => _handleGoogleSignIn(),
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
              ),
            ),

            // Top-left Home button (Kept position)
            Positioned(
              top: 40,
              left: 16,
              child: IconButton(
                icon: const Icon(Icons.home, color: Colors.white, size: 28),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.teal,
                  shape: const CircleBorder(),
                  padding: const EdgeInsets.all(12),
                  shadowColor: Colors.black.withValues(
                    alpha: 0.1,
                  ), // Fixed usage of .withValues
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

            // Top-right Admin button (Kept position)
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
                  shadowColor: Colors.black.withValues(
                    alpha: 0.1,
                  ), // Fixed usage of .withValues
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
            color: Colors.teal.withValues(
              alpha: 0.3,
            ), // Fixed usage of .withValues
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
      controller: emailController,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        labelText: 'Email Address',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      validator: (value) =>
          value == null || value.isEmpty ? 'Email is required' : null,
    );
  }

  Widget _buildPasswordField(
    bool obscurePassword,
    VoidCallback toggleVisibility,
  ) {
    return TextFormField(
      controller: passwordController,
      obscureText: obscurePassword,
      textInputAction: TextInputAction.done,
      // Fixed: ensures login is submitted when 'Done' is pressed on keyboard
      onFieldSubmitted: (_) => _submitLogin(),
      decoration: InputDecoration(
        labelText: 'Password',
        suffixIcon: IconButton(
          icon: Icon(
            obscurePassword
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
            color: Colors.grey,
          ),
          onPressed: toggleVisibility,
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      validator: (value) =>
          value == null || value.isEmpty ? 'Password is required' : null,
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

  Widget _buildLoginButton(bool isLoading) {
    return SizedBox(
      width: double.infinity,
      child: PrimaryButton(
        text: 'Login',
        onPressed: isLoading ? null : () => _submitLogin(),
        isLoading: isLoading,
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
