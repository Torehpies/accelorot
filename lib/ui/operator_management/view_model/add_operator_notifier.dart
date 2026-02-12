import 'package:flutter_application_1/data/models/app_user.dart';
import 'package:flutter_application_1/data/providers/auth_providers.dart';
import 'package:flutter_application_1/data/providers/operator_providers.dart';
import 'package:flutter_application_1/data/providers/team_providers.dart';
import 'package:flutter_application_1/data/services/contracts/team_service.dart';
import 'package:flutter_application_1/data/services/firebase/firebase_operator_service.dart';
import 'package:flutter_application_1/data/utils/result.dart';
import 'package:flutter_application_1/utils/operator_headers.dart';
import 'package:flutter_application_1/utils/roles.dart';
import 'package:flutter_application_1/utils/user_status.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'add_operator_state.dart';

part 'add_operator_notifier.g.dart';

@riverpod
class AddOperatorNotifier extends _$AddOperatorNotifier {
  late final FirebaseOperatorService _operatorService;
  late final TeamService _teamService;
  @override
  AddOperatorState build() {
    _operatorService = ref.read(operatorServiceProvider);
    _teamService = ref.read(teamServiceProvider);
    return const AddOperatorState(isLoading: false);
  }

  /// SIPIR - Added operators are email verified
  /// as upon setting their password means
  /// they have access to that email

  Future<void> addOperator({
    required String email,
    required String firstname,
    required String lastname,
    String? teamId,
  }) async {
    // Start loading
    state = state.copyWith(isLoading: true, error: null);

    final teamUser = ref.read(appUserProvider).value;
    final teamId = teamUser?.teamId;
    if (teamId == null) return;

    final result = await _operatorService.addUser(
      email: email,
      firstname: firstname,
      lastname: lastname,
      globalRole: GlobalRole.user.value,
      teamRole: TeamRole.operator.value,
      status: UserStatus.approval.value,
      requestTeamId: teamId,
    );
    // Handle success and errors

    if (result is Error<AppUser>) {
      final error = result.error;
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to Add Operator: ${error.toString()}',
      );
      return;
    }

    final incrementResult = await _teamService.incrementTeamField(
      teamId: teamId,
      field: OperatorHeaders.activeOperators,
      amount: 1,
    );

    if (incrementResult is Error<String>) {
      final error = incrementResult.error;
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to update Team Summary: ${error.toString()}',
      );
      return;
    }

    final appUser = (result as Ok<AppUser>).value;
    state = state.copyWith(isLoading: false, operator: appUser);
  }
}
