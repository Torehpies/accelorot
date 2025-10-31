class UserEntity {
  final String uid;
  final String role;
  final String? teamId;
  final String? pendingTeamId;
  final bool isArchived;
  final bool hasLeft;

  const UserEntity({
    required this.uid,
    required this.role,
    this.teamId,
    this.pendingTeamId,
    this.isArchived = false,
    this.hasLeft = false,
  });

  factory UserEntity.fromMap(String uid, Map<String, dynamic> data) {
    return UserEntity(
      uid: uid,
      role: data['role'] ?? 'Operator',
      teamId: data['teamId'] as String?,
      pendingTeamId: data['pendingTeamId'] as String?,
			isArchived: data['isArchived'] ?? false,
			hasLeft: data['hasLeft'] ?? false,
    );
  }

  bool get isAdmin => role == 'Admin';
  bool get isRestricted => isArchived || hasLeft;

  UserEntity copyWith({bool? isArchived, bool? hasLeft}) {
    return UserEntity(
      uid: uid,
      role: role,
      teamId: teamId,
      pendingTeamId: pendingTeamId,
      isArchived: isArchived ?? this.isArchived,
      hasLeft: hasLeft ?? this.hasLeft,
    );
  }
}
