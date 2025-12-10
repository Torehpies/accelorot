import 'package:flutter/material.dart';
import 'package:flutter_application_1/ui/core/themes/app_theme.dart';
import 'package:flutter_application_1/ui/core/ui/responsive_layout.dart';
import 'package:flutter_application_1/ui/login/view_model/login_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'desktop_login_view.dart';
import 'mobile_login_view.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(loginProvider, (previous, next) {
      next.when(
        data: (_) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text("Login successful")));
        },
        loading: () {},
        error: (err, _) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(err.toString())));
        },
      );
    });
    return Scaffold(
      backgroundColor: AppColors.background2,
      body: SafeArea(
        child: ResponsiveLayout(
          mobileView: MobileLoginView(),
          desktopView: DesktopLoginView(),
        ),
      ),
    );
  }
}
