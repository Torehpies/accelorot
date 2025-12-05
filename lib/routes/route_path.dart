enum RoutePath {
  initial(path: '/'),
  loading(path: '/loading'),
  signin(path: '/signin'),
  signup(path: '/signup'),
  //qrRefer(path: '/qr-refer'),
  pending(path: '/pending'),
  verifyEmail(path: '/verify-email'),
  teamSelect(path: '/team-select'),
  restricted(path: '/restricted'),
  forgotPassword(path: '/forgot-password'),

  // operator paths
  dashboard(path: '/operator/dashboard'),
  activity(path: '/operator/activity'),
  statistics(path: '/operator/statistics'),
  operatorMachines(path: '/operator/machines'),
  profile(path: '/operator/profile'),

  //admin paths
  adminDashboard(path: '/admin/dashboard'),
  adminActivity(path: '/admin/activity'),
  adminStatistics(path: '/admin/statistics'),
  adminMachines(path: '/admin/machines'),
  adminOperators(path: '/admin/operators'),
  adminProfile(path: '/admin/profile'),

  //TODO placeholder super admin paths
  superAdminTeams(path: '/superadmin/teams'),
  superAdminProfile(path: '/superadmin/profile');

  const RoutePath({required this.path});
  final String path;
}
