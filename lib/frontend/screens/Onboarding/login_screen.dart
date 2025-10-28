import 'package:flutter/material.dart';
// Note: All external imports are preserved as requested by the user.
import 'package:flutter_application_1/frontend/components/google_signin_button.dart';
import 'package:flutter_application_1/frontend/components/or_divider.dart';
import 'package:flutter_application_1/frontend/screens/admin/admin_screens/admin_main_navigation.dart';
import 'package:flutter_application_1/utils/login_flow_result.dart';
import 'package:flutter_application_1/viewmodels/login_notifier.dart';
import 'package:flutter_application_1/widgets/common/primary_button.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_application_1/frontend/operator/main_navigation.dart';
import 'package:flutter_application_1/frontend/screens/Onboarding/qr_refer.dart';
import 'package:flutter_application_1/frontend/screens/Onboarding/waiting_approval_screen.dart';
import '../../../utils/snackbar_utils.dart';
import 'registration_screen.dart';
import 'email_verify.dart';
import 'forgot_pass.dart';
import 'restricted_access_screen.dart';

// --- 1. Constants for Responsiveness ---
const int kDesktopBreakpoint = 800;
const double _kMaxFormWidth = 450.0;

// --- 2. Responsive Layout Widget (Reusable) ---

/// Determines and displays the correct view based on screen width.
class ResponsiveLayout extends StatelessWidget {
  final Widget mobileView;
  final Widget desktopView;

  const ResponsiveLayout({
    super.key,
    required this.mobileView,
    required this.desktopView,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= kDesktopBreakpoint) {
          // Screens wider than 800 get the split-panel desktop view
          return desktopView;
        }
        // Screens 800 or less get the mobile view
        return mobileView;
      },
    );
  }
}

// ---------------------------------------------------------------------
// --- 3. STATE & LOGIC (All original methods preserved here) ---
// ---------------------------------------------------------------------

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

  @override
  void initState() {
    super.initState();
  }

  // --- Login Submission Logic ---
  Future<void> _submitLogin() async {
    if (!mounted) return;
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final email = emailController.text;
    final password = passwordController.text;

    final notifier = ref.read(loginProvider.notifier);
    final result = await notifier.loginUser(
      email: email,
      password: password,
    );

    if (!mounted) return;

    _handleLoginFlow(result, emailController.text.trim());

    final error = ref.read(loginProvider).errorMessage;
    if (mounted && error != null) {
      showSnackbar(context, error, isError: true);
    }
  }

  // --- Navigation Logic ---
  void _handleLoginFlow(LoginFlowResult result, String email) {
    if (!mounted) return;

    switch (result) {
      case LoginFlowSuccess():
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainNavigation()),
        );
      case LoginFlowSuccessAdmin():
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

  // --- Google Sign-In Logic ---
  Future<void> _handleGoogleSignIn() async {
    if (_isGoogleLoading) return;

    setState(() => _isGoogleLoading = true);

    try {
      final notifier = ref.read(loginProvider.notifier);
      final result = await notifier.signInWithGoogleAndCheckStatus();
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

  // --- Main Build Method (Now only delegates to ResponsiveLayout) ---
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(loginProvider);
    final notifier = ref.read(loginProvider.notifier);

    // Collect all necessary handlers and state properties to pass to the UI
    final LoginHandlers handlers = LoginHandlers(
      formKey: _formKey,
      emailController: emailController,
      passwordController: passwordController,
      isLoading: state.isLoading,
      isGoogleLoading: _isGoogleLoading,
      obscurePassword: state.obscurePassword,
      togglePasswordVisibility: notifier.togglePasswordVisibility,
      onSubmitLogin: _submitLogin,
      onGoogleSignIn: _handleGoogleSignIn,
      onNavigateToForgotPass: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const ForgotPassScreen()),
      ),
      onNavigateToRegistration: () => Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const RegistrationScreen()),
      ),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: ResponsiveLayout(
          // Pass the collected handlers to the specific view widgets
          mobileView: MobileLoginView(handlers: handlers),
          desktopView: DesktopLoginView(handlers: handlers),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------
// --- 4. DATA MODEL: Handlers to pass state logic to the UI views ---
// ---------------------------------------------------------------------

/// Simple class to bundle all the methods/controllers/state needed by the UI
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

// ---------------------------------------------------------------------
// --- 5. SHARED UI: The Form content used by both views ---
// ---------------------------------------------------------------------

/// Encapsulates the core login form content, receiving data via LoginHandlers
class _LoginFormContent extends StatelessWidget {
  final LoginHandlers handlers;
  final bool isDesktop;

  const _LoginFormContent({required this.handlers, this.isDesktop = false});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final verticalPadding = isDesktop ? 0.0 : 32.0;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(child: _buildLogo()),
        const SizedBox(height: 24),
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
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
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
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Password is required' : null,
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
                  // Call the handler function directly
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
                          color: Colors.teal, fontWeight: FontWeight.bold),
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

  // --- Helper Widgets (moved from the State class) ---
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
            color: Colors.teal.withOpacity(0.3),
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
}

// ---------------------------------------------------------------------
// --- 6. MOBILE VIEW (Original layout, constrained and centered) ---
// ---------------------------------------------------------------------

class MobileLoginView extends StatelessWidget {
  final LoginHandlers handlers;
  const MobileLoginView({super.key, required this.handlers});

  @override
  Widget build(BuildContext context) {
    // Mobile/Tablet uses a SingleChildScrollView to ensure the form is usable when the keyboard is up
    return SingleChildScrollView(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: _kMaxFormWidth,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 80.0,
            ),
            // The content is now delegated to the shared form widget
            child: _LoginFormContent(handlers: handlers),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------
// --- 7. DESKTOP VIEW (New split-screen layout) ---
// ---------------------------------------------------------------------

class DesktopLoginView extends StatelessWidget {
  final LoginHandlers handlers;
  const DesktopLoginView({super.key, required this.handlers});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Left Side: Branding and Contextual Information
        Expanded(
          flex: 2,
          child: Container(
            // Use a strong, branded color for visual separation
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.teal.shade600, Colors.teal.shade800],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: const Center(
              child: Padding(
                padding: EdgeInsets.all(40.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Team Access Portal',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 48,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.2,
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Login to your account to manage reports, users, and data insights.',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 18,
                      ),
                    ),
                    SizedBox(height: 80),
                    Icon(Icons.lock_outline, color: Colors.white, size: 100),
                  ],
                ),
              ),
            ),
          ),
        ),

        // Right Side: The Form Area
        Expanded(
          flex: 3,
          child: SingleChildScrollView(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: _kMaxFormWidth),
                child: Padding(
                  padding: const EdgeInsets.all(48.0),
                  // The content is delegated to the shared form widget
                  child: _LoginFormContent(handlers: handlers, isDesktop: true),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

