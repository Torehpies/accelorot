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
    for (var doc in membersSnapshot.docs) {
      final data = doc.data();
      final userId = doc.id;

      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (!userDoc.exists) continue;

      final u = userDoc.data()!;
      final firstName = (u['firstname'] ?? '') as String;
      final lastName = (u['lastname'] ?? '') as String;
      final name = ('$firstName $lastName').trim();

      operators.add(
        OperatorModel(
          id: userId,
          uid: userId,
          name: name.isNotEmpty ? name : (data['name'] ?? 'Unknown') as String,
          email: (data['email'] ?? u['email'] ?? '') as String,
          role: (data['role'] ?? u['teamRole'] ?? 'Operator') as String,
          isArchived: (data['isArchived'] ?? false) as bool,
          hasLeft: (data['hasLeft'] ?? false) as bool,
          leftAt: (data['leftAt'] as Timestamp?)?.toDate(),
          archivedAt: (data['archivedAt'] as Timestamp?)?.toDate(),
          addedAt: (data['addedAt'] as Timestamp?)?.toDate(),
        ),
      );
    }
    return operators;
  }

  @override
  Future<List<Map<String, dynamic>>> fetchPendingMembers(String teamId) async {
    final snapshot = await _firestore
        .collection('teams')
        .doc(teamId)
        .collection('pending_members')
        .orderBy('requestedAt', descending: true)
        .get();

    final List<Map<String, dynamic>> members = [];
    for (var doc in snapshot.docs) {
      final data = doc.data();
      final requestorId = data['requestorId'] as String?;
      if (requestorId == null) continue;

      final userDoc = await _firestore
          .collection('users')
          .doc(requestorId)
          .get();
      if (!userDoc.exists) continue;

      final u = userDoc.data()!;
      final firstName = (u['firstname'] ?? '') as String;
      final lastName = (u['lastname'] ?? '') as String;
      final name = ('$firstName $lastName').trim();

      members.add({
        'id': doc.id,
        'requestorId': requestorId,
        'name': name.isNotEmpty ? name : 'Unknown',
        'email': data['requestorEmail'] ?? u['email'] ?? '',
        'requestedAt': (data['requestedAt'] as Timestamp?)?.toDate(),
      });
    }
    return members;
  }

  @override
  Future<void> archiveOperator({
    required String teamId,
    required String operatorUid,
  }) async {
    await _firestore
        .collection('teams')
        .doc(teamId)
        .collection('members')
        .doc(operatorUid)
        .update({
          'isArchived': true,
          'archivedAt': FieldValue.serverTimestamp(),
        });
  }

  @override
  Future<void> restoreOperator({
    required String teamId,
    required String operatorUid,
  }) async {
    await _firestore
        .collection('teams')
        .doc(teamId)
        .collection('members')
        .doc(operatorUid)
        .update({'isArchived': false, 'archivedAt': FieldValue.delete()});
  }

  @override
  Future<void> removeOperator({
    required String teamId,
    required String operatorUid,
  }) async {
    final batch = _firestore.batch();

    final memberRef = _firestore
        .collection('teams')
        .doc(teamId)
        .collection('members')
        .doc(operatorUid);

    batch.update(memberRef, {
      'hasLeft': true,
      'leftAt': FieldValue.serverTimestamp(),
      'isArchived': false,
      'archivedAt': FieldValue.delete(),
    });

    final userRef = _firestore.collection('users').doc(operatorUid);
    batch.update(userRef, {'teamId': FieldValue.delete()});

    await batch.commit();
  }

  @override
  Future<void> acceptInvitation({
    required String teamId,
    required String requestorId,
    required String name,
    required String email,
    required String pendingDocId,
  }) async {
    final batch = _firestore.batch();

    final memberRef = _firestore
        .collection('teams')
        .doc(teamId)
        .collection('members')
        .doc(requestorId);

    batch.set(memberRef, {
      'userId': requestorId,
      'name': name,
      'email': email,
      'role': 'Operator',
      'addedAt': FieldValue.serverTimestamp(),
      'isArchived': false,
    });

    final userRef = _firestore.collection('users').doc(requestorId);
    batch.update(userRef, {
      'teamId': teamId,
      'pendingTeamId': FieldValue.delete(),
    });

    final pendingRef = _firestore
        .collection('teams')
        .doc(teamId)
        .collection('pending_members')
        .doc(pendingDocId);
    batch.delete(pendingRef);

    await batch.commit();
  }

  @override
  Future<void> declineInvitation({
    required String teamId,
    required String requestorId,
    required String pendingDocId,
  }) async {
    final batch = _firestore.batch();

    final userRef = _firestore.collection('users').doc(requestorId);
    batch.update(userRef, {'pendingTeamId': FieldValue.delete()});

    final pendingRef = _firestore
        .collection('teams')
        .doc(teamId)
        .collection('pending_members')
        .doc(pendingDocId);
    batch.delete(pendingRef);

    await batch.commit();
  }

  @override
  Future<app_result.Result<AppUser>> addOperator({
    required String email,
    required String password,
    required String firstname,
    required String lastname,
    String? globalRole,
    String? teamRole,
    String? status,
    String? teamId,
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
        'password': password,
        'firstname': firstname,
        'lastname': lastname,
        'globalRole': globalRole,
        'teamRole': teamRole,
        'status': status,
        'teamId': teamId,
      });
      // Deserialize response into AppUser
      final data = response.data as Map<String, dynamic>;
      final appUser = AppUser.fromJson(
        data,
      ); // Uses the provided `AppUser.fromJson`
      return app_result.Result.ok(appUser);
    } catch (e) {
      return app_result.Result.error(Exception('Error: ${e.toString()}'));
    }
  }
}
