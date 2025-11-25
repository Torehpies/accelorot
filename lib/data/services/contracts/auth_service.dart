abstract class AuthService {
  Stream<String?> get onAuthStateChanged;
  String? get currentUserUid;
  Future<String> signInWithEmail(String email, String password);
  Future<String> signUp(
    String email,
    String password,
  );
  Future<void> signOut();
}
