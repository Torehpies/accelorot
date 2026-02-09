// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_application_1/services/auth_wrapper.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:provider/provider.dart' as prov;
// import 'package:flutter_application_1/ui/web_admin_home/view_model/web_admin_dashboard_view_model.dart';
// import 'package:flutter_application_1/ui/web_admin_home/widgets/dashboard_view.dart';
// import '../../../data/providers/admin_dashboard_providers.dart';
// import '../../../frontend/screens/admin/operator_management/operator_management_screen.dart' show OperatorManagementScreen;
// import '../../../ui/web_machine/widgets/admin/web_admin_machine_view.dart';
// import '../../../ui/profile_screen/web_widgets/web_profile_view.dart';
// import '../../../ui/reports/view/web_reports_view.dart';
//
//
// class WebAdminNavigation extends ConsumerStatefulWidget {
//   const WebAdminNavigation({super.key});
//
//   @override
//   ConsumerState<WebAdminNavigation> createState() => _WebAdminNavigationState();
// }
//
// class _WebAdminNavigationState extends ConsumerState<WebAdminNavigation> {
//   int _selectedIndex = 0;
//
//   // Keep dashboard view model alive
//   late WebAdminDashboardViewModel _dashboardViewModel;
//
//   late final List<Widget> _screens;
//
//   final List<_NavItem> _navItems = const [
//     _NavItem(Icons.dashboard, 'Dashboard'),
//     _NavItem(Icons.supervisor_account, 'Operators'),
//     _NavItem(Icons.settings, 'Machines'),
//     _NavItem(Icons.report, 'Reports'),
//     _NavItem(Icons.person, 'Profile'),
//   ];
//
//   @override
//   void initState() {
//     super.initState();
//     final teamId = FirebaseAuth.instance.currentUser?.uid ?? '';
//
//     // Now this should work since we have the repository and provider
//     final repository = ref.read(dashboardRepositoryProvider);
//
//     // Initialize view model ONCE - it loads data automatically in constructor
//     _dashboardViewModel = WebAdminDashboardViewModel(repository, teamId);
//
//     _screens = [
//       // Dashboard with pre-loaded view model
//       prov.ChangeNotifierProvider.value(
//         value: _dashboardViewModel,
//         child: _DashboardWithSkeleton(viewModel: _dashboardViewModel),
//       ),
//       OperatorManagementScreen(teamId: teamId),
//       const WebAdminMachineView(),
//       // OperatorManagementScreen(teamId: FirebaseAuth.instance.currentUser?.uid ?? ''),
//       const WebReportsView(),
//       const WebProfileView(),
//     ];
//   }
//
//   Future<void> _handleLogout() async {
//     final shouldLogout = await showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Confirm Logout'),
//         content: const Text('Are you sure you want to log out?'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context, false),
//             child: const Text('Cancel'),
//           ),
//           ElevatedButton(
//             onPressed: () => Navigator.pop(context, true),
//             style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
//             child: const Text('Logout'),
//           ),
//         ],
//       ),
//     );
//
//     if (shouldLogout == true && mounted) {
//       await FirebaseAuth.instance.signOut();
//       if (!mounted) return;
//       Navigator.pushAndRemoveUntil(
//         context,
//         MaterialPageRoute(builder: (_) => const AuthWrapper()),
//         (route) => false,
//       );
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Row(
//         children: [
//           // Sidebar (unchanged)
//           Container(
//             width: 250,
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 begin: Alignment.topCenter,
//                 end: Alignment.bottomCenter,
//                 colors: [Colors.teal.shade700, Colors.teal.shade900],
//               ),
//             ),
//             child: SafeArea(
//               child: Column(
//                 children: [
//                   const SizedBox(height: 24),
//                   Container(
//                     padding: const EdgeInsets.all(12),
//                     decoration: BoxDecoration(
//                       color: Colors.white.withValues(alpha: 0.1),
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     child: const Icon(Icons.eco, size: 40, color: Colors.white),
//                   ),
//                   const SizedBox(height: 12),
//                   const Text(
//                     'Accel-O-Rot',
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontSize: 20,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   const SizedBox(height: 4),
//                   Text(
//                     'Admin Portal',
//                     style: TextStyle(
//                       color: Colors.white.withValues(alpha: 0.7),
//                       fontSize: 12,
//                     ),
//                   ),
//                   const SizedBox(height: 8),
//                   Container(
//                     margin: const EdgeInsets.symmetric(horizontal: 16),
//                     padding: const EdgeInsets.all(12),
//                     decoration: BoxDecoration(
//                       color: Colors.white.withValues(alpha: 0.1),
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                     child: Row(
//                       children: [
//                         CircleAvatar(
//                           radius: 16,
//                           backgroundColor: Colors.white.withValues(alpha: 0.2),
//                           child: const Icon(
//                             Icons.person,
//                             size: 16,
//                             color: Colors.white,
//                           ),
//                         ),
//                         const SizedBox(width: 8),
//                         Expanded(
//                           child: Text(
//                             FirebaseAuth.instance.currentUser?.email ?? 'User',
//                             style: const TextStyle(
//                               color: Colors.white,
//                               fontSize: 12,
//                             ),
//                             overflow: TextOverflow.ellipsis,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   const Divider(color: Colors.white30, height: 32),
//
//                   Expanded(
//                     child: ListView.builder(
//                       padding: const EdgeInsets.symmetric(horizontal: 8),
//                       itemCount: _navItems.length,
//                       itemBuilder: (context, index) {
//                         final item = _navItems[index];
//                         final isSelected = _selectedIndex == index;
//                         return Container(
//                           margin: const EdgeInsets.only(bottom: 4),
//                           child: Material(
//                             color: Colors.transparent,
//                             child: ListTile(
//                               leading: Icon(
//                                 item.icon,
//                                 color: isSelected ? Colors.white : Colors.white70,
//                                 size: 22,
//                               ),
//                               title: Text(
//                                 item.label,
//                                 style: TextStyle(
//                                   color: isSelected ? Colors.white : Colors.white70,
//                                   fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
//                                   fontSize: 14,
//                                 ),
//                               ),
//                               selected: isSelected,
//                               selectedTileColor: Colors.white.withValues(alpha: 0.15),
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(8),
//                               ),
//                               onTap: () => setState(() => _selectedIndex = index),
//                             ),
//                           ),
//                         );
//                       },
//                     ),
//                   ),
//                   Container(
//                     margin: const EdgeInsets.all(16),
//                     child: Material(
//                       color: Colors.transparent,
//                       child: ListTile(
//                         leading: const Icon(
//                           Icons.logout,
//                           color: Colors.white70,
//                           size: 22,
//                         ),
//                         title: const Text(
//                           'Logout',
//                           style: TextStyle(color: Colors.white70, fontSize: 14),
//                         ),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(8),
//                           side: BorderSide(
//                             color: Colors.white.withValues(alpha: 0.3),
//                           ),
//                         ),
//                         onTap: _handleLogout,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//
//           // Main Content - Key fix: IndexedStack keeps all screens in memory
//           Expanded(
//             child: Container(
//               color: Colors.grey[50],
//               child: IndexedStack(
//                 index: _selectedIndex,
//                 children: _screens,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// // Separate widget for dashboard with skeleton
// class _DashboardWithSkeleton extends StatefulWidget {
//   final WebAdminDashboardViewModel viewModel;
//
//   const _DashboardWithSkeleton({required this.viewModel});
//
//   @override
//   State<_DashboardWithSkeleton> createState() => _DashboardWithSkeletonState();
// }
//
// class _DashboardWithSkeletonState extends State<_DashboardWithSkeleton> {
//   bool _initialLoadComplete = false;
//
//   @override
//   void initState() {
//     super.initState();
//     // Listen for when loading completes
//     widget.viewModel.addListener(() {
//       if (!widget.viewModel.isLoading && !_initialLoadComplete) {
//         setState(() {
//           _initialLoadComplete = true;
//         });
//       }
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     // Show skeleton only on initial load
//     if (!_initialLoadComplete && widget.viewModel.isLoading) {
//       return _buildSkeletonLoader();
//     }
//
//     return const DashboardView();
//   }
//
//   Widget _buildSkeletonLoader() {
//     return Scaffold(
//       backgroundColor: const Color(0xFFDFF2FF),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             const CircularProgressIndicator(),
//             const SizedBox(height: 16),
//             Text(
//               'Loading Dashboard...',
//               style: TextStyle(
//                 color: Colors.grey[600],
//                 fontSize: 14,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// class _NavItem {
//   final IconData icon;
//   final String label;
//   const _NavItem(this.icon, this.label);
// }
