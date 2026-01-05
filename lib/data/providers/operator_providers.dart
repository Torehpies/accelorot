import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/firebase/firebase_operator_service.dart';
import '../repositories/operator_repository/operator_repository.dart';
import '../repositories/operator_repository/operator_repository_remote.dart';

final operatorServiceProvider = Provider<FirebaseOperatorService>((ref) {
  return FirebaseOperatorService();
});

final operatorRepositoryProvider = Provider<OperatorRepository>((ref) {
  final service = ref.read(operatorServiceProvider);
  return OperatorRepositoryRemote(service);
});
