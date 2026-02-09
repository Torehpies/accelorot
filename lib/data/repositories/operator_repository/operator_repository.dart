import '../../models/operator_model.dart';

abstract class OperatorRepository {
  Future<List<OperatorModel>> getOperators(String teamId);
}
