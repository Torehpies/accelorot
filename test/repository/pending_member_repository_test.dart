// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter_application_1/data/models/app_user.dart';
// import 'package:flutter_application_1/data/repositories/app_user_repository/app_user_repository.dart';
// import 'package:flutter_application_1/data/services/contracts/app_user_service.dart';
// import 'package:flutter_application_1/data/services/contracts/data_layer_error.dart';
// import 'package:flutter_application_1/data/services/contracts/pagination_result.dart';
// import 'package:flutter_application_1/data/services/contracts/pending_member_service.dart';
// import 'package:flutter_test/flutter_test.dart';
// import 'package:mockito/annotations.dart';
// import 'package:mockito/mockito.dart';
//
// @GenerateMocks([PendingMemberService, AppUserRepository, AppUserService])
// import 'pending_member_repository_test.mocks.dart';
//
// void main() {
//   late MockPendingMemberService mockService;
//   late MockAppUserRepository mockAppUserRepository;
//   late PendingMemberRepositoryImpl repository;
//   late MockAppUserService mockAppUserService;
//
//   const testTeamId = 'team-177';
//   const testRequestorId = 'user-requester-id';
//   final testTimestamp = Timestamp.fromDate(DateTime(2025, 6, 1));
//
//   final mockAppUser = AppUser(
//     uid: testRequestorId,
//     email: 'test@exmaple.com',
//     firstname: 'Test',
//     lastname: 'User',
//     globalRole: 'User',
//     createdAt: DateTime(2024, 1, 1),
//     teamRole: 'Operator',
//     teamId: 'example-team',
//   );
//
//   setUp(() {
//     mockService = MockPendingMemberService();
//     mockAppUserRepository = MockAppUserRepository();
//     mockAppUserService = MockAppUserService();
//     repository = PendingMemberRepositoryImpl(
//       mockService,
//       mockAppUserRepository,
//       mockAppUserService,
//     );
//     reset(mockService);
//     reset(mockAppUserRepository);
//   });
//
//   group('getPendingMembers', () {
//     // ARRANGEMENT
//
//     // test 1: success (composition and mapping check)
//     test(
//       'should return success, compose User, and map Timestamp to DateTime',
//       () async {
//         // arrange
//         final rawPendingMemberData = {
//           'requestedAt': testTimestamp,
//           'requestorId': testRequestorId,
//         };
//
//         final mockPaginationResult = PaginationResult<Map<String, dynamic>>(
//           items: [rawPendingMemberData],
//           nextCursor: 'next-page-token',
//         );
//
//         // stub 1: service returns raw data
//         when(
//           mockService.fetchRawPendingMembers(
//             teamId: testTeamId,
//             limit: 20,
//             startCursor: anyNamed('startCursor'),
//           ),
//         ).thenAnswer((_) async => mockPaginationResult);
//
//         // stub 2: repository returns clean user model
//         //when(
//         //  mockAppUserRepository.getUser(testRequestorId),
//         //).thenAnswer((_) async => mockAppUser);
//
//         // action
//         final result = await repository.getPendingMembers(
//           teamId: testTeamId,
//           limit: 20,
//           startCursor: null,
//         );
//
//         // assertion
//
//         // check success rate
//         expect(result.isSuccess, isNotNull);
//         expect(result.isFailure, isNull);
//
//         // check actaul paginationresult
//         final paginationResult = result.value!;
//
//         // check composition and mapping
//         expect(paginationResult.items, hasLength(1));
//         final member = paginationResult.items.first;
//
//         expect(member.user, isNotNull);
//         expect(member.user!.uid, testRequestorId);
//         expect(member.requestedAt, testTimestamp.toDate());
//         expect(paginationResult.nextCursor, 'next-page-token');
//
//         // verification
//         verify(mockAppUserRepository.getUser(testRequestorId)).called(1);
//       },
//     );
//
//     // test 2: network/unknown error
//     test(
//       'should return networkerror if the service fails with a general exception',
//       () async {
//         // arrange
//         when(
//           mockService.fetchRawPendingMembers(
//             teamId: anyNamed('teamId'),
//             limit: anyNamed('limit'),
//             startCursor: anyNamed('startCursor'),
//           ),
//         ).thenThrow(Exception('Simulated network timeout'));
//
//         // action
//         final result = await repository.getPendingMembers(
//           teamId: testTeamId,
//           limit: 20,
//           startCursor: null,
//         );
//
//         // assertion
//         // 1. check for failure state
//         expect(result.value, isNull);
//
//         // 2. check for the specific datalayererror type (networkerror)
//         expect(result.error, isA<DataLayerError>());
//         expect(result.error, isA<NetworkError>());
//       },
//     );
//
//     // test 3: failure - permission denied
//     test(
//       'should return PermissionError if the service throws a permission-denied FirebaseException',
//       () async {
//         // arrange
//         when(
//           mockService.fetchRawPendingMembers(
//             teamId: anyNamed('teamId'),
//             limit: anyNamed('limit'),
//             startCursor: anyNamed('startCursor'),
//           ),
//         ).thenThrow(
//           FirebaseException(plugin: 'firestore', code: 'permission-denied'),
//         );
//
//         // action
//         final result = await repository.getPendingMembers(
//           teamId: testTeamId,
//           limit: 20,
//           startCursor: null,
//         );
//
//         // assertion
//         expect(result.error, isA<DataLayerError>());
//         expect(result.error, isA<PermissionError>());
//       },
//     );
//   });
// }
