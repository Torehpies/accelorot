import 'package:flutter/material.dart';

import '../components/system_card.dart';
import '../components/environmental_sensors_card.dart';
import '../components/composting_progress_card.dart';
import '../components/activity_logs.dart';
import '../components/add_waste_product.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  // Store logged waste products
  final List<Map<String, dynamic>> _wasteLogs = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: Colors.teal,
      ),
      body: SafeArea(
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 500),
            padding: const EdgeInsets.all(24),
            child: ScrollConfiguration(
              behavior: ScrollConfiguration.of(context).copyWith(
                scrollbars: false, // 👈 Hides scrollbar on all platforms
              ),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    EnvironmentalSensorsCard(
                      temperature: 3.0,
                      moisture: 5.0,
                      humidity: 8.0,
                    ),
                    const SizedBox(height: 20),
                    CompostingProgressCard(batchStart: DateTime(2025, 9, 15)),
                    const SizedBox(height: 20),
                    const SystemCard(),
                    const SizedBox(height: 20),
                    CustomCard(title: "Activity Logs", logs: _wasteLogs),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddWasteProductModal(context);
        },
        backgroundColor: Colors.green,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
    );
  }

  void _showAddWasteProductModal(BuildContext context) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => const AddWasteProduct(),
    );

    if (result != null) {
      setState(() {
        _wasteLogs.insert(0, result);
      });
    }
  }
}
