import '../../models/profile_model.dart';

abstract class ProfileService {
  /// Fetch the current authenticated user's profile
  Future<ProfileModel?> fetchCurrentUserProfile();
  
  /// Fetch any user's profile by UID
  Future<ProfileModel?> fetchUserProfile(String uid);
  

  Future<void> updateProfile({
    required String uid,
    required String firstName,
    required String lastName,
  });
  
  /// Stream current user's profile for real-time updates
  Stream<ProfileModel?> watchCurrentUserProfile();
}