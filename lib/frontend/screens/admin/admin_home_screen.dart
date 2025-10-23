// lib/frontend/screens/admin/admin_home_screen.dart

import 'package:flutter/material.dart';

class AdminHomeScreen extends StatelessWidget {
  const AdminHomeScreen({super.key});

  static const List<String> _userNames = [
    'Alice Johnson',
    'Bob Smith',
    'Carol Davis',
    'David Wilson',
    'Elena Rodriguez',
  ];

  static const List<String> _machineNames = [
    'CNC Mill #1',
    'Injection Molder A',
    'Laser Cutter Pro',
    '3D Printer Station',
    'Robotic Arm Beta',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: const Color(0xFF00796B),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // === Stats Cards ===
            Row(
              children: [
                Expanded(child: _buildStatCard('25', 'Users', Icons.person)),
                const SizedBox(width: 20),
                Expanded(child: _buildStatCard('12', 'Machines', Icons.devices)),
              ],
            ),
            const SizedBox(height: 36),

            // === User Management Section ===
            _buildSection(
              title: 'User Management',
              onTap: () => Navigator.pushNamed(context, '/admin/users'),
            ),
            const SizedBox(height: 18),
            _buildHorizontalCardList(
              items: _userNames,
              isMachine: false,
            ),

            const SizedBox(height: 36),

            // === Machine Management Section ===
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Machine Management',
                  style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () => Navigator.pushNamed(context, '/admin/machines'),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  child: const Text(
                    'Manage >',
                    style: TextStyle(color: Colors.teal, fontSize: 16),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            _buildHorizontalCardList(
              items: _machineNames,
              isMachine: true,
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String value, String label, IconData icon) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                value,
                style: const TextStyle(fontSize: 34, fontWeight: FontWeight.bold),
              ),
              Icon(icon, color: Colors.teal, size: 30),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: TextStyle(fontSize: 15, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({required String title, required VoidCallback onTap}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold)),
        TextButton(
          onPressed: onTap,
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          child: const Text(
            'Manage >',
            style: TextStyle(color: Colors.teal, fontSize: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildHorizontalCardList({
    required List<String> items,
    required bool isMachine,
  }) {
    return SizedBox(
      height: 150,
      child: ListView.builder(
        shrinkWrap: true,
        physics: const ClampingScrollPhysics(),
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        itemBuilder: (context, index) {
          return _buildCardWithBorder(name: items[index], isMachine: isMachine);
        },
      ),
    );
  }

  Widget _buildCardWithBorder({required String name, required bool isMachine}) {
    final borderColor = isMachine ? Colors.blue[300] : Colors.teal;
    final iconColor = isMachine ? Colors.blue[400] : Colors.teal;

    return Padding(
      padding: const EdgeInsets.only(right: 16), // Spacing between cards
      child: Container(
        width: 140,
        padding: const EdgeInsets.all(12), // Inner padding
        decoration: BoxDecoration(
          color: Colors.white, // White background
          border: Border.all(
            color: borderColor ?? Colors.grey[300]!, // Visible border
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isMachine ? Icons.devices : Icons.person,
              color: iconColor,
              size: 36,
            ),
            const SizedBox(height: 8),
            Text(
              name,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
