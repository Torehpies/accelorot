import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../notifier/admin_dashboard_notifier.dart';
import '../widgets/swipeable_stat_cards.dart';
import '../widgets/analytics_widget.dart';
import '../../operator_dashboard/widgets/add_waste/activity_logs_card.dart';

class MobileAdminHomeView extends ConsumerWidget {
  const MobileAdminHomeView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncState = ref.watch(adminDashboardProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal.shade600,
        title: const Text('Admin Dashboard', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.black),
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('No new notifications')),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(adminDashboardProvider.notifier).loadData();
        },
        child: asyncState.when(
          loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF4CAF50))),
          error: (err, _) => Center(child: Text('Error: $err')),
          data: (state) {
            final statCards = [
              StatCardData(
                count: state.totalOperators,
                label: 'Total Operators',
                subtitle: '+25% activated operators this month',
                icon: Icons.people,
                iconColor: Colors.teal,
                iconBackgroundColor: Colors.teal.shade50,
              ),
              StatCardData(
                count: state.totalMachines,
                label: 'Total Machines',
                subtitle: '+25% new machines this month',
                icon: Icons.precision_manufacturing,
                iconColor: Colors.blue,
                iconBackgroundColor: Colors.blue.shade50,
              ),
              StatCardData(
                count: state.totalReports,
                label: 'Total Reports',
                subtitle: 'Reports submitted this month',
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text('Overview', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      SizedBox.shrink(),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SwipeableStatCards(cards: statCards),
                  const SizedBox(height: 24),
                  
                  // Analytics Section
                  AnalyticsWidget(reports: state.reports),
                  const SizedBox(height: 24),
                  
                  // Activity Logs Section
                  ActivityLogsCard(
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