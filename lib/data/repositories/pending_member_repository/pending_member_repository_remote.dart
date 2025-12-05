import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_1/data/models/pending_member.dart';
import 'package:flutter_application_1/data/repositories/pending_member_repository/pending_member_repository.dart';
import 'package:flutter_application_1/data/services/contracts/data_layer_error.dart';
import 'package:flutter_application_1/data/services/contracts/pending_member_service.dart';
import 'package:flutter_application_1/data/services/contracts/result.dart';

class PendingMemberRepositoryRemote extends PendingMemberRepository {
  final PendingMemberService _pendingMemberService;

  List<PendingMember>? _cache;

  PendingMemberRepositoryRemote(this._pendingMemberService);

  @override
  Future<Result<void, DataLayerError>> acceptInvitation({
    required String teamId,
    required PendingMember member,
  }) {
    // TODO: implement acceptInvitation
    throw UnimplementedError();
  }

  @override
  Future<Result<void, DataLayerError>> declineInvitation({
    required String teamId,
    required PendingMember member,
  }) {
    // TODO: implement declineInvitation
    throw UnimplementedError();
  }

  @override
  Future<Result<PendingMember, DataLayerError>> getPendingMember(String id) {
    // TODO: implement getPendingMember
    throw UnimplementedError();
  }

  @override
  Future<Result<List<PendingMember>, DataLayerError>> getPendingMembers({
    required String teamId,
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh && _cache != null) {
      return Result.success(_cache!);
    }
    final result = await _pendingMemberService.fetchPendingMembers(teamId);
    result.when(success: (members) => _cache = members, failure: (_) => _cache);
    return result;
  }
}
