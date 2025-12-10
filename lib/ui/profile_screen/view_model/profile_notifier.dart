import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../data/models/profile_model.dart';
import '../../../data/repositories/profile_repository/profile_repository.dart';
import '../../../data/providers/profile_providers.dart';

part 'profile_notifier.g.dart';

class ProfileState {
  final ProfileModel? profile;
  final bool isLoading;
  final String? errorMessage;
  final bool isEditing;

  const ProfileState({
    this.profile,
    this.isLoading = false,
    this.errorMessage,
    this.isEditing = false,
  });

  ProfileState copyWith({
    ProfileModel? profile,
    bool? isLoading,
    String? errorMessage,
    bool? isEditing,
  }) {
    return ProfileState(
      profile: profile ?? this.profile,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      isEditing: isEditing ?? this.isEditing,
    );
  }
}

@riverpod
class ProfileNotifier extends _$ProfileNotifier {
  ProfileRepository get _repository => ref.read(profileRepositoryProvider);

  @override
  ProfileState build() {
    // Initialize and start watching for changes
    _watchProfile();
    return const ProfileState(isLoading: true);
  }

  void _watchProfile() {
    _repository.watchCurrentProfile().listen(
      (profile) {
        if (profile != null) {
          state = state.copyWith(
            profile: profile,
            isLoading: false,
            errorMessage: null,
          );
        }
      },
      onError: (error) {
        state = state.copyWith(
          errorMessage: 'Failed to load profile: $error',
          isLoading: false,
        );
      },
    );
  }

  Future<void> initialize() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final profile = await _repository.getCurrentProfile();
      state = state.copyWith(profile: profile, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Failed to load profile: $e',
        isLoading: false,
      );
    }
  }

  void setEditing(bool value) {
    state = state.copyWith(isEditing: value);
  }

  Future<void> updateProfile({
    required String firstName,
    required String lastName,
  }) async {
    if (state.profile == null) {
      throw Exception('No profile loaded');
    }

    try {
      await _repository.updateCurrentProfile(
        firstName: firstName,
        lastName: lastName,
      );

      // Update local state optimistically
      state = state.copyWith(
        profile: state.profile!.copyWith(
          firstName: firstName,
          lastName: lastName,
        ),
        isEditing: false,
      );
    } catch (e) {
      state = state.copyWith(errorMessage: 'Failed to update profile: $e');
      rethrow;
    }
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}