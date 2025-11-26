import 'package:flutter/foundation.dart';

class AddOperatorViewModel extends ChangeNotifier {
  String firstName = '';
  String lastName = '';
  String username = '';
  String email = '';
  String password = '';
  String confirmPassword = '';

  bool loading = false;
  String? error;

  void updateFirstName(String value) {
    firstName = value;
    notifyListeners();
  }

  void updateLastName(String value) {
    lastName = value;
    notifyListeners();
  }

  void updateUsername(String value) {
    username = value;
    notifyListeners();
  }

  void updateEmail(String value) {
    email = value;
    notifyListeners();
  }

  void updatePassword(String value) {
    password = value;
    notifyListeners();
  }

  void updateConfirmPassword(String value) {
    confirmPassword = value;
    notifyListeners();
  }

  bool get isValid {
    return firstName.isNotEmpty &&
        lastName.isNotEmpty &&
        username.isNotEmpty &&
        email.isNotEmpty &&
        password.isNotEmpty &&
        password == confirmPassword;
  }

  Future<void> addOperator() async {
    if (!isValid) {
      error = 'Please fill all required fields correctly';
      notifyListeners();
      return;
    }

    loading = true;
    error = null;
    notifyListeners();

    try {
      // TODO: Implement Firebase Auth creation + add to team
      await Future.delayed(const Duration(seconds: 2)); // Placeholder
      
      // Clear form on success
      firstName = '';
      lastName = '';
      username = '';
      email = '';
      password = '';
      confirmPassword = '';
    } catch (e) {
      error = e.toString();
    } finally {
      loading = false;
      notifyListeners();
    }
  }


}