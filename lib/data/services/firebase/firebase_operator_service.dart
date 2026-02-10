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
