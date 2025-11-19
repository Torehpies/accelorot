import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_1/data/models/user.dart';
import 'package:flutter_application_1/data/repositories/pending_member_repository.dart';
import 'package:flutter_application_1/data/repositories/user_repository.dart';
import 'package:flutter_application_1/data/services/contracts/pagination_result.dart';
import 'package:flutter_application_1/data/services/contracts/pending_member_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
@GenerateMocks([PendingMemberService, UserRepository])
import 'pending_member_repository_test.mocks.dart';

void main() {
  late MockPendingMemberService mockService;
  late MockUserRepository mockUserRepository;
  late PendingMemberRepositoryImpl repository;

  const testTeamId = 'team-177';
  const testRequestorId = 'user-requester-id';
  final testTimestamp = Timestamp.fromDate(DateTime(2025, 6, 1));

  final mockUser = User(
    uid: testRequestorId,
    email: 'test@exmaple.com',
    firstName: 'Test',
    lastName: 'User',
    globalRole: 'User',
    emailVerified: true,
    createdAt: DateTime(2024, 1, 1),
  );

  setUp(() {
    mockService = MockPendingMemberService();
    mockUserRepository = MockUserRepository();
    repository = PendingMemberRepositoryImpl(mockService, mockUserRepository);
    reset(mockService);
    reset(mockUserRepository);
  });

  group('getPendingMembers', () {
    // ARRANGEMENT

    // A. setup muna ng raw data for mock service
    test('should fetch, compose User, and map Timestamp to DateTime', () async {
      final rawPendingMemberData = {
        'requestedAt': testTimestamp,
        'requestorId': testRequestorId,
      };

      final mockPaginationResult = PaginationResult<Map<String, dynamic>>(
        items: [rawPendingMemberData],
        nextCursor: 'next-page-token',
      );

      // B. setup ng irereturn ng mock service
      when(
        mockService.fetchRawPendingMembers(
          teamId: testTeamId,
          limit: 20,
          startCursor: anyNamed('startCursor'),
        ),
      ).thenAnswer((_) async => mockPaginationResult);

      // C. setup ng irereturn ng user repository
      when(
        mockUserRepository.getUser(testRequestorId),
      ).thenAnswer((_) async => mockUser);

      // TEST ACTION
      final result = await repository.getPendingMembers(
        teamId: testTeamId,
        limit: 20,
        startCursor: null,
      );

      // ASSERTION
      expect(result.items, isNotEmpty);
      final member = result.items.first;

      expect(member.user, isNotNull);
      expect(member.user!.uid, testRequestorId);

      expect(member.requestedAt, isA<DateTime>());
      expect(member.requestedAt.year, 2025);
      expect(member.requestedAt, testTimestamp.toDate());

      expect(result.nextCursor, 'next-page-token');

      // VERIFICATION
      verify(mockUserRepository.getUser(testRequestorId)).called(1);
      verify(
        mockService.fetchRawPendingMembers(
          teamId: testTeamId,
          limit: 20,
          startCursor: null,
        ),
      ).called(1);
    });

    test('should return null user if userRepository throws error', () async {
      // ARRANGEMENT
      final rawData = {
        'requestedAt': testTimestamp,
        'requestorId': testRequestorId,
        'teamId': testTeamId,
      };

      when(
        mockService.fetchRawPendingMembers(
          teamId: anyNamed('teamId'),
          limit: anyNamed('limit'),
          startCursor: anyNamed('startCursor'),
        ),
      ).thenAnswer(
        (_) async => PaginationResult(items: [rawData], nextCursor: null),
      );

      // Tell user repository to throw an error
      when(
        mockUserRepository.getUser(testRequestorId),
      ).thenThrow(Exception('User not found'));

      // ACTION
      final result = await repository.getPendingMembers(
        teamId: testTeamId,
        limit: 20,
        startCursor: null,
      );

      // ASSERTION
      final member = result.items.first;

      expect(member.user, isNull);

      verify(mockUserRepository.getUser(testRequestorId)).called(1);
    });
  });
}
