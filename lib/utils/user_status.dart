enum UserStatus {
  unverified('unverified'),
  registered('registered'),
  pending('pending'),
  archived('archived'),
  active('active');

  final String value;
  const UserStatus(this.value);
}
