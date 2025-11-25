// lib/web/admin/models/operator.dart

class Operator {
  final String id;
  final String name;
  final String email;
  final bool isArchived;

  Operator({
    required this.id,
    required this.name,
    required this.email,
    required this.isArchived,
  });

  factory Operator.fromMap(Map<String, dynamic> data, String id) {
    return Operator(
      id: id,
      name: data['name'] ?? '—',
      email: data['email'] ?? '—',
      isArchived: data['isArchived'] == true,
    );
  }
}