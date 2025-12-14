// lib/data/providers/repository_providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/machine_repository/machine_repository.dart'; 
import '../repositories/operator_repository.dart'; 
import '../repositories/machine_repository/machine_repository_remote.dart';
import '../repositories/operator_repository_impl.dart' as impl;
import '../services/firebase/firebase_machine_service.dart';
import '../services/firebase/firebase_operator_service.dart';

final machineRepositoryProvider = Provider<MachineRepository>((ref) {
  return MachineRepositoryRemote(FirebaseMachineService());
});

final operatorRepositoryProvider = Provider<OperatorRepository>((ref) {
  return impl.OperatorRepositoryImpl(FirebaseOperatorService());
});