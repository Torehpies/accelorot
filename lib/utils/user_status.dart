enum UserStatus {
  loading('loading'),
  unauthenticated('unauthenticated'),
  unverified('unverified'),
  teamSelect('teamSelect'),
  pending('pending'),
  archived('archived'),
  active('active');

  final String value;
  const UserStatus(this.value);
}
