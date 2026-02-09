import 'package:flutter/foundation.dart';
import 'package:flutter_application_1/data/models/app_auth_state.dart';
import 'package:flutter_application_1/data/providers/app_auth_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RouterNotifier extends ChangeNotifier {
  RouterNotifier(this.ref) {
    ref.listen<AppAuthState>(authStateModelProvider, (_, _) {
      notifyListeners();
    });
  }
  final Ref ref;
}

final routerNotifierProvider = Provider<RouterNotifier>((ref) {
  return RouterNotifier(ref);
});
