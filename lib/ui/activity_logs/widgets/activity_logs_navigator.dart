// lib/frontend/operator/activity_logs/activity_logs_navigator.dart
import 'package:flutter/material.dart';
import '../components/all_activity_section.dart';
import '../components/substrate_section.dart';
import '../components/alerts_section.dart';
import '../components/cycles_recom_section.dart';
import '../components/reports_section.dart';
import '../components/batch_filter_section.dart';
import '../view_screens/all_activity_screen.dart';
import '../view_screens/substrates_screen.dart';
import '../view_screens/alerts_screen.dart';
import '../view_screens/cycles_recom_screen.dart';
import '../view_screens/reports_screen.dart';

// Main navigator for Activity Logs tab with nested routing
class ActivityLogsNavigator extends StatelessWidget {
  final String? focusedMachineId;

  const ActivityLogsNavigator({super.key, this.focusedMachineId});

  @override
  Widget build(BuildContext context) {
    return Navigator(
      onGenerateRoute: (settings) {
        // Route handler - passes focusedMachineId to all screens
        Widget page;

        switch (settings.name) {
          case '/':
            // Overview page with section cards
            page = _ActivityLogsOverview(focusedMachineId: focusedMachineId);
            break;
          case '/all-activity':
            page = AllActivityScreen(focusedMachineId: focusedMachineId);
            break;
          case '/substrates':
            final args = settings.arguments as Map<String, dynamic>?;
            page = SubstratesScreen(
              focusedMachineId: focusedMachineId,
              initialFilter: args?['initialFilter'],
            );
            break;
          case '/alerts':
            final args = settings.arguments as Map<String, dynamic>?;
            page = AlertsScreen(
              focusedMachineId: focusedMachineId,
              initialFilter: args?['initialFilter'],
            );
            break;
          case '/cycles-recom':
            final args = settings.arguments as Map<String, dynamic>?;
            page = CyclesRecomScreen(
              focusedMachineId: focusedMachineId,
              initialFilter: args?['initialFilter'],
            );
            break;
          case '/reports':
            final args = settings.arguments as Map<String, dynamic>?;
            page = ReportsScreen(
              focusedMachineId: focusedMachineId,
              initialFilter: args?['initialFilter'],
            );
            break;
          default:
            page = _ActivityLogsOverview(focusedMachineId: focusedMachineId);
        }

        // Apply slide animation to all routes except home
        if (settings.name == '/') {
          return MaterialPageRoute(builder: (context) => page);
        }

        return _SlidePageRoute(builder: (context) => page);
      },
    );
  }
}

// Custom page route with slide transition animation
class _SlidePageRoute extends PageRouteBuilder {
  final WidgetBuilder builder;

  _SlidePageRoute({required this.builder})
    : super(
        pageBuilder: (context, animation, secondaryAnimation) =>
            builder(context),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOut;
          var tween = Tween(
            begin: begin,
            end: end,
          ).chain(CurveTween(curve: curve));
          var offsetAnimation = animation.drive(tween);
          return SlideTransition(position: offsetAnimation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 300),
      );
}

// Overview page displaying all activity section cards
class _ActivityLogsOverview extends StatelessWidget {
  final String? focusedMachineId;

  const _ActivityLogsOverview({this.focusedMachineId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          focusedMachineId != null ? "Machine Activity Logs" : "Activity Logs",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.teal,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Machine filter banner - only shown when viewing specific machine
              if (focusedMachineId != null)
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.teal.shade50, Colors.teal.shade100],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.teal.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.filter_alt,
                        color: Colors.teal.shade700,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Showing activities for this machine only',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.teal.shade900,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              // Main content container with white background
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                    border: Border.all(color: Colors.grey[300]!, width: 1.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      // Scrollable section cards area (behind)
                      Padding(
                        padding: const EdgeInsets.only(top: 70),
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              AllActivitySection(
                                focusedMachineId: focusedMachineId,
                              ),
                              const SizedBox(height: 16),
                              SubstrateSection(
                                focusedMachineId: focusedMachineId,
                              ),
                              const SizedBox(height: 16),
                              AlertsSection(focusedMachineId: focusedMachineId),
                              const SizedBox(height: 16),
                              CyclesRecomSection(
                                focusedMachineId: focusedMachineId,
                              ),
                              const SizedBox(height: 16),
                              ReportsSection(
                                focusedMachineId: focusedMachineId,
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Batch filter header - positioned on top
                      const Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        child: BatchFilterSection(),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
