import 'package:flutter/cupertino.dart';
import 'package:flutter_application_1/routes/auth_notifier.dart';
import 'package:flutter_application_1/routes/auth_status.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Ref ref) {
    ref.listen<AuthStatus>(authStateProvider, (previousState, newState) {
      bool shouldNotify = previousState.runtimeType != newState.runtimeType;

      if (newState is Authenticated && previousState is Authenticated) {
        if (previousState.role != newState.role) {
          shouldNotify = true;
        }
      }
      if (shouldNotify) {
        notifyListeners();
      }
    });
  }
}
