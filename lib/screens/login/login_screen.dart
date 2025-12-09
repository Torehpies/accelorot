import 'package:flutter/material.dart';
import 'package:flutter_application_1/ui/core/themes/app_theme.dart';
import 'package:flutter_application_1/viewmodels/login_notifier.dart';
import 'package:flutter_application_1/ui/core/ui/responsive_layout.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../utils/snackbar_utils.dart';
import 'desktop_login_view.dart';
import 'login_handlers.dart';
import 'mobile_login_view.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    ref.listenManual(loginProvider, (previous, next) {
      if (next.errorMessage != null &&
          previous?.errorMessage != next.errorMessage) {
        if (mounted) {
          showSnackbar(context, next.errorMessage!, isError: true);

				ref.read(loginProvider.notifier).clearError();
        }
      }
    });

		emailController.addListener(() {
			ref.read(loginProvider.notifier).updateEmail(emailController.text.trim());
		});
		passwordController.addListener(() {
			ref.read(loginProvider.notifier).updatePassword(passwordController.text);
		});
  }

  Future<void> _submitLogin() async {
    if (_formKey.currentState?.validate() ?? false) {
			await ref.read(loginProvider.notifier).signInWithEmail();
    }
  }

  Future<void> _handleGoogleSignIn() async {
		await ref.read(loginProvider.notifier).signInWithGoogle();
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
      obscurePassword: state.obscurePassword,
      togglePasswordVisibility: notifier.togglePasswordVisibility,
      onSubmitLogin: _submitLogin,
      onGoogleSignIn: _handleGoogleSignIn,
      onNavigateToForgotPass: () => context.push('/forgot-password'),
      onNavigateToRegistration: () => context.go('/signup'),
    );

    // 2. Delegate to the ResponsiveLayout
    return Scaffold(
      backgroundColor: AppColors.background2,
      body: SafeArea(
        child: ResponsiveLayout(
          mobileView: MobileLoginView(handlers: handlers),
          desktopView: DesktopLoginView(handlers: handlers),
        ),
      ),
    );
  }
}
