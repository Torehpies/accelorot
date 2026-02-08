import 'package:flutter_application_1/data/models/machine_model.dart';
import 'package:flutter_application_1/data/providers/machine_providers.dart';
import 'package:flutter_application_1/data/repositories/machine_repository/machine_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'team_machine_actions_notifier.g.dart';

@riverpod
class TeamMachineActionsNotifier extends _$TeamMachineActionsNotifier {
  @override
  ({bool isSubmitting, String? errorMessage}) build(String teamId) {
    return (isSubmitting: false, errorMessage: null);
  }

  /// Adds a machine under [teamId].
  ///
  /// Throws if the machine ID already exists so that
  /// [WebAdminAddDialog] can show inline duplicate-ID validation.
  Future<void> addMachine({
    required String machineId,
    required String machineName,
    List<String> assignedUserIds = const [],
  }) async {
    // Capture the repository reference up-front to avoid
    // using ref after the notifier might be disposed during awaits.
    final MachineRepository repository = ref.read(machineRepositoryProvider);

    state = (isSubmitting: true, errorMessage: null);

    try {
      final exists = await repository.checkMachineExists(machineId);
      if (exists) {
        state = (isSubmitting: false, errorMessage: 'Machine ID already exists');
        throw Exception('Machine ID "$machineId" already exists');
      }

      await repository.createMachine(
        CreateMachineRequest(
          machineId: machineId,
          machineName: machineName,
          teamId: teamId,
          assignedUserIds: assignedUserIds,
          status: MachineStatus.active,
        ),
      );

      state = (isSubmitting: false, errorMessage: null);
    } catch (e) {
      state = (isSubmitting: false, errorMessage: e.toString());
      rethrow;
    }
  }
}
