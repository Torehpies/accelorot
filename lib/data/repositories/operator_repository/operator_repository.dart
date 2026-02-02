import '../../models/operator_model.dart';

abstract class OperatorRepository {
  Future<List<OperatorModel>> getOperators(String teamId);
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
