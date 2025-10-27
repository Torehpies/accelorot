import 'package:flutter/material.dart';
import 'package:flutter_application_1/frontend/components/google_signin_button.dart';
import 'package:flutter_application_1/frontend/components/or_divider.dart';
import 'package:flutter_application_1/frontend/screens/admin/admin_screens/admin_main_navigation.dart';
import 'package:flutter_application_1/frontend/screens/main_navigation.dart';
import 'package:flutter_application_1/frontend/screens/qr_refer.dart';
import 'package:flutter_application_1/frontend/screens/waiting_approval_screen.dart';
import 'package:flutter_application_1/utils/login_flow_result.dart';
import 'package:flutter_application_1/viewmodels/login_viewmodel.dart';
import 'package:flutter_application_1/widgets/common/primary_button.dart';
import 'package:provider/provider.dart';
import '../../utils/snackbar_utils.dart';
import 'registration_screen.dart';
import 'email_verify.dart';
import 'forgot_pass.dart';
import 'restricted_access_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isGoogleLoading = false;
  
  // Define a max width for the login form on wide screens (web/desktop)
  static const double _kMaxContentWidth = 450.0;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _submitLogin(LoginViewModel viewModel) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final result = await viewModel.loginUser();

    _handleLoginFlow(result, viewModel.emailController.text.trim());
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
      case LoginFlowNeedsReferral():
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const QRReferScreen()),
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

  Future<void> _handleGoogleSignIn(LoginViewModel viewModel) async {
    if (_isGoogleLoading || viewModel.isLoading) return;

    setState(() => _isGoogleLoading = true);

    try {
      final result = await viewModel.signInWithGoogleAndCheckStatus();
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Theme.of(context) is implicitly used later, so this line is redundant
    // Theme.of(context);

    // Get screen width to calculate dynamic padding/positioning
    final screenWidth = MediaQuery.of(context).size.width;

    return Consumer<LoginViewModel>(
      builder: (context, viewModel, child) {
        return Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: Stack(
              children: [
                // Full-screen background
                Container(
                  decoration: const BoxDecoration( // Made const
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
                                  _buildEmailField(viewModel),
                                  const SizedBox(height: 16),

                                  // Password
                                  _buildPasswordField(viewModel),
                                  const SizedBox(height: 8),

                                  // Forgot Password
                                  _buildForgotPassword(),

                                  // Login Button
                                  _buildLoginButton(viewModel),
                                  const SizedBox(height: 24),

                                  const OrDivider(), // Made const
                                  const SizedBox(height: 20),
                                  GoogleSignInButton(
                                    onPressed: () => _handleGoogleSignIn(viewModel),
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
                      shadowColor: Colors.black.withOpacity(0.1), // Fixed usage of .withValues
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
                      shadowColor: Colors.black.withOpacity(0.1), // Fixed usage of .withValues
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
            color: Colors.teal.withOpacity(0.3), // Fixed usage of .withValues
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

  Widget _buildEmailField(LoginViewModel viewModel) {
    return TextFormField(
      controller: viewModel.emailController,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        labelText: 'Email Address',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      validator: viewModel.validateEmail,
    );
  }

  Widget _buildPasswordField(LoginViewModel viewModel) {
    return TextFormField(
      controller: viewModel.passwordController,
      obscureText: viewModel.obscurePassword,
      textInputAction: TextInputAction.done,
      // Fixed: ensures login is submitted when 'Done' is pressed on keyboard
      onFieldSubmitted: (_) => _submitLogin(viewModel), 
      decoration: InputDecoration(
        labelText: 'Password',
        suffixIcon: IconButton(
          icon: Icon(
            viewModel.obscurePassword
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
            color: Colors.grey,
          ),
          onPressed: viewModel.togglePasswordVisibility,
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      validator: viewModel.validatePassword,
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

  Widget _buildLoginButton(LoginViewModel viewModel) {
    return SizedBox(
      width: double.infinity,
      child: PrimaryButton(
        text: 'Login',
        onPressed: viewModel.isLoading ? null : () => _submitLogin(viewModel),
        isLoading: viewModel.isLoading,
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

