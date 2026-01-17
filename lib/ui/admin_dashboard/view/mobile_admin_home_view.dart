import 'package:flutter/foundation.dart' show kIsWeb; 
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../view_model/admin_home_provider.dart';
import '../web_widgets/stat_card.dart';
import '../web_widgets/recent_activities_table.dart';
import '../widgets/analytics_widget.dart'; 
import '../../core/widgets/shared/mobile_header.dart'; 

class MobileAdminHomeView extends ConsumerWidget {
  const MobileAdminHomeView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncState = ref.watch(adminHomeProvider);

    return Scaffold(
      appBar: kIsWeb
          ? null 
          : const MobileHeader(title: 'Dashboard'),

      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(adminHomeProvider.notifier).loadData();
        },
        child: asyncState.when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: Color(0xFF4CAF50)),
          ),
          error: (err, _) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text('Error: $err', textAlign: TextAlign.center),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => ref.read(adminHomeProvider.notifier).refresh(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
          data: (state) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Overview Section Header
                  const Text(
                    'Overview',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1F2937)),
                  ),
                  const SizedBox(height: 16),

                  // Stat Cards (Stacked vertically on mobile)
                  StatCard(
                    title: "Total Operators",
                    value: state.totalOperators,
                    growth: state.operatorGrowthRate,
                    icon: Icons.person_outline,
                    iconBackgroundColor: const Color(0xFF22C55E),
                  ),
                  const SizedBox(height: 12),
                  StatCard(
                    title: "Total Machines",
                    value: state.totalMachines,
                    growth: state.machineGrowthRate,
                    icon: Icons.settings_outlined,
                    iconBackgroundColor: const Color(0xFF3B82F6),
                  ),
                  const SizedBox(height: 12),
                  StatCard(
                    title: "Total Reports",
                    value: state.totalReports,
                    growth: state.reportGrowthRate,
                    icon: Icons.description_outlined,
                    iconBackgroundColor: const Color(0xFFF59E0B),
                  ),
                  const SizedBox(height: 24),

                  // Analytics Widget (combines Activity Chart and Status Chart with tabs)
                  AnalyticsWidget(reports: state.reports),
                  const SizedBox(height: 24),

                  // Recent Activities Section
                  const Text(
                    'Recent Activities',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1F2937)),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 500,
                    child: const RecentActivitiesTable(),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}