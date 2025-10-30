//machine_mock_data.dart

class MachineMockData {
  static List<Map<String, dynamic>> getMockMachines() {
    return [
      // Active Machines (3)
      {
        'machineName': 'Composter Alpha',
        'machineId': 'MACH0001',
        'userId': 'user_placeholder_001',
        'teamId': '',
        'dateCreated': DateTime(2025, 8, 15),
        'isArchived': false,
      },
      {
        'machineName': 'Composter Beta',
        'machineId': 'MACH0002',
        'userId': 'user_placeholder_002',
        'teamId': '',
        'dateCreated': DateTime(2025, 8, 20),
        'isArchived': false,
      },
      {
        'machineName': 'Composter Gamma',
        'machineId': 'MACH0003',
        'userId': 'user_placeholder_003',
        'teamId': '',
        'dateCreated': DateTime(2025, 9, 1),
        'isArchived': false,
      },
      
      // Archived Machines (3)
      {
        'machineName': 'Old Composter 1',
        'machineId': 'MACH0004',
        'userId': 'user_placeholder_001',
        'teamId': '',
        'dateCreated': DateTime(2024, 12, 10),
        'isArchived': true,
      },
      {
        'machineName': 'Old Composter 2',
        'machineId': 'MACH0005',
        'userId': 'user_placeholder_002',
        'teamId': '',
        'dateCreated': DateTime(2025, 1, 5),
        'isArchived': true,
      },
      {
        'machineName': 'Test Machine',
        'machineId': 'MACH0006',
        'userId': 'user_placeholder_003',
        'teamId': '',
        'dateCreated': DateTime(2025, 2, 14),
        'isArchived': true,
      },
    ];
  }
}