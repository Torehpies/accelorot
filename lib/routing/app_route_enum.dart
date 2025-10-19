enum AppRoutes { home, login, register, activity, statistics, profile, users, machines}

extension AppRouteExtension on AppRoutes {
  String get path {
    switch (this) {
      case AppRoutes.home:
        return '/';
      case AppRoutes.login:
        return '/login';
      case AppRoutes.register:
        return '/register';
      case AppRoutes.activity:
        return '/activity';
      case AppRoutes.statistics:
        return '/statistics';
      case AppRoutes.profile:
        return '/profile';
      case AppRoutes.users:
        return '/users';
      case AppRoutes.machines:
        return '/machines';
    }
  }

  String get routeName {
    switch (this) {
      case AppRoutes.home:
        return 'Home';
      case AppRoutes.login:
        return 'Login';
      case AppRoutes.register:
        return 'Register';
      case AppRoutes.activity:
        return 'Activity';
      case AppRoutes.statistics:
        return 'Statistics';
      case AppRoutes.profile:
        return 'profile';
      case AppRoutes.users:
        return 'Users';
      case AppRoutes.machines:
        return 'machines';
    }
  }
}
