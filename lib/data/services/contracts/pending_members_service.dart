import 'package:flutter_application_1/data/services/api/model/pending_member/pending_member.dart';
import 'package:flutter_application_1/data/utils/result.dart';
import 'package:flutter_application_1/ui/activity_logs/models/activity_common.dart';

abstract class PendingMembersService {
  Future<Result<List<PendingMember>>> getPendingMembersPage({
    required String teamId,
    required int pageSize,
    required int pageIndex,
    DateFilterRange? dateFilter,
  });

  Future<Result<List<PendingMember>>> getAllPendingMembers({
    required String teamId,
    DateFilterRange? dateFilter,
  });

  Future<Result<void>> addPendingMember({
    required String teamId,
    required PendingMember pendingMember,
  });

  Future<Result<void>> acceptPendingMember({
    required String teamId,
    required PendingMember member,
  });

  Future<Result<void>> deletePendingMember({
    required String teamId,
    required String docId,
  });
}