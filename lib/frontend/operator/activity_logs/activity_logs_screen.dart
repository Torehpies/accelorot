//activity_logs_screen.dart
import 'package:flutter/material.dart';
import '../../../services/firestore_activity_service.dart';
import 'components/all_activity_section.dart';
import 'components/substrate_section.dart';
import 'components/alerts_section.dart';

class ActivityLogsScreen extends StatefulWidget {
  const ActivityLogsScreen({super.key});

  @override
  State<ActivityLogsScreen> createState() => _ActivityLogsScreenState();
}

class _ActivityLogsScreenState extends State<ActivityLogsScreen> {
  bool _dataInitialized = false;
  String? _initError;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    try {
      // Upload mock data to Firestore (only once on app start)
      await FirestoreActivityService.uploadAllMockData();
      setState(() {
        _dataInitialized = true;
      });
    } catch (e) {
      setState(() {
        _initError = e.toString();
        _dataInitialized = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_initError != null) {
      return Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text(
            "Activity Logs",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.teal,
        ),
        body: Center(
          child: Text('Error loading data: $_initError'),
        ),
      );
    }

    if (!_dataInitialized) {
      return Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text(
            "Activity Logs",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.teal,
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          "Activity Logs",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.teal,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            16,
            16,
            16,
            80,
          ),
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