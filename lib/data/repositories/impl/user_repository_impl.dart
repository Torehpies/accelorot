import '../../models/user_model.dart';
import '../contracts/user_repository.dart';
import '../../services/contracts/user_service.dart';

class UserRepositoryImpl implements IUserRepository {
  final UserService service;

  UserRepositoryImpl(this.service);

  @override
  Future<List<UserModel>> getUsers() {
    return service.fetchUsers();
  }

  @override
  Future<UserModel?> getUser(String id) {
    return service.getUserById(id);
  }
}
 