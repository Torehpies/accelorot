import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../data/providers/admin_dashboard_providers.dart';
import '../../web_admin_home/view_model/web_admin_dashboard_view_model.dart';
import 'dashboard_view.dart';

class DashboardProviderWrapper extends ConsumerWidget {
  const DashboardProviderWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardRepo = ref.watch(dashboardRepositoryProvider);
    final teamId = FirebaseAuth.instance.currentUser?.uid ?? '';

    return ChangeNotifierProvider(
      create: (_) => WebAdminDashboardViewModel(dashboardRepo, teamId),
      child: const DashboardView(),
    );
  }
}
