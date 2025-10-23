// lib/screens/home_screen.dart

import 'package:flutter/material.dart';
import '../../components/system_card.dart';
import '../../components/environmental_sensors_card.dart';
import '../../components/composting_progress_card.dart';
import '../../components/activity_logs.dart';
import '../../components/add_waste_product.dart';

class HomeScreen extends StatefulWidget {
  final List<Map<String, dynamic>> wasteLogs;

  const HomeScreen({super.key, this.wasteLogs = const []});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late List<Map<String, dynamic>> _wasteLogs;

  @override
  void initState() {
    super.initState();
    _wasteLogs = List.from(widget.wasteLogs);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
     appBar: AppBar(
  title: const Text('Dashboard'),
  centerTitle: false, //  Ensures title is aligned to the left
  backgroundColor: Colors.teal, //  Sets the background color
  // Optional: Ensure text is readable (white by default in light themes)
  foregroundColor: Colors.white,
),
      body: SafeArea(
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 500),
            padding: const EdgeInsets.all(24),
            child: ScrollConfiguration(
              behavior: ScrollConfiguration.of(context).copyWith(
                scrollbars: false,
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
      builder: (context) => AddWasteProduct(),
    );

    if (result != null) {
      setState(() {
        _wasteLogs.insert(0, result);
      });
    }
  }
}