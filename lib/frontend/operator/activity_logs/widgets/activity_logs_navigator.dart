import 'package:flutter/material.dart';
import '../activity_logs_screen.dart';
import '../view_screens/all_activity_screen.dart';
import '../view_screens/substrates_screen.dart';
import '../view_screens/alerts_screen.dart';
import '../view_screens/cycles_recom_screen.dart';
import '../widgets/slide_page_route.dart';

class ActivityLogsNavigator extends StatelessWidget {
  final String? viewingOperatorId;
  
  const ActivityLogsNavigator({super.key, this.viewingOperatorId});

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
          case '/cyclesRecom':
            page = const CyclesRecomScreen();
            break;
          default:
            page = const ActivityLogsScreen();
        }

        return SlidePageRoute(
          page: page,
          routeSettings: settings,
        );
      },
    );
  }
}