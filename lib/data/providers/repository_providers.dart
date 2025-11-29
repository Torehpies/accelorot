import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/repositories/activity_repository.dart';
import '../../../data/repositories/firestore_activity_repository.dart';

final activityRepositoryProvider = Provider<ActivityRepository>((ref) {
  return FirestoreActivityRepository();
});