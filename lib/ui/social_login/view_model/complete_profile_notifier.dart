import 'package:flutter_application_1/data/providers/auth_providers.dart';
import 'package:flutter_application_1/data/providers/core_providers.dart';
import 'package:flutter_application_1/data/providers/team_providers.dart';
import 'package:flutter_application_1/data/services/api/model/team/team.dart';
import 'package:flutter_application_1/ui/social_login/view_model/complete_profile_state.dart';
import 'package:flutter_application_1/utils/ui_message.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'complete_profile_notifier.g.dart';

@riverpod
class CompleteProfileNotifier extends _$CompleteProfileNotifier {
  @override
  CompleteProfileState build() {
    Future.microtask(() => _initialize());
    return const CompleteProfileState();
  }

  Future<void> _initialize() async {
    // Pre-fill name from Google data if available
    final user = ref.read(firebaseAuthProvider).currentUser;
    if (user?.displayName != null) {
      final names = user!.displayName!.split(' ');
      final firstName = names.isNotEmpty ? names.first : '';
      final lastName = names.length > 1 ? names.sublist(1).join(' ') : '';
      
      state = state.copyWith(
        firstName: state.firstName.isEmpty ? firstName : state.firstName,
        lastName: state.lastName.isEmpty ? lastName : state.lastName,
      );
      validateForm();
    }

    state = state.copyWith(teams: const AsyncValue.loading());
    
    // Load teams
    state = state.copyWith(
      teams: await AsyncValue.guard(
        () => ref.read(teamRepositoryProvider).getTeams(),
      ),
    );
  }

  void updateFirstName(String value) {
    state = state.copyWith(
      firstName: value,
      firstNameError: _validateName(value),
    );
    validateForm();
  }

  void updateLastName(String value) {
    state = state.copyWith(
      lastName: value,
      lastNameError: _validateName(value),
    );
    validateForm();
  }

  void selectTeam(Team? team) {
    state = state.copyWith(selectedTeam: team);
    validateForm();
  }

  void validateForm() {
    final isValid = state.firstName.isNotEmpty &&
        state.lastName.isNotEmpty &&
        state.selectedTeam != null &&
        state.firstNameError == null &&
        state.lastNameError == null;
    
    state = state.copyWith(isFormValid: isValid);
  }

  String? _validateName(String value) {
    if (value.isEmpty) return 'Required';
    if (value.length < 2) return 'Too short';
    return null;
  }

  Future<void> submitProfile() async {
    if (!state.isFormValid) return;

    state = state.copyWith(isSubmitting: true);

    final result = await ref.read(authRepositoryProvider).completeSocialLogin(
      firstName: state.firstName.trim(),
      lastName: state.lastName.trim(),
      teamId: state.selectedTeam!.teamId!,
    );

    if (result.isFailure) {
      state = state.copyWith(
        isSubmitting: false,
        message: UiMessage.error(result.asFailure.userFriendlyMessage),
      );
    } else {
      state = state.copyWith(
        isSubmitting: false,
        message: UiMessage.success('Profile completed successfully!'),
      );
    }
  }

  void clearMessage() {
    state = state.copyWith(message: null);
  }
}
