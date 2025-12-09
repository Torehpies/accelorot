import 'package:flutter/material.dart';
import 'package:flutter_application_1/ui/registration/view_model/registration_notifier.dart';
import 'package:flutter_application_1/ui/core/ui/responsive_layout.dart';
import 'package:flutter_application_1/providers/auth_providers.dart';
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
        }
      }
      if (next.successMessage != null &&
          previous?.successMessage != next.successMessage) {
        if (mounted) {
          showSnackbar(context, next.successMessage!);
        }
      }
    });
  }

  // --- Handler Methods ---

  void _submitRegistration() async {
    if (_formKey.currentState?.validate() ?? false) {
      final notifier = ref.read(registrationProvider.notifier);
      final state = ref.read(registrationProvider);

      if (state.selectedTeamId == null) {
        showSnackbar(context, 'Please select a team.');
        return;
      }

      await notifier.registerUser(
        firstName: firstNameController.text.trim(),
        lastName: lastNameController.text.trim(),
        email: emailController.text.trim(),
        password: passwordController.text,
      );
    }
  }

  Future<void> _handleGoogleSignIn() async {
    await ref.read(registrationProvider.notifier).signInWithGoogle();
  }

  void _onTeamSelected(String? teamId) {
    ref.read(registrationProvider.notifier).updateSelectedTeamId(teamId);
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
    final isLoading = ref.watch(
      registrationProvider.select((state) => state.isRegistrationLoading),
    );
    final isGoogleLoading = ref.watch(
      registrationProvider.select((state) => state.isGoogleLoading),
    );
    final obscurePassword = ref.watch(
      registrationProvider.select((state) => state.obscurePassword),
    );
    final obscureConfirmPassword = ref.watch(
      registrationProvider.select((state) => state.obscureConfirmPassword),
    );
    final selectedTeamId = ref.watch(
      registrationProvider.select((state) => state.selectedTeamId),
    );
    final notifier = ref.read(registrationProvider.notifier);
    final asyncTeamList = ref.watch(teamListProvider);

    final RegistrationHandlers handlers = RegistrationHandlers(
      formKey: _formKey,
      firstNameController: firstNameController,
      lastNameController: lastNameController,
      emailController: emailController,
      passwordController: passwordController,
      confirmPasswordController: confirmPasswordController,

      asyncTeamList: asyncTeamList,
      selectedTeamId: selectedTeamId,
      onTeamSelected: _onTeamSelected,

      // State from Notifier
      isLoading: isLoading,
      isGoogleLoading: isGoogleLoading,
      obscurePassword: obscurePassword,
      obscureConfirmPassword: obscureConfirmPassword,

      // Methods from Notifier
      togglePasswordVisibility: notifier.togglePasswordVisibility,
      toggleConfirmPasswordVisibility: notifier.toggleConfirmPasswordVisibility,

      // Local Handler Methods
      onSubmitRegistration: _submitRegistration,
      onGoogleSignIn: _handleGoogleSignIn,

      // Navigation
      onNavigateToLogin: () => context.go('/signin'),
    );

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
