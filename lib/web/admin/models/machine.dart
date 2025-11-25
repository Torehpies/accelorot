// lib/web/admin/models/machine.dart

class Machine {
  final String id;
  final String name;
  final String machineId;
  final bool isArchived;

  Machine({
    required this.id,
    required this.name,
    required this.machineId,
    required this.isArchived,
  });

  factory Machine.fromMap(Map<String, dynamic> data, String id) {
    return Machine(
      id: id,
      name: data['name'] ?? '—',
      machineId: data['machineId'] ?? '—',
      isArchived: data['isArchived'] == true,
    );
  }
}