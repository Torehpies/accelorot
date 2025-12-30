import '../../models/profile_model.dart';


abstract class ProfileRepository {
  /// Get the user profile
  Future<ProfileModel?> getCurrentProfile();
  
  /// Get user profile by UID
  Future<ProfileModel?> getProfileByUid(String uid);

  Future<void> updateCurrentProfile({
    required String firstName,
    required String lastName,
  });
  
  //user's profile for real-time updates
  Stream<ProfileModel?> watchCurrentProfile();
}