import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_1/data/models/pending_member.dart';
import 'package:flutter_application_1/data/repositories/pending_member_repository/pending_member_repository.dart';
import 'package:flutter_application_1/data/services/contracts/app_user_service.dart';
import 'package:flutter_application_1/data/services/contracts/data_layer_error.dart';
import 'package:flutter_application_1/data/services/contracts/pending_member_service.dart';
import 'package:flutter_application_1/data/services/contracts/result.dart';
import 'package:flutter_application_1/utils/user_status.dart';

class PendingMemberRepositoryRemote extends PendingMemberRepository {
  final PendingMemberService _pendingMemberService;
  final AppUserService _userService;

  List<PendingMember>? _cache;

  PendingMemberRepositoryRemote(this._pendingMemberService, this._userService);

  @override
  Future<Result<void, DataLayerError>> acceptInvitation({
    required String teamId,
    required PendingMember member,
  }) async {
    try {
      final memberId = member.user?.uid;
      if (memberId == null) {
        return const Result.failure(MappingError());
      }

      await _pendingMemberService.processAcceptanceTransaction(
        teamId: teamId,
        member: member,
      );

      return const Result.success(null);
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        return const Result.failure(PermissionError());
      }
      return const Result.failure(NetworkError());
    } catch (e) {
      return const Result.failure(NetworkError());
    }
  }

  @override
  Future<Result<void, DataLayerError>> declineInvitation({
    required String teamId,
    required String id,
  }) async {
    try {
      await _pendingMemberService.deletePendingMember(
        teamId: teamId,
        memberId: id,
      );

      final data = {
        "status": UserStatus.teamSelect.value,
        "requestTeamId": FieldValue.delete,
      };
      await _userService.updateUserField(id, data);

      return const Result.success(null);
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        return const Result.failure(DataLayerError.permissionError());
      }
      return const Result.failure(NetworkError());
    } catch (e) {
      return const Result.failure(NetworkError());
    }
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
    result.when(
      success: (members) {
        return _cache = members;
      },
      failure: (error) {
        return _cache;
      },
    );
    return result;
  }

  //  @override
  //  Future<Result<PaginationResult<PendingMember>, DataLayerError>>
  //  getPendingMembers({
  //    required String teamId,
  //    required int limit,
  //    String? startCursor,
  //  }) async {
  //    try {
  //      final rawResult = await _pendingMemberService.fetchRawPendingMembers(
  //        teamId: teamId,
  //        limit: limit,
  //        startCursor: startCursor,
  //      );
  //
  //      final cleanItems = (await Future.wait(
  //        rawResult.items.map((rawMap) async {
  //          final requestedAtTimestamp = rawMap['requestedAt'] as Timestamp;
  //          final requestedAtDate = requestedAtTimestamp.toDate();
  //
  //          final existingUserId = rawMap['requestorId'] as String?;
  //          PendingMemberUser? existingPendingMemberUser;
  //
  //          if (existingUserId != null) {
  //            try {
  //              final rawData = await _userService.fetchRawUserData(
  //                existingUserId,
  //              );
  //
  //              if (rawData == null) {
  //                return null;
  //              }
  //
  //              final user = _userRepository.mapRawDataToDomain(rawData);
  //
  //              existingPendingMemberUser = PendingMemberUser(
  //                uid: user.uid,
  //                firstName: user.firstname,
  //                lastName: user.lastname,
  //                email: user.email,
  //              );
  //            } catch (_) {
  //              existingPendingMemberUser = null;
  //            }
  //          }
  //
  //          return PendingMember(
  //            user: existingPendingMemberUser,
  //            requestedAt: requestedAtDate,
  //          );
  //        }),
  //      )).whereType<PendingMember>().toList();
  //
  //      return Result.success(
  //        PaginationResult(items: cleanItems, nextCursor: rawResult.nextCursor),
  //      );
  //    } on FirebaseException catch (e) {
  //      if (e.code == 'permission-denied') {
  //        return const Result.failure(PermissionError());
  //      }
  //      return const Result.failure(NetworkError());
  //    } on MappingError catch (e) {
  //      return Result.failure(e);
  //    } catch (e) {
  //      return const Result.failure(NetworkError());
  //    }
  //  }
}
