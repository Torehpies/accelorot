import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_1/data/models/pending_member.dart';
import 'package:flutter_application_1/data/models/pending_member_user.dart';
import 'package:flutter_application_1/data/repositories/user_repository.dart';
import 'package:flutter_application_1/data/services/contracts/data_layer_error.dart';
import 'package:flutter_application_1/data/services/contracts/pagination_result.dart';
import 'package:flutter_application_1/data/services/contracts/pending_member_service.dart';
import 'package:flutter_application_1/data/services/contracts/result.dart';

abstract class PendingMemberRepository {
  Future<Result<PendingMember, DataLayerError>> getPendingMember(String id);
  Future<Result<PaginationResult<PendingMember>, DataLayerError>>
  getPendingMembers({
    required String teamId,
    required int limit,
    String? startCursor,
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

class PendingMemberRepositoryImpl implements PendingMemberRepository {
  final PendingMemberService _pendingMemberService;
  final UserRepository _userRepository;
  PendingMemberRepositoryImpl(this._pendingMemberService, this._userRepository);

  @override
  Future<Result<PendingMember, DataLayerError>> getPendingMember(String id) {
    // TODO: implement getPendingMember
    throw UnimplementedError();
  }

  @override
  Future<Result<PaginationResult<PendingMember>, DataLayerError>>
  getPendingMembers({
    required String teamId,
    required int limit,
    String? startCursor,
  }) async {
    try {
      final rawResult = await _pendingMemberService.fetchRawPendingMembers(
        teamId: teamId,
        limit: limit,
        startCursor: startCursor,
      );

      final cleanItems = await Future.wait(
        rawResult.items.map((rawMap) async {
          final requestedAtTimestamp = rawMap['requestedAt'] as Timestamp;
          final requestedAtDate = requestedAtTimestamp.toDate();

          final existingUserId = rawMap['requestorId'] as String?;
          PendingMemberUser? existingPendingMemberUser;

          if (existingUserId != null) {
            try {
              final existingUser = await _userRepository.getUser(
                existingUserId,
              );
              existingPendingMemberUser = PendingMemberUser(
                uid: existingUser.uid,
                firstName: existingUser.firstName,
                lastName: existingUser.lastName,
                email: existingUser.email,
              );
            } catch (_) {
              existingPendingMemberUser = null;
            }
          }

          return PendingMember(
            user: existingPendingMemberUser,
            requestedAt: requestedAtDate,
          );
        }),
      );

      return Result.success(
        PaginationResult(items: cleanItems, nextCursor: rawResult.nextCursor),
      );
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        return const Result.failure(PermissionError());
      }
      return const Result.failure(NetworkError());
    } on MappingError catch (e) {
      return Result.failure(e);
    } catch (e) {
      return const Result.failure(NetworkError());
    }
  }

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
        memberId: memberId,
        email: member.user!.email,
        firstName: member.user!.firstName,
        lastName: member.user!.lastName,
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
    required PendingMember member,
  }) async {
    try {
      final memberId = member.user?.uid;
      if (memberId == null) {
        return const Result.failure(MappingError());
      }

      await _pendingMemberService.deletePendingMember(
        teamId: teamId,
        memberId: memberId,
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
}
