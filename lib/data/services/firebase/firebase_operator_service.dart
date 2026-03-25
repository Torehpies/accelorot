import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_1/data/models/app_user.dart';
import 'package:flutter_application_1/data/utils/result.dart' as app_result;
import '../../models/operator_model.dart';
import '../../services/contracts/operator_service.dart';

class FirebaseOperatorService implements OperatorService {
  final FirebaseFirestore _firestore;

  FirebaseOperatorService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<List<OperatorModel>> fetchTeamOperators(String teamId) async {
    final membersSnapshot = await _firestore
        .collection('teams')
        .doc(teamId)
        .collection('members')
        .orderBy('addedAt', descending: true)
        .get();

    final List<OperatorModel> operators = [];
    final memberDocs = membersSnapshot.docs;
    if (memberDocs.isEmpty) return operators;

    // We can fetch up to 10 users at once using whereIn on the document ID.
    final chunks = <List<QueryDocumentSnapshot>>[];
    for (var i = 0; i < memberDocs.length; i += 10) {
      final sliceEnd = (i + 10 < memberDocs.length) ? i + 10 : memberDocs.length;
      chunks.add(memberDocs.sublist(i, sliceEnd));
    }

    // Execute queries in parallel
    final chunkFutures = chunks.map((chunk) async {
      final userIds = chunk.map((c) => c.id).toList();
      final usersSnapshot = await _firestore
          .collection('users')
          .where(FieldPath.documentId, whereIn: userIds)
          .get();

      // Map document IDs to user data for quick lookup
      final userMap = {for (var doc in usersSnapshot.docs) doc.id: doc.data()};
      
      final chunkOperators = <OperatorModel>[];
      for (var memberDoc in chunk) {
        final userId = memberDoc.id;
        final u = userMap[userId];
        if (u == null) continue; // User not found in 'users' collection

        final data = memberDoc.data() as Map<String, dynamic>;
        final firstName = (u['firstname'] ?? '') as String;
        final lastName = (u['lastname'] ?? '') as String;
        final name = ('$firstName $lastName').trim();

        chunkOperators.add(
          OperatorModel(
            id: userId,
            uid: userId,
            name: name.isNotEmpty ? name : (data['name'] ?? 'Unknown').toString(),
            email: (data['email'] ?? u['email'] ?? '').toString(),
            role: (data['role'] ?? u['teamRole'] ?? 'Operator').toString(),
            isArchived: (data['isArchived'] ?? false) as bool,
            hasLeft: (data['hasLeft'] ?? false) as bool,
            leftAt: (data['leftAt'] as Timestamp?)?.toDate(),
            archivedAt: (data['archivedAt'] as Timestamp?)?.toDate(),
            addedAt: (data['addedAt'] as Timestamp?)?.toDate(),
          ),
        );
      }
      return chunkOperators;
    });

    final results = await Future.wait(chunkFutures);
    for (var chunkResult in results) {
      operators.addAll(chunkResult);
    }

    // In case the whereIn chunking messed up the ordering, re-sort explicitly
    operators.sort((a, b) {
      final aDate = a.addedAt ?? DateTime(1970);
      final bDate = b.addedAt ?? DateTime(1970);
      return bDate.compareTo(aDate); // descending
    });

    return operators;
  }

  @override
  Future<app_result.Result<AppUser>> addUser({
    required String email,
    required String firstname,
    required String lastname,
    String? globalRole,
    String? teamRole,
    String? status,
    String? requestTeamId,
  }) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        return app_result.Result.error(Exception('Not signed in'));
      }

      final HttpsCallable callable = FirebaseFunctions.instance.httpsCallable(
        'createUserWithProfile',
      );
      final response = await callable.call({
        'email': email,
        'firstname': firstname,
        'lastname': lastname,
        'globalRole': globalRole,
        'teamRole': teamRole,
        'status': status,
        'requestTeamId': requestTeamId,
      });
      // Deserialize response into AppUser
      try {
        final data = response.data as Map<String, dynamic>;
        final appUser = AppUser.fromJson(data);
        return app_result.Result.ok(appUser);
      } catch (e) {
        return app_result.Result.error(Exception('Error: ${e.toString()}'));
      }
    } catch (e) {
      return app_result.Result.error(Exception('Error: ${e.toString()}'));
    }
  }
}
