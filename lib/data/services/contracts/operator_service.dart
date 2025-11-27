import 'package:flutter_application_1/data/models/operator_model.dart';

abstract class OperatorService {
  Future<List<Operator>> fetchTeamOperators(String teamId);
  Future<List<Map<String, dynamic>>> fetchPendingMembers(String teamId);

  Future<void> archiveOperator({required String teamId, required String operatorUid});
  Future<void> restoreOperator({required String teamId, required String operatorUid});
  Future<void> removeOperator({required String teamId, required String operatorUid});

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
}