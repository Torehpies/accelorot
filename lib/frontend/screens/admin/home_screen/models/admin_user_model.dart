class AdminUserModel {
  final String id;
  final String name;
  final String imageUrl;
  final String email;
  final String role;

  AdminUserModel({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.email,
    this.role = 'User',
  });

  // Factory constructor for creating from Firestore
  factory AdminUserModel.fromMap(Map<String, dynamic> data, String documentId) {
    return AdminUserModel(
      id: documentId,
      name: data['name'] ?? 'Unknown',
      imageUrl: data['imageUrl'] ?? '',
      email: data['email'] ?? '',
      role: data['role'] ?? 'User',
    );
  }

  // Convert to map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'imageUrl': imageUrl,
      'email': email,
      'role': role,
    };
  }

  // Copy with method
  AdminUserModel copyWith({
    String? id,
    String? name,
    String? imageUrl,
    String? email,
    String? role,
  }) {
    return AdminUserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      imageUrl: imageUrl ?? this.imageUrl,
      email: email ?? this.email,
      role: role ?? this.role,
    );
  }
}

class AdminStats {
  final int userCount;
  final int machineCount;

  AdminStats({
    required this.userCount,
    required this.machineCount,
  });

  AdminStats copyWith({
    int? userCount,
    int? machineCount,
  }) {
    return AdminStats(
      userCount: userCount ?? this.userCount,
      machineCount: machineCount ?? this.machineCount,
    );
  }
}