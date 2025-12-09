import '../models/profile_model.dart';
import '../services/contracts/profile_service.dart';

abstract class ProfileRepository {
  /// Get the current user's profile
  Future<ProfileModel?> getCurrentProfile();
  
  /// Get any user's profile by UID
  Future<ProfileModel?> getProfileByUid(String uid);
  
  /// Update the current user's profile
  Future<void> updateCurrentProfile({
    required String firstName,
    required String lastName,
  });
  
  /// Watch current user's profile for real-time updates
  Stream<ProfileModel?> watchCurrentProfile();
}

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileService _service;

  ProfileRepositoryImpl(this._service);

  @override
  Future<ProfileModel?> getCurrentProfile() =>
      _service.fetchCurrentUserProfile();

  @override
  Future<ProfileModel?> getProfileByUid(String uid) =>
      _service.fetchUserProfile(uid);

  @override
  Future<void> updateCurrentProfile({
    required String firstName,
    required String lastName,
  }) async {
    final profile = await _service.fetchCurrentUserProfile();
    if (profile == null) throw Exception('User not authenticated');
    
    return _service.updateProfile(
      uid: profile.uid,
      firstName: firstName,
      lastName: lastName,
    );
  }

  @override
  Stream<ProfileModel?> watchCurrentProfile() =>
      _service.watchCurrentUserProfile();
}