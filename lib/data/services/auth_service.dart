import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Register user with email and password
  Future<Map<String, dynamic>> registerUser({
    required String email,
    required String password,
    required String fullName,
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
        // Save additional user data to Firestore
        await _firestore.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'email': email,
          'fullName': fullName,
          'role': role,
          'createdAt': FieldValue.serverTimestamp(),
          'isActive': true,
        });

        return {
          'success': true,
          'message': 'User registered successfully',
          'uid': user.uid,
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

  // Get current user
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  // Get user data from Firestore
  Future<DocumentSnapshot> getUserData(String uid) async {
    return await _firestore.collection('users').doc(uid).get();
  }

  /*
	Google Sign In
	*/
  final _googleSignIn = GoogleSignIn.instance;
  bool _isGoogleSignInInitialized = false;

  AuthService() {
    _initializeGoogleSignIn();
  }

  Future<void> _initializeGoogleSignIn() async {
    try {
      await _googleSignIn.initialize();
      _isGoogleSignInInitialized = true;
    } catch (e) {
      // print('Failed to initialize Google Sign-In: $e');
    }
  }

  /// Always check Google sign in initialization before use
  Future<void> _ensureGoogleSignInInitialized() async {
    if (!_isGoogleSignInInitialized) {
      await _initializeGoogleSignIn();
    }
  }

  // Future<GoogleSignInAccount> signInWithGoogle() async {
  //   await _ensureGoogleSignInInitialized();

  //   try {
  //     // authenticate() throws exceptions instead of returning null
  //     final GoogleSignInAccount account = await _googleSignIn.authenticate(
  //       scopeHint: ['email'], // Specify required scopes
  //     );
  //     return account;
  //   } on GoogleSignInException catch (e) {
  //     print(
  //       'Google Sign In error: code: ${e.code.name} description:${e.description} details:${e.details}, error: e',
  //     );
  //     rethrow;
  //   } catch (error) {
  //     print('Unexpected Google Sign-In error: $error');
  //     rethrow;
  //   }
  // }

  Future<GoogleSignInAccount?> attemptSilentSignIn() async {
    await _ensureGoogleSignInInitialized();

    try {
      // attemptLightweightAuthentication can return Future or immediate result
      final result = _googleSignIn.attemptLightweightAuthentication();

      // Handle both sync and async returns
      if (result is Future<GoogleSignInAccount?>) {
        return await result;
      } else {
        return result as GoogleSignInAccount?;
      }
    } catch (error) {
      //print('Silent sign-in failed: $error');
      return null;
    }
  }

  GoogleSignInAuthentication getAuthTokens(GoogleSignInAccount account) {
    // authentication is now synchronous
    return account.authentication;
  }

  Future<String?> getAccessTokenForScopes(List<String> scopes) async {
    await _ensureGoogleSignInInitialized();

    try {
      final authClient = _googleSignIn.authorizationClient;

      // Try to get existing authorization
      var authorization = await authClient.authorizationForScopes(scopes);

      // Request new authorization from user
      authorization ??= await authClient.authorizeScopes(scopes);

      return authorization.accessToken;
    } catch (error) {
      //print('Failed to get access token for scopes: $error');
      return null;
    }
  }

  // Manage user state manually
  GoogleSignInAccount? _currentUser;
  GoogleSignInAccount? get currentUser => _currentUser;

  bool get isSignedIn => _currentUser != null;

  //  Future<void> signIn() async {
  //    try {
  //      _currentUser = await signInWithGoogle();
  //      // Manually notify listeners or update state
  //      _notifyUserChanged();
  //    } catch (error) {
  //      _currentUser = null;
  //      rethrow;
  //    }
  //  }

  Future<void> signOut() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
    _currentUser = null;
    _notifyUserChanged();
  }

  void _notifyUserChanged() {
    notifyListeners(); // from ChangeNotifier
  }

  Future<UserCredential> signInWithGoogleFirebase() async {
    await _ensureGoogleSignInInitialized();

    // Authenticate with Google
    final GoogleSignInAccount googleUser = await _googleSignIn.authenticate(
      scopeHint: ['email'],
    );

    // Get authorization for Firebase scopes if needed
    final authClient = _googleSignIn.authorizationClient;
    final authorization = await authClient.authorizationForScopes(['email']);

    // Obtain auth details from the request
    final GoogleSignInAuthentication googleAuth = googleUser.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: authorization?.accessToken,
      idToken: googleAuth.idToken,
    );

    final userCredential = await FirebaseAuth.instance.signInWithCredential(
      credential,
    );

    // Update local state
    _currentUser = googleUser;

    return userCredential;
  }

  Future<UserCredential> signInWithGoogle() async {
    await _ensureGoogleSignInInitialized();
    // Trigger the authentication flow
    final GoogleSignInAccount googleUser = await GoogleSignIn.instance
        .authenticate();

    // Obtain the auth details from the request
    final GoogleSignInAuthentication googleAuth = googleUser.authentication;

    // Create a new credential
    final credential = GoogleAuthProvider.credential(
      idToken: googleAuth.idToken,
    );

    // Once signed in, return the UserCredential
    return await FirebaseAuth.instance.signInWithCredential(credential);
  }

  // Legacy Sign out
  //Future<void> signOut() async {
  //  await _auth.signOut();
  //}
}
