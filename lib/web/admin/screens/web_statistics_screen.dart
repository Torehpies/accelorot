// lib/web/screens/web_statistics_screen.dart

import 'package:flutter/material.dart';

class WebStatisticsScreen extends StatelessWidget {
  const WebStatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Statistics')),
      body: const Center(child: Text('Web Statistics Screen')),
    );
  }
}