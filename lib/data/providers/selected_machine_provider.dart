import 'package:flutter_riverpod/flutter_riverpod.dart';

class SelectedMachineNotifier extends Notifier<String> {
  @override
  String build() => "";

  void setMachine(String machineId) {
    state = machineId;
  }

  void clearSelection() {
    state = "";
  }
}

final selectedMachineIdProvider =
    NotifierProvider<SelectedMachineNotifier, String>(
      () => SelectedMachineNotifier(),
    );
