import 'package:flutter_application_1/data/services/api/model/pending_member/pending_member.dart';
import 'package:flutter_application_1/data/utils/result.dart';

abstract class PendingMembersService {
  Future<Result<List<PendingMember>>> getPendingMembersPage({
    required String teamId,
    required int pageSize,
    required int pageIndex,
  });
  Future<Result> addPendingMember({
    required String teamId,
    required PendingMember pendingMember,
  });
  Future<Result> acceptPendingMember({
    required String teamId,
    required String docId,
  });
  Future<Result> declinePendingMember({
    required String teamId,
    required String docId,
  });
}
