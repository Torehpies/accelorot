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
}
