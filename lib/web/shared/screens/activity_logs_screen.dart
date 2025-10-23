// activity_logs_screen.dart

import 'package:flutter/material.dart';

class ActivityLogsScreen extends StatelessWidget {
  const ActivityLogsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.grey[100],
        elevation: 0,
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search',
              prefixIcon: const Icon(Icons.search, color: Colors.grey),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: IconButton(
              icon: const Icon(Icons.notifications_outlined),
              onPressed: () {},
              color: Colors.black,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // View All Activity Section
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey,
                    spreadRadius: 1,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(Icons.history, color: Colors.grey),
                  const SizedBox(width: 8.0),
                  const Text(
                    'View All Activity',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16.0,
                    ),
                  ),
                  const Spacer(),
                  const Icon(Icons.arrow_forward_ios, size: 16.0, color: Colors.grey),
                ],
              ),
            ),
            const SizedBox(height: 24.0),

            // Substrates Section
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey,
                          spreadRadius: 1,
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.leak_add, color: Colors.grey),
                            const SizedBox(width: 8.0),
                            const Text(
                              'Substrates',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16.0,
                              ),
                            ),
                            const Spacer(),
                            TextButton(
                              onPressed: () {},
                              child: const Text(
                                'View All >',
                                style: TextStyle(
                                  color: Colors.green,
                                  fontSize: 14.0,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16.0),
                        Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
                _createSubstrateCard('Green', Icons.eco),
                _createSubstrateCard('Brown', Icons.eco),
                _createSubstrateCard('Compost', Icons.recycling),
                ],
                    ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24.0),

            // Alerts Section
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey,
                          spreadRadius: 1,
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.warning, color: Colors.grey),
                            const SizedBox(width: 8.0),
                            const Text(
                              'Alerts',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16.0,
                              ),
                            ),
                            const Spacer(),
                            TextButton(
                              onPressed: () {},
                              child: const Text(
                                'View All >',
                                style: TextStyle(
                                  color: Colors.green,
                                  fontSize: 14.0,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16.0),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _createAlertCard('Temp', Icons.thermostat),
                            _createAlertCard('Moisture', Icons.water_drop),
                            _createAlertCard('Oxygen', Icons.bubble_chart),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _createSubstrateCard(String title, IconData icon) {
    return Container(
      width: 80.0,
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.grey[50] ?? Colors.grey[100]!, // Safe fallback if null
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: Colors.grey[300] ?? Colors.grey[200]!, width: 1.0), // Safe fallback
      ),
      child: Column(
        children: [
          Icon(icon, size: 32.0, color: Colors.grey[700]),
          const SizedBox(height: 8.0),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14.0,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _createAlertCard(String title, IconData icon) {
    return Container(
      width: 80.0,
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.grey[50] ?? Colors.grey[100]!, // Safe fallback if null
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: Colors.grey[300] ?? Colors.grey[200]!, width: 1.0), // Safe fallback
      ),
      child: Column(
        children: [
          Icon(icon, size: 32.0, color: Colors.grey[700]),
          const SizedBox(height: 8.0),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14.0,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}