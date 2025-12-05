import '../../models/user_model.dart';

abstract class UserService {
  Future<List<UserModel>> fetchUsers();
  Future<UserModel?> getUserById(String id);
}
