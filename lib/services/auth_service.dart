import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Map<String, dynamic>> sendEmailVerify() async {
    try {
      User? user = _auth.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
        return {'success': true, 'message': 'Verification email sent'};
      } else if (user != null && user.emailVerified) {
        return {'success': false, 'message': 'Email is already verified'};
      } else {
        return {'success': false, 'message': 'No user is currently signed in'};
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'An error occurred: ${e.toString()}',
      };
    }
  }

  Future<bool> isEmailVerified() async {
    User? user = _auth.currentUser;
    await user?.reload(); // Refresh user data
    return user?.emailVerified ?? false;
  }

  Future<Map<String, dynamic>> signInUser({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = result.user;
      if (user != null) {
        if (!user.emailVerified) {
          await _auth.signOut();
          return {
            'success': false,
            'message': 'Email not verified. Please verify your email.',
            'needsVerification': true,
            'uid': user.uid,
          };
        }
        // Get user data from Firestore
        DocumentSnapshot userDoc = await _firestore
            .collection('users')
            .doc(user.uid)
            .get();

        if (userDoc.exists) {
          return {
            'success': true,
            'message': 'Sign in successful',
            'uid': user.uid,
            'userData': userDoc.data(),
          };
        } else {
          return {'success': false, 'message': 'User data not found'};
        }
      } else {
        return {'success': false, 'message': 'Failed to sign in'};
      }
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'user-not-found':
          message = 'No user found for that email.';
          break;
        case 'wrong-password':
          message = 'Wrong password provided.';
          break;
        case 'invalid-email':
          message = 'The email address is not valid.';
          break;
        case 'user-disabled':
          message = 'This user account has been disabled.';
          break;
        case 'too-many-requests':
          message = 'Too many failed login attempts. Please try again later.';
          break;
        default:
          message = e.message ?? 'An error occurred during sign in.';
      }
      return {'success': false, 'message': message};
    } catch (e) {
      return {
        'success': false,
        'message': 'An unexpected error occurred: ${e.toString()}',
      };
    }
  }

  // Register user with email and password
  Future<Map<String, dynamic>> registerUser({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String role,
  }) async {
    try {
      // Create user with Firebase Auth
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = result.user;
      if (user != null) {
        await user.sendEmailVerification();
        // Save additional user data to Firestore
        await _firestore.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'email': email,
          // Store names separately (no concatenation)
          // Note: keys are intentionally cased to match requested schema
          'firstname': firstName,
          'lastname': lastName,
          'role': role,
          'createdAt': FieldValue.serverTimestamp(),
          'isActive': true,
          'emailVerified': false,
        });

        return {
          'success': true,
          'message': 'User registered successfully',
          'uid': user.uid,
          'needsVerification': true,
        };
      } else {
        return {'success': false, 'message': 'Failed to create user account'};
      }
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'weak-password':
          message = 'The password provided is too weak.';
          break;
        case 'email-already-in-use':
          message = 'The account already exists for that email.';
          break;
        case 'invalid-email':
          message = 'The email address is not valid.';
          break;
        default:
          message = e.message ?? 'An error occurred during registration.';
      }
      return {'success': false, 'message': message};
    } catch (e) {
      return {
        'success': false,
        'message': 'An unexpected error occurred: ${e.toString()}',
      };
    }
  }
  //verification email status
  Future<void> updateEmailVerificationStatus(String uid, bool isVerified) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'emailVerified': isVerified,
      });
    } catch (e) {
      //irror
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Get current user
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  // Mark that referral overlay was shown for the given user (stored in users doc)


  // Check whether referral overlay was already shown


  // Get user data from Firestore
  Future<DocumentSnapshot> getUserData(String uid) async {
    return await _firestore.collection('users').doc(uid).get();
  }

  // Get team status for a user: returns map with teamId and pendingTeamId (both may be null)
  Future<Map<String, dynamic>> getUserTeamStatus(String uid) async {
    try {
      final doc = await getUserData(uid);
      if (!doc.exists) return {'teamId': null, 'pendingTeamId': null};
      final data = doc.data() as Map<String, dynamic>?;
      return {
        'teamId': data?['teamId'],
        'pendingTeamId': data?['pendingTeamId'],
      };
    } catch (e) {
      return {'teamId': null, 'pendingTeamId': null};
    }
  }

  // Set a pendingTeamId on the user document (when they enter/scan a referral code)
  Future<void> setPendingTeamId(String uid, String teamCode) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'pendingTeamId': teamCode,
      });
    } catch (e) {
      rethrow;
    }
  }

  // Clear pendingTeamId (e.g., if cancelled)
  Future<void> clearPendingTeamId(String uid) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'pendingTeamId': FieldValue.delete(),
      });
    } catch (e) {
      // ignore
    }
  }
}
