//activity_logs_screen.dart
import 'package:flutter/material.dart';
import 'components/all_activity_section.dart';
import 'components/substrate_section.dart';
import 'components/alerts_section.dart';

class ActivityLogsScreen extends StatelessWidget {
  const ActivityLogsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Activity Logs'),
        backgroundColor: Colors.teal,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 80), // space above nav bar
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: const [
              AllActivitySection(),
              SizedBox(height: 16),
              SubstrateSection(),
              SizedBox(height: 16),
              AlertsSection(),
            ],
          ),
        ),
      ),
    );
  }
}
