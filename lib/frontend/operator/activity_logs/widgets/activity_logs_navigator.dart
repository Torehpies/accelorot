import 'package:flutter/material.dart';
import '../activity_logs_screen.dart';
import '../view_screens/all_activity_screen.dart';
import '../view_screens/substrates_screen.dart';
import '../view_screens/alerts_screen.dart';
import '../widgets/slide_page_route.dart';

class ActivityLogsNavigator extends StatelessWidget {
  const ActivityLogsNavigator({super.key});

  @override
  Widget build(BuildContext context) {
    return Navigator(
      initialRoute: '/activityLogs',
      onGenerateRoute: (settings) {
        Widget page;
        switch (settings.name) {
          case '/allActivity':
            page = const AllActivityScreen();
            break;
          case '/substrates':
            page = const SubstratesScreen();
            break;
          case '/alerts':
            page = const AlertsScreen();
            break;
          default:
            page = const ActivityLogsScreen();
        }

        return SlidePageRoute(
          page: page,
          routeSettings: settings, // pass Settings through to the route
        );
      },
    );
  }
}
