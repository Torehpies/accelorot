import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/firebase/firebase_profile_service.dart';
import '../services/contracts/profile_service.dart';
import '../repositories/profile_repository.dart';

final profileServiceProvider = Provider<ProfileService>((ref) {
  return FirebaseProfileService();
});

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepositoryImpl(ref.read(profileServiceProvider));
});