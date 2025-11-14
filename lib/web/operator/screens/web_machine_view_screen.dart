// lib/web/operator/screens/web_machine_view_screen.dart
import 'package:flutter/material.dart';
import '../../../frontend/operator/machine_management/models/machine_model.dart';
import 'web_home_screen.dart';
import 'web_activity_logs_screen.dart';
import 'web_statistics_screen.dart';

class WebMachineViewScreen extends StatefulWidget {
  final MachineModel machine;

  const WebMachineViewScreen({super.key, required this.machine});

  @override
  State<WebMachineViewScreen> createState() => _WebMachineViewScreenState();
}

class _WebMachineViewScreenState extends State<WebMachineViewScreen> {
  int _selectedIndex = 0;

  final List<_NavItem> _navItems = const [
    _NavItem(Icons.dashboard, 'Dashboard'),
    _NavItem(Icons.history, 'Activity Logs'),
    _NavItem(Icons.bar_chart, 'Statistics'),
  ];

  @override
  Widget build(BuildContext context) {
    // Get screens with focused machine
    final screens = [
      WebHomeScreen(focusedMachine: widget.machine),
      WebActivityLogsScreen(focusedMachineId: widget.machine.machineId),
      WebStatisticsScreen(focusedMachineId: widget.machine.machineId),
    ];

    return Scaffold(
      body: Row(
        children: [
          // Sidebar
          Container(
            width: 250,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.teal.shade700, Colors.teal.shade900],
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: 24),
                  // Back Button
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Material(
                      color: Colors.transparent,
                      child: ListTile(
                        leading: const Icon(
                          Icons.arrow_back,
                          color: Colors.white70,
                          size: 22,
                        ),
                        title: const Text(
                          'Back to Machines',
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(
                            color: Colors.white.withValues(alpha: 0.3),
                          ),
                        ),
                        onTap: () => Navigator.pop(context),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Machine Info
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.precision_manufacturing,
                          size: 40,
                          color: Colors.white,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          widget.machine.machineName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'ID: ${widget.machine.machineId}',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.7),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(color: Colors.white30, height: 32),

                  // Navigation Items
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      itemCount: _navItems.length,
                      itemBuilder: (context, index) {
                        final item = _navItems[index];
                        final isSelected = _selectedIndex == index;
                        return Container(
                          margin: const EdgeInsets.only(bottom: 4),
                          child: Material(
                            color: Colors.transparent,
                            child: ListTile(
                              leading: Icon(
                                item.icon,
                                color: isSelected
                                    ? Colors.white
                                    : Colors.white70,
                                size: 22,
                              ),
                              title: Text(
                                item.label,
                                style: TextStyle(
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.white70,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  fontSize: 14,
                                ),
                              ),
                              selected: isSelected,
                              selectedTileColor: Colors.white.withValues(
                                alpha: 0.15,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              onTap: () =>
                                  setState(() => _selectedIndex = index),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Main Content Area
          Expanded(
            child: Container(
              color: Colors.grey[50],
              child: screens[_selectedIndex],
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem(this.icon, this.label);
}
