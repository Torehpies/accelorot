// Basic operator model; expand as needed
class Operator {
  final String uid;
  final String name;
  final String email;
  final String role;
  final bool isArchived;
  final bool hasLeft;
  final DateTime? leftAt;
  final DateTime? archivedAt;
  final DateTime? addedAt;

  Operator({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    required this.isArchived,
    required this.hasLeft,
    this.leftAt,
    this.archivedAt,
    this.addedAt,
  });

  factory Operator.fromUserDoc(Map<String, dynamic> data) {
    final firstName = (data['firstname'] ?? '') as String;
    final lastName = (data['lastname'] ?? '') as String;
    final name = ('$firstName $lastName').trim();
    return Operator(
      uid: (data['uid'] ?? '') as String,
      name: name.isNotEmpty ? name : (data['name'] ?? 'Unknown') as String,
      email: (data['email'] ?? '') as String,
      role: (data['role'] ?? 'Operator') as String,
      isArchived: (data['isArchived'] ?? false) as bool,
      hasLeft: (data['hasLeft'] ?? false) as bool,
    );
  }

  Operator copyWith({
    String? uid,
    String? name,
    String? email,
    String? role,
    bool? isArchived,
    bool? hasLeft,
    DateTime? leftAt,
    DateTime? archivedAt,
    DateTime? addedAt,
  }) {
    return Operator(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      isArchived: isArchived ?? this.isArchived,
      hasLeft: hasLeft ?? this.hasLeft,
      leftAt: leftAt ?? this.leftAt,
      archivedAt: archivedAt ?? this.archivedAt,
      addedAt: addedAt ?? this.addedAt,
    );
  }
}