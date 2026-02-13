import 'package:flutter_application_1/data/models/app_user.dart';
import 'package:flutter_application_1/data/providers/operator_providers.dart';
import 'package:flutter_application_1/data/services/firebase/firebase_operator_service.dart';
import 'package:flutter_application_1/data/utils/result.dart';
import 'package:flutter_application_1/utils/roles.dart';
import 'package:flutter_application_1/utils/user_status.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'add_admin_state.dart';

part 'add_admin_notifier.g.dart';

@riverpod
class AddAdminNotifier extends _$AddAdminNotifier {
  late final FirebaseOperatorService _service;

  @override
  AddAdminState build() {
    _service = ref.read(operatorServiceProvider);
    return const AddAdminState(isLoading: false);
  }

  Future<void> addAdmin({
    required String email,
    required String firstname,
    required String lastname,
    required String teamId,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _service.addUser(
      email: email,
      firstname: firstname,
      lastname: lastname,
      globalRole: GlobalRole.user.value,
      teamRole: TeamRole.admin.value,
      status: UserStatus.approval.value,
      requestTeamId: teamId,
    );
    if (result is Ok<AppUser>) {
      final appUser = result.value;
      state = state.copyWith(isLoading: false, admin: appUser);
    } else if (result is Error<AppUser>) {
      final error = result.error;
      state = state.copyWith(isLoading: false, error: error.toString());
    }
  }
}
