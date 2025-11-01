import 'package:flutter/material.dart';
import 'package:flutter_application_1/viewmodels/registration_notifier.dart';
import 'package:flutter_application_1/widgets/common/responsive_layout.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../utils/snackbar_utils.dart';
import 'desktop_registration_view.dart';
import 'mobile_registration_view.dart';
import 'registration_handlers.dart';

class RegistrationScreen extends ConsumerStatefulWidget {
  const RegistrationScreen({super.key});

  @override
  ConsumerState<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends ConsumerState<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();

  // Initialize all text controllers
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    
    // 1. Listen for errors from the notifier
    ref.listenManual(registrationProvider, (previous, next) {
      if (next.errorMessage != null &&
          previous?.errorMessage != next.errorMessage) {
        if (mounted) {
          showSnackbar(context, next.errorMessage!, isError: true);
          // Clear the error message after showing it
          ref.read(registrationProvider.notifier).clearError();
        }
      }
    });

    // 2. Link TextControllers to Notifier state updates
    firstNameController.addListener(() {
      ref.read(registrationProvider.notifier).updateFirstName(firstNameController.text.trim());
    });
    lastNameController.addListener(() {
      ref.read(registrationProvider.notifier).updateLastName(lastNameController.text.trim());
    });
    emailController.addListener(() {
      ref.read(registrationProvider.notifier).updateEmail(emailController.text.trim());
    });
    passwordController.addListener(() {
      ref.read(registrationProvider.notifier).updatePassword(passwordController.text);
    });
    confirmPasswordController.addListener(() {
      ref.read(registrationProvider.notifier).updateConfirmPassword(confirmPasswordController.text);
    });
  }

  // --- Handler Methods ---

  Future<void> _submitRegistration() async {
    if (_formKey.currentState?.validate() ?? false) {
			await ref.read(registrationProvider.notifier).registerUser();
    }
  }

  Future<void> _handleGoogleSignIn() async {
		await ref.read(registrationProvider.notifier).signInWithGoogle();
  }

  // --- Dispose Controllers ---

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Watch the state to trigger UI rebuilds
    final state = ref.watch(registrationProvider);
    final notifier = ref.read(registrationProvider.notifier);

    // 3. Create the Handlers object
    final RegistrationHandlers handlers = RegistrationHandlers(
      formKey: _formKey,
      firstNameController: firstNameController,
      lastNameController: lastNameController,
      emailController: emailController,
      passwordController: passwordController,
      confirmPasswordController: confirmPasswordController,
      
      // State from Notifier
      isLoading: state.isLoading,
      isGoogleLoading: state.isGoogleLoading,
      obscurePassword: state.obscurePassword,
      obscureConfirmPassword: state.obscureConfirmPassword,

      // Methods from Notifier
      togglePasswordVisibility: notifier.togglePasswordVisibility,
      toggleConfirmPasswordVisibility: notifier.toggleConfirmPasswordVisibility,
      
      // Local Handler Methods
      onSubmitRegistration: _submitRegistration,
      onGoogleSignIn: _handleGoogleSignIn,
      
      // Navigation
      onNavigateToLogin: () => context.go('/signin'),
    );

    // 4. Delegate to the ResponsiveLayout
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: ResponsiveLayout(
          mobileView: MobileRegistrationView(handlers: handlers),
          // We will define this next
          desktopView: DesktopRegistrationView(handlers: handlers),
        ),
      ),
    );
  }
}
