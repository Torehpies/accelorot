import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_1/data/models/pending_member.dart';
import 'package:flutter_application_1/data/models/user.dart';
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
          User? existingUser;
          if (existingUserId != null) {
            try {
              existingUser = await _userRepository.getUser(existingUserId);
            } catch (_) {
              existingUser = null;
            }
          }

          return PendingMember(
            user: existingUser,
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
}
