enum AppRoutes { home, login, register }

extension AppRouteExtension on AppRoutes {
  String get path {
    switch (this) {
      case AppRoutes.home:
        return '/';
      case AppRoutes.login:
        return '/login';
      case AppRoutes.register:
        return '/register';
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
    }
  }
}
