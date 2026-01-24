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
  adminOperators(path: '/admin/operators'),
  adminMachines(path: '/admin/machines'),
  adminReports(path: '/admin/reports'),
  adminProfile(path: '/admin/profile'),

  //super admin paths
  superAdminTeams(path: '/superadmin/teams'),
  superAdminMachines(path: '/superadmin/machines'),
  superAdminProfile(path: '/superadmin/profile'),
  
  // settings
  operatorSettings(path: '/operator/settings'),
  adminSettings(path: '/admin/settings'),
  superAdminSettings(path: '/superadmin/settings');

  const RoutePath({required this.path});
  final String path;
}
