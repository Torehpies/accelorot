// ignore_for_file: unused_import, unused_field

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter_application_1/services/auth_service.dart';
import 'package:flutter_application_1/utils/snackbar_utils.dart';

class GoogleSignInHandler {
  final AuthService _authService;
  final BuildContext context;

  GoogleSignInHandler(this._authService, this.context);

  Future<void> signInWithGoogle({
    required Function(bool) setLoadingState,
  }) async {
    setLoadingState(true);

    //try {
    //  final UserCredential userCredential = await _authService
    //      .signInWithGoogle();
    //  final User? user = userCredential.user;

    //  if (user != null) {
    //    await _authService.saveGoogleUserToFirestore(
    //      user: user,
    //      role: 'Operator',
    //    );

    //    final username = user.displayName ?? 'friend';
    //    if (context.mounted) {
    //      showSnackbar(context, 'Signed in successfully! Welcome $username');

    //      await Future.delayed(const Duration(milliseconds: 1000));

    //      if (context.mounted) {
    //        Navigator.pushReplacement(
    //          context,
    //          MaterialPageRoute(builder: (context) => const QRReferScreen()),
    //        );
    //      }
    //    }
    //  }
    //} catch (e) {
    //  if (context.mounted) {
    //    showSnackbar(
    //      context,
    //      'Google Sign-In failed unexpectedly.',
    //      isError: true,
    //    );
    //  }
    //} finally {
    //  setLoadingState(false);
    //}
  }
}
