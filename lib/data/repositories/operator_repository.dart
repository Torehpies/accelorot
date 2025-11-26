import 'package:flutter_application_1/data/models/operator_model.dart';
import 'package:flutter_application_1/data/services/contracts/operator_service.dart';

abstract class OperatorRepository {
  Future<List<Operator>> getOperators(String teamId);
  Future<List<Map<String, dynamic>>> getPendingMembers(String teamId);

  Future<void> archive(String teamId, String operatorUid);
  Future<void> restore(String teamId, String operatorUid);
  Future<void> remove(String teamId, String operatorUid);

  Future<void> accept({
    required String teamId,
    required String requestorId,
    required String name,
    required String email,
    required String pendingDocId,
  });

  Future<void> decline({
    required String teamId,
    required String requestorId,
    required String pendingDocId,
  });
}

class OperatorRepositoryImpl implements OperatorRepository {
  final OperatorService service;
  OperatorRepositoryImpl(this.service);

  @override
  Future<List<Operator>> getOperators(String teamId) => service.fetchTeamOperators(teamId);

  @override
  Future<List<Map<String, dynamic>>> getPendingMembers(String teamId) =>
      service.fetchPendingMembers(teamId);

  @override
  Future<void> archive(String teamId, String operatorUid) =>
      service.archiveOperator(teamId: teamId, operatorUid: operatorUid);

  @override
  Future<void> restore(String teamId, String operatorUid) =>
      service.restoreOperator(teamId: teamId, operatorUid: operatorUid);

  @override
  Future<void> remove(String teamId, String operatorUid) =>
      service.removeOperator(teamId: teamId, operatorUid: operatorUid);

  @override
  Future<void> accept({
    required String teamId,
    required String requestorId,
    required String name,
    required String email,
    required String pendingDocId,
  }) =>
      service.acceptInvitation(
        teamId: teamId,
        requestorId: requestorId,
        name: name,
        email: email,
        pendingDocId: pendingDocId,
      );

  @override
  Future<void> decline({
    required String teamId,
    required String requestorId,
    required String pendingDocId,
  }) =>
      service.declineInvitation(
        teamId: teamId,
        requestorId: requestorId,
        pendingDocId: pendingDocId,
      );
}