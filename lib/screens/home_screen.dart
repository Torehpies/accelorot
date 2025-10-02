// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import '../components/activity-logs.dart';
import '../components/add-waste-product.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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
            child: Column(
              children: [
                const Spacer(),
                CustomCard(title: "Activity Logs", logs: _wasteLogs),
                const SizedBox(height: 20),
              ],
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