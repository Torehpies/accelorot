import 'package:flutter/material.dart';
import '../../components/system_card.dart';
import '../../components/environmental_sensors_card.dart';
import '../../components/composting_progress_card.dart';
import 'add_waste/add_waste_product.dart';
import 'add_waste/activity_logs_card.dart';
import 'services/activity_log_repository.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> _wasteLogs = [];
  bool _loadingLogs = true;
  bool _logsFetchError = false;

  @override
  void initState() {
    super.initState();
    _loadWasteLogs();
  }

  Future<void> _loadWasteLogs() async {
    try {
      final logs = await ActivityLogRepository.fetchWasteLogs();
      if (mounted) {
        setState(() {
          _wasteLogs = logs;
          _loadingLogs = false;
          _logsFetchError = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loadingLogs = false;
          _logsFetchError = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text(
          'Dashboard',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.teal,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              EnvironmentalSensorsCard(
                temperature: 3.0,
                moisture: 5.0,
                humidity: 8.0,
              ),
              const SizedBox(height: 16),
              CompostingProgressCard(batchStart: DateTime(2025, 9, 15)),
              const SizedBox(height: 16),
              const SystemCard(),
              const SizedBox(height: 16),
              if (_loadingLogs)
                const Center(child: CircularProgressIndicator())
              else if (_logsFetchError)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Center(
                    child: Text(
                      'Please log in to view recent logs',
                      style: const TextStyle(fontSize: 15, color: Colors.grey),
                    ),
                  ),
                )
              else if (_wasteLogs.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Center(
                    child: Text(
                      'No logs yet. Add waste products to see them here.',
                      style: const TextStyle(fontSize: 15, color: Colors.grey),
                    ),
                  ),
                )
              else
                ActivityLogsCard(),
            ],
          ),
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 16, right: 16),
        child: SizedBox(
          width: 58,
          height: 58,
          child: FloatingActionButton(
            onPressed: () async {
              final result = await showDialog<Map<String, dynamic>>(
                context: context,
                builder: (context) => const AddWasteProduct(),
              );
              if (result != null && mounted) {
                await _loadWasteLogs();
              }
            },
            backgroundColor: Colors.teal,
            elevation: 5,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.add, size: 28, color: Colors.white),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
    );
  }
}
