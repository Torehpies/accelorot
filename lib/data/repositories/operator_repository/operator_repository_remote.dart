import '../../models/operator_model.dart';
import '../../services/contracts/operator_service.dart';
import 'operator_repository.dart';

class OperatorRepositoryRemote implements OperatorRepository {
  final OperatorService _service;

  OperatorRepositoryRemote(this._service);

  @override
  Future<List<OperatorModel>> getOperators(String teamId) {
    return _service.fetchTeamOperators(teamId);
  }

  @override
  Future<List<Map<String, dynamic>>> getPendingMembers(String teamId) {
    return _service.fetchPendingMembers(teamId);
  }

  @override
  Future<void> archive(String teamId, String operatorUid) {
    return _service.archiveOperator(teamId: teamId, operatorUid: operatorUid);
  }

  @override
  Future<void> restore(String teamId, String operatorUid) {
    return _service.restoreOperator(teamId: teamId, operatorUid: operatorUid);
  }

  @override
  Future<void> remove(String teamId, String operatorUid) {
    return _service.removeOperator(teamId: teamId, operatorUid: operatorUid);
  }

  @override
  Future<void> accept({
    required String teamId,
    required String requestorId,
    required String name,
    required String email,
    required String pendingDocId,
  }) {
    return _service.acceptInvitation(
      teamId: teamId,
      requestorId: requestorId,
      name: name,
      email: email,
      pendingDocId: pendingDocId,
    );
  }

  @override
  Future<void> decline({
    required String teamId,
    required String requestorId,
    required String pendingDocId,
  }) {
    return _service.declineInvitation(
      teamId: teamId,
      requestorId: requestorId,
      pendingDocId: pendingDocId,
    );
  }
}
