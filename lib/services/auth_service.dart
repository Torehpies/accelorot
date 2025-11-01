import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_application_1/utils/google_auth_result.dart';
import 'package:flutter_application_1/utils/login_result.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  bool _isGoogleSignInInitialized = false;

  AuthService() {
    _initializeGoogleSignIn();
  }

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser {
    return _auth.currentUser;
  }

  bool get isUserLoggedIn =>
      currentUser != null && (currentUser?.emailVerified ?? false);

  /// Silent sign in with Google
  Future<GoogleSignInAccount?> attemptSilentSignIn() async {
    await _ensureGoogleSignInInitialized();

    try {
      final result = _googleSignIn.attemptLightweightAuthentication();

      if (result is Future<GoogleSignInAccount?>) {
        return await result;
      } else {
        return result;
      }
    } catch (error) {
      log('Silent sign-in failed: $error');
      return null;
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

  Future<
    ({
      bool isAdmin,
      String? teamId,
      String? pendingTeamId,
      bool isArchived,
      bool hasLeft,
    })
  >
  getUserFlowStatus(String uid) async {
    try {
      final userDoc = await _firestore.collection('users').doc(uid).get();

      if (!userDoc.exists || userDoc.data() == null) {
        return (
          isAdmin: false,
          teamId: null,
          pendingTeamId: null,
          isArchived: false,
          hasLeft: false,
        );
      }

      final data = userDoc.data() as Map<String, dynamic>;
      final String? teamId = data['teamId'] as String?;
      final bool isAdmin = (data['role'] as String? ?? 'Operator') == 'Admin';

      bool isArchived = false;
      bool hasLeft = false;

      if (teamId != null) {
        try {
          final memberDoc = await _firestore
              .collection('teams')
              .doc(teamId)
              .collection('members')
              .doc(uid)
              .get();

          if (memberDoc.exists && memberDoc.data() != null) {
            final memberData = memberDoc.data()!;
            isArchived = memberData['isArchived'] as bool? ?? false;
            hasLeft = memberData['hasLeft'] as bool? ?? false;
          }
        } catch (e) {
          log('Error fetching member status for $uid: $e');
        }
      }

      return (
        isAdmin: isAdmin,
        teamId: teamId,
        pendingTeamId: data['pendingTeamId'] as String?,
        isArchived: isArchived,
        hasLeft: hasLeft,
      );
    } catch (e) {
      log('Fatal error fetching user flow status for $uid: $e');
      return (
        isAdmin: false,
        teamId: null,
        pendingTeamId: null,
        isArchived: false,
        hasLeft: false,
      );
    }
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

  Future<bool> isEmailVerified() async {
    User? user = _auth.currentUser;
    await user?.reload(); // Refresh user data
    return user?.emailVerified ?? false;
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

  Future<void> saveGoogleUserToFirestore({
    required User user,
    required String role,
  }) async {
    final userDoc = _firestore.collection('users').doc(getCurrentUser()?.uid);
    final docSnapshot = await userDoc.get();

    // Parse names from displayName (e.g., "John Doe" -> "John", "Doe")
    final names = user.displayName?.split(' ');
    final firstName = (names?.isNotEmpty ?? false)
        ? names?.first
        : (user.email?.split('@').first);
    final lastName = names!.length > 1 ? names.sublist(1).join(' ') : '';

    if (!docSnapshot.exists) {
      // New user: save full data set
      await userDoc.set({
        'uid': user.uid,
        'email': user.email,
        'firstname': firstName,
        'lastname': lastName,
        'role': role,
        'createdAt': FieldValue.serverTimestamp(),
        'isActive': true,
        'emailVerified': true, // Google accounts are considered verified
      });
    } else {
      // Existing user: ensure verification status is marked true
      await userDoc.update({'isActive': true, 'emailVerified': true});
    }
  }

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

  Future<LoginResult> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      return LoginSuccess(credential.user!.displayName, credential.user!.uid);
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
      return LoginFailure(message);
    } catch (e) {
      return LoginFailure(e.toString());
    }
  }

  Future<GoogleAuthResult> signInWithGoogle() async {
    if (kIsWeb) {
      try {
        final GoogleAuthProvider googleProvider = GoogleAuthProvider();
        final UserCredential credential = await _auth.signInWithPopup(
          googleProvider,
        );

        if (credential.user?.uid != null) {
          return GoogleLoginSuccess(credential.user!.uid);
        }
        return GoogleLoginFailure('Google sign-in but user id is empty.');
      } on FirebaseAuthException catch (e) {
        log('Firebase Web Sign In Error: ${e.code} - ${e.message}');
        return GoogleLoginFailure('Google sign-in failed: $e');
      } catch (error) {
        log('Unexpected Web Sign-In Error: $error');
        return GoogleLoginFailure('An unexpected error occured.');
      }
    } else {
      await _ensureGoogleSignInInitialized();

      try {
        final GoogleSignInAccount googleUser = await _googleSignIn
            .authenticate();

        final GoogleSignInAuthentication googleAuth = googleUser.authentication;
        final credential = GoogleAuthProvider.credential(
          idToken: googleAuth.idToken,
        );
        await _auth.signInWithCredential(credential);

        return GoogleLoginSuccess(getCurrentUser()!.uid);
      } on GoogleSignInException catch (e) {
        log(
          'Google Sign In error: code: ${e.code.name} description:${e.description}',
        );
        return GoogleLoginFailure('Google sign-in error occured.');
      } catch (error) {
        log('Unexpected Google Sign-In error: $error');
        return GoogleLoginFailure('An unexpected error occured.');
      }
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  //verification email status
  Future<void> updateEmailVerificationStatus(
    String uid,
    bool isVerified,
  ) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'emailVerified': isVerified,
      });
    } catch (e) {
      //irror
    }
  }

  Future<void> _ensureGoogleSignInInitialized() async {
    if (!_isGoogleSignInInitialized) {
      await _initializeGoogleSignIn();
    }
  }

  Future<void> _initializeGoogleSignIn() async {
    try {
      await _googleSignIn.initialize();
      _isGoogleSignInInitialized = true;
    } catch (e) {
      log('Failed to initialize Google Sign-In: $e');
    }
  }

	Future<void> refreshUser() async {
		try {
			User? user = _auth.currentUser;
			if (user != null) {
			await user.reload();
			} 
		} catch (e) {
			print('Error refreshing user: $e');
		}
	}
}
