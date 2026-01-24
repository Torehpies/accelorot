String mapAuthErrorCodeToMessage(String code) {
  return switch (code) {
    'user-not-found' => 'No user found with that email.',
    'wrong-password' => 'Wrong password provided.',
    'invalid-email' => 'The email address is not valid.',
    'user-disabled' => 'This account has been disabled.',
    'operation-not-allowed' => 'Email/Password sign-in is not enabled.',
    'network-request-failed' => 'Network error. Check your connection.',
    _ => 'Login failed. Please try again.',
  };
}

String mapRegisterErrorCodeToMessage(String code) {
  return switch (code) {
    'weak-password' => 'The provided password is weak.',
    'email-already-in-use' => 'The account already exists for that email.',
    'invalid-email' => 'The email address is not valid.',
    _ => 'Registration failed. Please try again.',
  };
}
