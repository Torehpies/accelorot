import 'package:flutter/material.dart';
import 'package:flutter_application_1/data/providers/auth_providers.dart';
import 'package:flutter_application_1/data/services/api/model/team/team.dart';
import 'package:flutter_application_1/ui/core/ui/app_snackbar.dart';
import 'package:flutter_application_1/ui/core/ui/primary_button.dart';
import 'package:flutter_application_1/ui/registration/widgets/register_field_box.dart';
import 'package:flutter_application_1/ui/social_login/view_model/complete_profile_notifier.dart';
import 'package:flutter_application_1/utils/ui_message.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';

class CompleteProfileScreen extends ConsumerStatefulWidget {
  const CompleteProfileScreen({super.key});

  @override
  ConsumerState<CompleteProfileScreen> createState() =>
      _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends ConsumerState<CompleteProfileScreen> {
  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController();
    _lastNameController = TextEditingController();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(completeProfileProvider);
    final notifier = ref.read(completeProfileProvider.notifier);

    if (_firstNameController.text != state.firstName) {
      _firstNameController.text = state.firstName;
      _firstNameController.selection = TextSelection.fromPosition(
        TextPosition(offset: _firstNameController.text.length),
      );
    }

    if (_lastNameController.text != state.lastName) {
      _lastNameController.text = state.lastName;
      _lastNameController.selection = TextSelection.fromPosition(
        TextPosition(offset: _lastNameController.text.length),
      );
    }

    // Listen for messages (success/error)
    ref.listen(completeProfileProvider, (previous, next) {
      if (next.message != null && previous?.message != next.message) {
        final message = next.message!;
        if (!context.mounted) return;

        message.maybeWhen(
          success: (text) {
            AppSnackbar.success(context, text);
          },
          error: (text) => AppSnackbar.error(context, text),
          orElse: () {},
        );

        WidgetsBinding.instance.addPostFrameCallback((_) {
          notifier.clearMessage();
        });
      }
    });

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 450),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: SvgPicture.asset(
                      'assets/images/Accelorot_logo.svg',
                      width: 65,
                      height: 65,
                      fit: BoxFit.contain,
                      semanticsLabel: 'Accelorot logo',
                    ),
                  ),
                  const SizedBox(height: 10),
                  Center(
                    child: Column(
                      children: [
                        const Text(
                          'Complete Profile',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 59, 59, 59),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'One last step to get you started',
                          style: TextStyle(
                            fontSize: 16,
                            color: Theme.of(context).hintColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // First Name Field
                  RegisterFieldBox(
                    child: TextFormField(
                      controller: _firstNameController,
                      textCapitalization: TextCapitalization.words,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        labelText: 'First Name',
                        errorText: state.firstNameError,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onChanged: notifier.updateFirstName,
                    ),
                  ),

                  // Last Name Field
                  RegisterFieldBox(
                    child: TextFormField(
                      controller: _lastNameController,
                      textCapitalization: TextCapitalization.words,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        labelText: 'Last Name',
                        errorText: state.lastNameError,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onChanged: notifier.updateLastName,
                    ),
                  ),

                  // Team Selection
                  RegisterFieldBox(
                    child: state.teams.when(
                      data: (teams) => teams.isEmpty
                          ? const Text('No teams available')
                          : DropdownButtonFormField<Team>(
                              initialValue: state.selectedTeam,
                              decoration: InputDecoration(
                                labelText: 'Select a Team',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
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
                      error: (e, _) => Text('Error loading teams: $e'),
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                    ),
                  ),

                  const SizedBox(height: 24),

                  PrimaryButton(
                    text: 'Complete Registration',
                    isLoading: state.isSubmitting,
                    onPressed: notifier.submitProfile,
                    enabled: state.isFormValid && !state.isSubmitting,
                  ),

                  const SizedBox(height: 16),

                  TextButton(
                    onPressed: () {
                      ref.read(authRepositoryProvider).signOut();
                    },
                    child: const Text("Cancel & Sign Out"),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
