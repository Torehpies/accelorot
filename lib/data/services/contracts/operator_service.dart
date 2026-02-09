// lib/data/services/contracts/operator_service.dart

import 'package:flutter_application_1/data/utils/result.dart';
import 'package:flutter_application_1/data/models/app_user.dart';

import '../../models/operator_model.dart';

abstract class OperatorService {
  Future<List<OperatorModel>> fetchTeamOperators(String teamId);
  Future<Result<AppUser>> addUser({
    required String email,
    required String password,
    required String firstname,
    required String lastname,
    String? globalRole,
    String? teamRole,
    String? status,
    String? requestTeamId,
  });
}
