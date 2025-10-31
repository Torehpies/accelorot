import 'package:flutter/material.dart';
import 'package:flutter_application_1/repositories/auth_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AppRouterListenable extends ChangeNotifier {
  AppRouterListenable({required this.ref});
  final Ref ref;

  Future<void> signIn({required String email, required String password}) => ref
      .read(authRepositoryProvider)
      .signInWithEmail(email, password)
      .then((value) => notifyListeners());

  Future<void> signOut() => ref
      .read(authRepositoryProvider)
      .signOut()
      .then((value) => notifyListeners());
}

final appRouterListenableProvider = Provider<AppRouterListenable>(
  (ref) => AppRouterListenable(ref: ref),
);
