import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_application_1/frontend/screens/admin/admin_screens/admin_main_navigation.dart';
import 'package:flutter_application_1/utils/login_flow_result.dart';
import 'package:flutter_application_1/viewmodels/login_notifier.dart';
import 'package:flutter_application_1/frontend/operator/main_navigation.dart';
import 'package:flutter_application_1/frontend/screens/Onboarding/qr_refer.dart';
import 'package:flutter_application_1/frontend/screens/Onboarding/waiting_approval_screen.dart';
import '../../../utils/snackbar_utils.dart';
import 'package:flutter_application_1/frontend/screens/Onboarding/registration_screen.dart';
import 'package:flutter_application_1/frontend/screens/Onboarding/email_verify.dart';
import 'package:flutter_application_1/frontend/screens/Onboarding/forgot_pass.dart';
import 'package:flutter_application_1/frontend/screens/Onboarding/restricted_access_screen.dart';
import 'package:flutter_application_1/widgets/common/responsive_layout.dart';
import 'mobile_login_view.dart';
import 'desktop_login_view.dart';
import 'login_handlers.dart';

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

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(loginProvider);
    final notifier = ref.read(loginProvider.notifier);

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

    // 2. Delegate to the ResponsiveLayout
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: ResponsiveLayout(
          mobileView: MobileLoginView(handlers: handlers),
          desktopView: DesktopLoginView(handlers: handlers),
        ),
      ),
    );
  }
}

