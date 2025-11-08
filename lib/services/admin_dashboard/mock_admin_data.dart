import '../../../frontend/screens/admin/home_screen/models/operator_model.dart';
import '../../../frontend/screens/admin/home_screen/models/machine_model.dart';
import '../../../frontend/screens/admin/home_screen/models/admin_stats.dart';

/// Mock data service for admin dashboard
/// Used when user is NOT logged in or as fallback
class MockAdminData {
  // Mock statistics
  static AdminStats getStats() {
    return AdminStats(
      userCount: 8, // Total operators
      machineCount: 6, // Total machines
    );
  }

  // Mock operators
  static List<OperatorModel> getMockOperators() {
    final now = DateTime.now();
    return [
      OperatorModel(
        userId: 'mock_op_1',
        name: 'Emma Davis',
        email: 'emma.davis@example.com',
        role: 'Operator',
        isArchived: false,
        addedAt: now.subtract(const Duration(days: 30)),
      ),
      OperatorModel(
        userId: 'mock_op_2',
        name: 'James Wilson',
        email: 'james.wilson@example.com',
        role: 'Operator',
        isArchived: false,
        addedAt: now.subtract(const Duration(days: 45)),
      ),
      OperatorModel(
        userId: 'mock_op_3',
        name: 'Sarah Johnson',
        email: 'sarah.johnson@example.com',
        role: 'Operator',
        isArchived: false,
        addedAt: now.subtract(const Duration(days: 60)),
      ),
      OperatorModel(
        userId: 'mock_op_4',
        name: 'Michael Chen',
        email: 'michael.chen@example.com',
        role: 'Operator',
        isArchived: false,
        addedAt: now.subtract(const Duration(days: 75)),
      ),
      OperatorModel(
        userId: 'mock_op_5',
        name: 'Lisa Anderson',
        email: 'lisa.anderson@example.com',
        role: 'Operator',
        isArchived: true, // Archived example
        addedAt: now.subtract(const Duration(days: 90)),
      ),
      OperatorModel(
        userId: 'mock_op_6',
        name: 'David Martinez',
        email: 'david.martinez@example.com',
        role: 'Operator',
        isArchived: false,
        addedAt: now.subtract(const Duration(days: 105)),
      ),
      OperatorModel(
        userId: 'mock_op_7',
        name: 'Emily Brown',
        email: 'emily.brown@example.com',
        role: 'Operator',
        isArchived: true, // Archived example
        addedAt: now.subtract(const Duration(days: 120)),
      ),
      OperatorModel(
        userId: 'mock_op_8',
        name: 'Robert Taylor',
        email: 'robert.taylor@example.com',
        role: 'Operator',
        isArchived: false,
        addedAt: now.subtract(const Duration(days: 135)),
      ),
    ];
  }

  // Mock machines
  static List<MachineModel> getMockMachines() {
    final now = DateTime.now();
    return [
      MachineModel(
        id: 'MACH001',
        machineId: 'MACH001',
        machineName: 'Precision Cutter A1',
        userId: 'mock_op_1',
        teamId: '', // Empty for easier fetching
        isArchived: false,
        dateCreated: now.subtract(const Duration(days: 180)),
      ),
      MachineModel(
        id: 'MACH002',
        machineId: 'MACH002',
        machineName: 'Assembly Line Beta',
        userId: 'mock_op_2',
        teamId: '',
        isArchived: false,
        dateCreated: now.subtract(const Duration(days: 165)),
      ),
      MachineModel(
        id: 'MACH003',
        machineId: 'MACH003',
        machineName: 'Quality Checker Pro',
        userId: 'mock_op_3',
        teamId: '',
        isArchived: false,
        dateCreated: now.subtract(const Duration(days: 150)),
      ),
      MachineModel(
        id: 'MACH004',
        machineId: 'MACH004',
        machineName: 'Packaging Unit X',
        userId: 'mock_op_4',
        teamId: '',
        isArchived: true, // Archived example
        dateCreated: now.subtract(const Duration(days: 135)),
      ),
      MachineModel(
        id: 'MACH005',
        machineId: 'MACH005',
        machineName: 'Conveyor System 2',
        userId: 'mock_op_5',
        teamId: '',
        isArchived: false,
        dateCreated: now.subtract(const Duration(days: 120)),
      ),
      MachineModel(
        id: 'MACH006',
        machineId: 'MACH006',
        machineName: 'Sorting Machine Delta',
        userId: 'mock_op_6',
        teamId: '',
        isArchived: false,
        dateCreated: now.subtract(const Duration(days: 105)),
      ),
    ];
  }

  // Get operators for display (first 4 active ones for preview)
  static List<OperatorModel> getOperatorsPreview() {
    return getMockOperators().where((op) => !op.isArchived).take(4).toList();
  }

  // Get machines for display (first 4 active ones for preview)
  static List<MachineModel> getMachinesPreview() {
    return getMockMachines()
        .where((machine) => !machine.isArchived)
        .take(4)
        .toList();
  }
}
