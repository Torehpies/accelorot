import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_1/data/models/user.dart';
import 'package:flutter_application_1/data/repositories/pending_member_repository.dart';
import 'package:flutter_application_1/data/repositories/user_repository.dart';
import 'package:flutter_application_1/data/services/contracts/data_layer_error.dart';
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
    teamRole: 'Operator',
    teamId: 'example-team',
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

    // test 1: success (composition and mapping check)
    test(
      'should return success, compose User, and map Timestamp to DateTime',
      () async {
        // arrange
        final rawPendingMemberData = {
          'requestedAt': testTimestamp,
          'requestorId': testRequestorId,
        };

        final mockPaginationResult = PaginationResult<Map<String, dynamic>>(
          items: [rawPendingMemberData],
          nextCursor: 'next-page-token',
        );

        // stub 1: service returns raw data
        when(
          mockService.fetchRawPendingMembers(
            teamId: testTeamId,
            limit: 20,
            startCursor: anyNamed('startCursor'),
          ),
        ).thenAnswer((_) async => mockPaginationResult);

        // stub 2: repository returns clean user model
        when(
          mockUserRepository.getUser(testRequestorId),
        ).thenAnswer((_) async => mockUser);

        // action
        final result = await repository.getPendingMembers(
          teamId: testTeamId,
          limit: 20,
          startCursor: null,
        );

        // assertion

        // check success rate
        expect(result.value, isNotNull);
        expect(result.error, isNull);

        // check actaul paginationresult
        final paginationResult = result.value!;

        // check composition and mapping
        expect(paginationResult.items, hasLength(1));
        final member = paginationResult.items.first;

        expect(member.user, isNotNull);
        expect(member.user!.uid, testRequestorId);
        expect(member.requestedAt, testTimestamp.toDate());
        expect(paginationResult.nextCursor, 'next-page-token');

        // verification
        verify(mockUserRepository.getUser(testRequestorId)).called(1);
      },
    );

    // test 2: network/unknown error
    test(
      'should return networkerror if the service fails with a general exception',
      () async {
        // arrange
        when(
          mockService.fetchRawPendingMembers(
            teamId: anyNamed('teamId'),
            limit: anyNamed('limit'),
            startCursor: anyNamed('startCursor'),
          ),
        ).thenThrow(Exception('Simulated network timeout'));

        // action
        final result = await repository.getPendingMembers(
          teamId: testTeamId,
          limit: 20,
          startCursor: null,
        );

        // assertion
        // 1. check for failure state
        expect(result.value, isNull);

        // 2. check for the specific datalayererror type (networkerror)
        expect(result.error, isA<DataLayerError>());
        expect(result.error, isA<NetworkError>());
      },
    );

    // test 3: failure - permission denied
    test(
      'should return PermissionError if the service throws a permission-denied FirebaseException',
      () async {
        // arrange
        when(
          mockService.fetchRawPendingMembers(
            teamId: anyNamed('teamId'),
            limit: anyNamed('limit'),
            startCursor: anyNamed('startCursor'),
          ),
        ).thenThrow(
          FirebaseException(plugin: 'firestore', code: 'permission-denied'),
        );

        // action
        final result = await repository.getPendingMembers(
          teamId: testTeamId,
          limit: 20,
          startCursor: null,
        );

        // assertion
        expect(result.error, isA<DataLayerError>());
        expect(result.error, isA<PermissionError>());
      },
    );
  });
}
