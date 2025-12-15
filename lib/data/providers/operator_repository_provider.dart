import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../repositories/operator_repository/operator_repository.dart';
import '../repositories/operator_repository/operator_repository_remote.dart';
import '../services/firebase/firebase_operator_service.dart';

final operatorRepositoryProvider = Provider<OperatorRepository>((ref) {
  return OperatorRepositoryRemote(
    FirebaseOperatorService(),
  );
});
