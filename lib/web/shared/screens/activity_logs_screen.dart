import 'package:flutter/material.dart';

class WebAdminHomeScreen extends StatefulWidget {
  const WebAdminHomeScreen({super.key});

  @override
  State<WebAdminHomeScreen> createState() => _WebAdminHomeScreenState();
}

class _WebAdminHomeScreenState extends State<WebAdminHomeScreen> {
  String currentPage = 'dashboard'; // default page

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Sidebar
          Container(
            width: 220,
            color: Colors.green.shade700,
            child: Column(
              children: [
                const SizedBox(height: 40),
                _buildNavItem('Dashboard', 'dashboard'),
                _buildNavItem('Activity Logs', 'activity_logs'),
              ],
            ),
          ),

          // Main content area
          Expanded(
            child: Container(
              color: Colors.grey[100],
              padding: const EdgeInsets.all(16),
              child: _buildPage(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(String title, String page) {
    return ListTile(
      title: Text(
        title,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      onTap: () => setState(() => currentPage = page),
    );
  }

  // This changes what appears on the right side
  Widget _buildPage() {
    switch (currentPage) {
      case 'activity_logs':
        return ActivityLogsPage(onViewAll: (section) {
          setState(() => currentPage = section);
        });
      case 'substrate':
        return const SubstrateLogsPage();
      case 'alerts':
        return const AlertLogsPage();
      case 'cycles':
        return const CycleLogsPage();
      default:
        return const Center(child: Text("Dashboard"));
    }
  }
}

class ActivityLogsPage extends StatelessWidget {
  final Function(String) onViewAll;

  const ActivityLogsPage({super.key, required this.onViewAll});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildSection("Substrate", () => onViewAll('substrate')),
        const SizedBox(height: 16),
        _buildSection("Alerts", () => onViewAll('alerts')),
        const SizedBox(height: 16),
        _buildSection("Cycles", () => onViewAll('cycles')),
      ],
    );
  }

  Widget _buildSection(String title, VoidCallback onViewAll) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const Spacer(),
          GestureDetector(
            onTap: onViewAll,
            child: const Text("View All >", style: TextStyle(color: Colors.green)),
          ),
        ],
      ),
    );
  }
}

// Example of the detailed Substrate page
class SubstrateLogsPage extends StatelessWidget {
  const SubstrateLogsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Image.asset('assets/substrate.png', fit: BoxFit.contain),
    );
  }
}

class AlertLogsPage extends StatelessWidget {
  const AlertLogsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Image.asset('assets/alerts.png', fit: BoxFit.contain),
    );
  }
}

class CycleLogsPage extends StatelessWidget {
  const CycleLogsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Image.asset('assets/cycles.png', fit: BoxFit.contain),
    );
  }
}
