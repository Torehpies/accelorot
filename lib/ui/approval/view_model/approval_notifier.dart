import 'package:flutter_application_1/data/providers/app_user_providers.dart';
import 'package:flutter_application_1/data/providers/auth_providers.dart';
import 'package:flutter_application_1/data/services/contracts/result.dart';
import 'package:flutter_application_1/ui/approval/view_model/approval_state.dart';
import 'package:flutter_application_1/utils/ui_message.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'approval_notifier.g.dart';

@riverpod
class ApprovalNotifier extends _$ApprovalNotifier {
  @override
  ApprovalState build() {
    return ApprovalState();
  }

  Future<void> accept() async {
    state = state.copyWith(isAccepting: true);
    final appUser = ref.read(appUserProvider).value;
    final teamId = appUser?.requestTeamId;
    if (teamId == null) return;

    final service = ref.read(appUserServiceProvider);

    if (!ref.mounted) return;

    final result = await service.acceptApproval(
      uid: appUser!.uid,
      teamId: teamId,
    );
    result.when(
      success: (_) {
        state = state.copyWith(
          isAccepting: false,
          message: UiMessage.success("Successfully accepted!"),
        );
      },
      failure: (error) {
        state = state.copyWith(
          isAccepting: false,
          message: UiMessage.error(error.userFriendlyMessage),
        );
      },
    );
  }

  Future<void> signOutAndNavigate() async {
    await ref.read(authServiceProvider).signOut();
  }

  void clearMessage() {
    state = state.copyWith(message: null);
  }
}
