class UserModel {
  final String id;
  final String name;
  final String email;
  final bool isActive;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.isActive,
  });

  factory UserModel.fromMap(String id, Map<String, dynamic> data) {
    return UserModel(
      id: id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      isActive: data['isActive'] ?? true,
    );
  }
}
