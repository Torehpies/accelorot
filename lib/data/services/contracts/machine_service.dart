abstract class MachineService {
  Future<List<MachineModel>> getAllMachines();
  Future<List<MachineModel>> getMachinesByTeamId(String teamId);
  Future<String?> getCurrentUserId();
}
String selectedFilterLabel = "Date Filter";
  List<MachineModel> machines = [];
  List<MachineModel> filteredMachines = [];
  bool isLoading = true;
  String? errorMessage;
  String searchQuery = "";

  // For focus support (preserve behavior)
  String? focusedMachineId;
  MachineModel? focusedMachine;

  void setFocus({String? id, MachineModel? machine}) {
    focusedMachineId = id;
    focusedMachine = machine;
  }

  Future<void> loadMachines() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      if (focusedMachine != null) {
        machines = [focusedMachine!];
        filteredMachines = machines;
        isLoading = false;
        notifyListeners();
        return;
      }

      final currentUserId = await repository.getCurrentUserId();

      if (focusedMachineId != null) {
        final allMachines = await repository.fetchAllMachines();
        machines =
            allMachines.where((m) => m.machineId == focusedMachineId).toList();
      } else {
        if (currentUserId != null) {
          final userData = await sessionService.getCurrentUserData();
          final teamId = userData?['teamId'] as String?;
          if (teamId != null && teamId.isNotEmpty) {
            machines = await repository.fetchMachinesByTeam(teamId);
          } else {
            machines = await repository.fetchAllMachines();
          }
        } else {
          machines = await repository.fetchAllMachines();
        }
      }

      filteredMachines = machines;
      isLoading = false;
      notifyListeners();
    } catch (e) {
      errorMessage = 'Failed to load machines: $e';
      isLoading = false;
      notifyListeners();
    }
  }