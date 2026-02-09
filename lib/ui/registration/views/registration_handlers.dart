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
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= kDesktopBreakpoint;
    final isTablet = screenWidth >= kTabletBreakpoint && screenWidth < kDesktopBreakpoint;

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
      labelStyle: TextStyle(
        fontSize: isDesktop ? 14 : (isTablet ? 13 : 11),
      ),
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      contentPadding: EdgeInsets.symmetric(
        horizontal: 12,
        vertical: isDesktop ? 14 : (isTablet ? 14 : 8),
      ),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.green100, width: 2),
      ),
    );

    // Minimized spacing to fit on screen without scrolling
    final fieldHeight = isDesktop ? 52.0 : (isTablet ? 54.0 : 44.0);
    final rowSpacing = isDesktop ? 12.0 : (isTablet ? 8.0 : 5.0);
    final titleSpacing = isDesktop ? 8.0 : (isTablet ? 8.0 : 4.0);
    final sectionSpacing = isDesktop ? 8.0 : (isTablet ? 8.0 : 4.0);
    final footerSpacing = isDesktop ? 3.0 : (isTablet ? 2.0 : 2.0);
    final logoSize = isTablet ? 45.0 : 40.0;
    final inputTextStyle = TextStyle(
      fontSize: isDesktop ? 14 : (isTablet ? 13 : 11),
      height: 1.2,
    );

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (!isDesktop && !isTablet)
          Center(
            child: SvgPicture.asset(
              'assets/images/Accel-O-Rot Logo.svg',
              width: logoSize,
              height: logoSize,
              fit: BoxFit.contain,
              semanticsLabel: 'Accel-O-Rot Logo',
            ),
          ),
        SizedBox(height: isDesktop ? 0 : 8),
        Center(child: _buildTitle(context, theme)),
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
                  style: inputTextStyle,
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
                  style: inputTextStyle,
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
            style: inputTextStyle,
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
            style: inputTextStyle,
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
            style: inputTextStyle,
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
                    hint: Text(
                      'Select a team',
                      style: inputTextStyle,
                    ),
                    items: teams
                        .map(
                          (t) => DropdownMenuItem<Team>(
                            value: t,
                            child: Text(t.teamName, style: inputTextStyle),
                          ),
                        )
                        .toList(),
                    onChanged: notifier.selectTeam,
                    style: inputTextStyle,
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

  Widget _buildTitle(BuildContext buildContext, ThemeData theme) {
    final screenWidth = MediaQuery.of(buildContext).size.width;
    final isDesktop = screenWidth >= kDesktopBreakpoint;
    final isTablet = screenWidth >= kTabletBreakpoint && screenWidth < kDesktopBreakpoint;
    
    return Column(
      children: [
        Text(
          'Create Account',
                  style: TextStyle(
                    fontSize: isDesktop ? 24 : (isTablet ? 26 : 18),
                    fontWeight: FontWeight.bold,
                    color: const Color.fromARGB(255, 59, 59, 59),
                  ),
                ),
        SizedBox(height: isDesktop ? 2 : 4),
        Text(
          'Join us to get started',
          style: TextStyle(
            fontSize: isDesktop ? 14 : (isTablet ? 15 : 10),
            color: theme.hintColor,
          ),
        ),
      ],
    );
  }
}
