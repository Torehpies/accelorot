import 'package:flutter_application_1/data/models/pending_member.dart';
import 'package:flutter_application_1/data/services/contracts/data_layer_error.dart';
import 'package:flutter_application_1/data/services/contracts/result.dart';

abstract class PendingMemberRepository {
  Future<Result<PendingMember, DataLayerError>> getPendingMember(String id);
  //Future<Result<PaginationResult<PendingMember>, DataLayerError>>
  //getPendingMembers({
  //  required String teamId,
  //  required int limit,
  //  String? startCursor,
  //});
  Future<Result<List<PendingMember>, DataLayerError>> getPendingMembers({
    required String teamId,
    bool forceRefresh = false,
  });
  Future<Result<void, DataLayerError>> acceptInvitation({
    required String teamId,
    required PendingMember member,
  });
  Future<Result<void, DataLayerError>> declineInvitation({
    required String teamId,
    required PendingMember member,
  });
}
