import 'package:flutter/foundation.dart' show kIsWeb; 
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../view_model/admin_dashboard_notifier.dart';
import '../widgets/swipeable_stat_cards.dart';
import '../widgets/analytics_widget.dart';
import '../../operator_dashboard/widgets/activity_logs/activity_logs_card.dart';
import '../../core/widgets/shared/mobile_header.dart'; 

class MobileAdminHomeView extends ConsumerWidget {
  const MobileAdminHomeView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncState = ref.watch(adminDashboardProvider);

    return Scaffold(
      appBar: kIsWeb
          ? null 
          : const MobileHeader(title: 'Dashboard'),

      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(adminDashboardProvider.notifier).loadData();
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
                  onPressed: () => ref.read(adminDashboardProvider.notifier).refresh(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
          data: (state) {
            final statCards = [
              StatCardData(
                count: state.totalOperators,
                label: 'Total Operators',
                subtitle: '${state.totalOperators} operators in team',
                icon: Icons.people,
                iconColor: Colors.teal,
                iconBackgroundColor: Colors.teal.shade50,
              ),
              StatCardData(
                count: state.totalMachines,
                label: 'Total Machines',
                subtitle: '${state.totalMachines} machines active',
                icon: Icons.precision_manufacturing,
                iconColor: Colors.blue,
                iconBackgroundColor: Colors.blue.shade50,
              ),
              StatCardData(
                count: state.totalReports,
                label: 'Total Reports',
                subtitle: '${state.totalReports} reports submitted',
                icon: Icons.description,
                iconColor: Colors.amber.shade800,
                iconBackgroundColor: Colors.amber.shade50,
              ),
            ];

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Overview Section
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Overview',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SwipeableStatCards(cards: statCards),
                  const SizedBox(height: 24),

                  // Analytics Section
                  AnalyticsWidget(reports: state.reports),
                  const SizedBox(height: 24),

                  // Activity Logs Section
                  const ActivityLogsCard(
                    focusedMachineId: null, // Show all machines for admin
                    maxHeight: 400,
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