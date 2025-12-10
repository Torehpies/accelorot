import 'profile_repository.dart';
import '../../models/profile_model.dart';
import '../../services/contracts/profile_service.dart';


class ProfileRepositoryRemote implements ProfileRepository {
  final ProfileService _service;

  ProfileRepositoryRemote(this._service);

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