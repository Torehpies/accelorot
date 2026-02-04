import 'package:flutter_application_1/data/models/app_user.dart';
import 'package:flutter_application_1/data/providers/auth_providers.dart';
import 'package:flutter_application_1/data/providers/operator_providers.dart';
import 'package:flutter_application_1/data/services/firebase/firebase_operator_service.dart';
import 'package:flutter_application_1/data/utils/result.dart';
import 'package:flutter_application_1/utils/roles.dart';
import 'package:flutter_application_1/utils/user_status.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'add_operator_state.dart';

part 'add_operator_notifier.g.dart';

@riverpod
class AddOperatorNotifier extends _$AddOperatorNotifier {
  late final FirebaseOperatorService _service;
  @override
  AddOperatorState build() {
    _service = ref.read(operatorServiceProvider);
    return const AddOperatorState(isLoading: false);
  }

  /// SIPIR - Added operators are unverified
  /// meaning they have to verify their email first
	/// but their status will be at active

  Future<void> addOperator({
    required String email,
    required String password,
    required String firstname,
    required String lastname,
    String? teamId,
  }) async {
    // Start loading
    state = state.copyWith(isLoading: true, error: null);

    final teamUser = ref.read(appUserProvider).value;
    final teamId = teamUser?.teamId;
    if (teamId == null) return;

    final result = await _service.addOperator(
      email: email,
      password: password,
      firstname: firstname,
      lastname: lastname,
      globalRole: GlobalRole.user.value,
      teamRole: TeamRole.operator.value,
      status: UserStatus.active.value,
      teamId: teamId,
    );
    // Handle success and errors
    if (result is Ok<AppUser>) {
      final appUser = result.value;
      state = state.copyWith(isLoading: false, operator: appUser);
    } else if (result is Error<AppUser>) {
      final error = result.error;
      state = state.copyWith(isLoading: false, error: error.toString());
    }
  }
}
