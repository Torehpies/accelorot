// lib/data/services/contracts/operator_service.dart

import 'package:flutter_application_1/data/utils/result.dart';
import 'package:flutter_application_1/data/models/app_user.dart';

import '../../models/operator_model.dart';

abstract class OperatorService {
  Future<List<OperatorModel>> fetchTeamOperators(String teamId);
  Future<List<Map<String, dynamic>>> fetchPendingMembers(String teamId);

  Future<void> archiveOperator({
    required String teamId,
    required String operatorUid,
  });
  Future<void> restoreOperator({
    required String teamId,
    required String operatorUid,
  });
  Future<void> removeOperator({
    required String teamId,
    required String operatorUid,
  });

  Future<void> acceptInvitation({
    required String teamId,
    required String requestorId,
    required String name,
    required String email,
    required String pendingDocId,
  });

  Future<void> declineInvitation({
    required String teamId,
    required String requestorId,
    required String pendingDocId,
  });

  Future<Result<AppUser>> addOperator({
    required String email,
    required String password,
    required String firstname,
    required String lastname,
    String? globalRole,
    String? teamRole,
    String? status,
    String? teamId,
  });
}
