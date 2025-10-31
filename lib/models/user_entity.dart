class UserEntity {
  final String uid;
  final String role;
  final String? teamId;
  final String? pendingTeamId;
  final bool isArchived;
  final bool hasLeft;
  final bool emailVerified; // Added this field

  const UserEntity({
    required this.uid,
    required this.role,
    this.teamId,
    this.pendingTeamId,
    this.isArchived = false,
    this.hasLeft = false,
    this.emailVerified = false, // Added to constructor
  });

  factory UserEntity.fromMap(String uid, Map<String, dynamic> data) {
    return UserEntity(
      uid: uid,
      role: data['role'] ?? 'Operator',
      teamId: data['teamId'] as String?,
      pendingTeamId: data['pendingTeamId'] as String?,
      isArchived: data['isArchived'] ?? false,
      hasLeft: data['hasLeft'] ?? false,
      emailVerified: data['emailVerified'] ?? false, // Added fromMap logic
    );
  }

  bool get isAdmin => role == 'Admin';
  bool get isRestricted => isArchived || hasLeft;

  UserEntity copyWith({
    bool? isArchived,
    bool? hasLeft,
    bool? emailVerified,
  }) {
    return UserEntity(
      uid: uid,
      role: role,
      teamId: teamId,
      pendingTeamId: pendingTeamId,
      isArchived: isArchived ?? this.isArchived,
      hasLeft: hasLeft ?? this.hasLeft,
      emailVerified: emailVerified ?? this.emailVerified,
    );
  }
}

