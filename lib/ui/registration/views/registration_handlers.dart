import 'package:flutter/material.dart';
import 'package:flutter_application_1/data/services/api/model/team/team.dart';
import 'package:flutter_application_1/frontend/components/google_signin_button.dart';
import 'package:flutter_application_1/frontend/components/or_divider.dart';
import 'package:flutter_application_1/ui/core/themes/app_theme.dart';
import 'package:flutter_application_1/ui/core/ui/app_snackbar.dart';
import 'package:flutter_application_1/ui/core/ui/primary_button.dart';
import 'package:flutter_application_1/ui/registration/view_model/registration_notifier.dart';
import 'package:flutter_application_1/utils/ui_message.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

const double kMaxFormWidth = 450.0;

class RegistrationFormContent extends ConsumerWidget {
  const RegistrationFormContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDesktop = MediaQuery.of(context).size.width >= kTabletBreakpoint;

    final state = ref.watch(registrationProvider);
    final notifier = ref.read(registrationProvider.notifier);

    ref.listen(registrationProvider, (previous, next) {
      if (next.message != null && previous?.message != next.message) {
        final message = next.message!;
        if (!context.mounted) return;

        message.maybeWhen(
          success: (text) => AppSnackbar.success(context, text),
          error: (text) => AppSnackbar.error(context, text),
          orElse: () {},
        );

        WidgetsBinding.instance.addPostFrameCallback((_) {
          notifier.clearMessage();
        });
      }
    });

    InputDecoration inputDecoration(
      String labelText,
      String? errorText, {
      Widget? suffixIcon,
      Icon? prefixIcon,
    }) => InputDecoration(
      errorText: errorText,
      errorStyle: const TextStyle(height: 0.5),
      labelText: labelText,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.green100, width: 2),
      ),
    );

    final fieldHeight = isDesktop ? 52.0 : 65.0;
    final rowSpacing = isDesktop ? 12.0 : 16.0;
    final titleSpacing = isDesktop ? 8.0 : 32.0;
    final sectionSpacing = isDesktop ? 8.0 : 18.0;
    final footerSpacing = isDesktop ? 4.0 : 6.0;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (!isDesktop)
          Center(
            child: SvgPicture.asset(
              'assets/images/Accel-O-Rot Logo.svg',
              width: 65,
              height: 65,
              fit: BoxFit.contain,
              semanticsLabel: 'Accel-O-Rot Logo',
            ),
          ),
        const SizedBox(height: 10),
        Center(child: _buildTitle(theme)),
        SizedBox(height: titleSpacing),

        Row(
          children: [
            // First Name Field
            Expanded(
              child: SizedBox(
                height: fieldHeight,
                child: TextField(
                  textInputAction: TextInputAction.next,
                  decoration: inputDecoration(
                    'First Name',
                    state.firstNameError,
                  ),
                  onChanged: notifier.updateFirstName,
                  autofocus: true,
                ),
              ),
            ),
            SizedBox(width: rowSpacing),
            // Last Name Field
            Expanded(
              child: SizedBox(
                height: fieldHeight,
                child: TextField(
                  textInputAction: TextInputAction.next,
                  onChanged: notifier.updateLastName,
                  decoration: inputDecoration('Last Name', state.lastNameError),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: rowSpacing),
        SizedBox(
          height: fieldHeight,
          child: TextField(
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            decoration: inputDecoration(
              'Email Address',
              state.emailError,
              prefixIcon: const Icon(Icons.email_outlined),
            ),
            onChanged: notifier.updateEmail,
          ),
        ),
        SizedBox(height: rowSpacing),
        SizedBox(
          height: fieldHeight,
          child: TextField(
            obscureText: state.obscurePassword,
            textInputAction: TextInputAction.next,
            decoration: inputDecoration(
              'Password',
              state.passwordError,
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                icon: Icon(
                  state.obscurePassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: Colors.grey,
                ),
                onPressed: notifier.togglePasswordVisibility,
              ),
            ),
            onChanged: notifier.updatePassword,
          ),
        ),
        SizedBox(height: rowSpacing),
        SizedBox(
          height: fieldHeight,
          child: TextField(
            obscureText: state.obscureConfirmPassword,
            textInputAction: TextInputAction.done,
            decoration: inputDecoration(
              'Confirm Password',
              state.confirmPasswordError,
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                icon: Icon(
                  state.obscureConfirmPassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: Colors.grey,
                ),
                onPressed: notifier.toggleConfirmPasswordVisibility,
              ),
            ),
            onChanged: notifier.updateConfirmPassword,
          ),
        ),
        SizedBox(height: rowSpacing),
        SizedBox(
          height: fieldHeight,
          child: state.teams.when(
            data: (teams) => teams.isEmpty
                ? const Text('No teams available')
                : DropdownButtonFormField<Team>(
                    initialValue: state.selectedTeam,
                    hint: const Text('Select a team'),
                    items: teams
                        .map(
                          (t) => DropdownMenuItem<Team>(
                            value: t,
                            child: Text(t.teamName),
                          ),
                        )
                        .toList(),
                    onChanged: notifier.selectTeam,
                  ),
            error: (e, _) => Text('Error: $e'),
            loading: () => const Center(child: CircularProgressIndicator()),
          ),
        ),
        SizedBox(
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (!state.isFormValid) ...[
                const Text(
                  '*Please complete all Fields',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
              ],
              PrimaryButton(
                text: 'Register',
                isLoading: state.isRegistrationLoading,
                onPressed: notifier.registerUser,
                enabled: state.isFormValid && !state.isRegistrationLoading,
              ),
            ],
          ),
        ),

        SizedBox(height: sectionSpacing),
        const OrDivider(),
        SizedBox(height: sectionSpacing),

        Center(
          child: GoogleSignInButton(
            isLoading: state.isGoogleLoading,
            onPressed: notifier.signInWithGoogle,
          ),
        ),

        // Sign In Link
        SizedBox(height: footerSpacing),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Already have an account? "),
            TextButton(
              onPressed: () => context.go('/signin'),
              child: Text(
                "Sign in",
                style: TextStyle(
                  color: AppColors.green100,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTitle(ThemeData theme) {
    return Column(
      children: [
        Text(
          'Create Account',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: const Color.fromARGB(255, 59, 59, 59),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Join us to get started',
          style: TextStyle(fontSize: 16, color: theme.hintColor),
        ),
      ],
    );
  }
}
