// lib/screens/web_dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_application_1/frontend/components/add_waste_product.dart';
import 'package:flutter_application_1/frontend/operator/dashboard/home_screen.dart';

class WebDashboardScreen extends StatefulWidget {
  const WebDashboardScreen({super.key});

  @override
  State<WebDashboardScreen> createState() => _WebDashboardScreenState();
}

class _WebDashboardScreenState extends State<WebDashboardScreen> {
  int _selectedIndex = 0;
  final List<Map<String, dynamic>> _wasteLogs = [];

  @override
  Widget build(BuildContext context) {
    // Only show sidebar on web
    if (kIsWeb) {
      return Scaffold(
        appBar: null, // ✅ Top app bar REMOVED
        body: Row(
          children: [
            // Sidebar Navigation (Web Only)
            _buildSidebar(),
            // Main Content Area
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: _getContentForIndex(),
              ),
            ),
          ],
        ),
        floatingActionButton: _selectedIndex == 0
            ? FloatingActionButton(
                onPressed: () {
                  _showAddWasteProductModal(context);
                },
                backgroundColor: Colors.green,
                child: const Icon(Icons.add, color: Colors.white),
              )
            : null,
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      );
    } else {
      // On mobile, just show the original HomeScreen
      return HomeScreen(wasteLogs: _wasteLogs);
    }
  }

  Widget _buildSidebar() {
    final Color activeColor = Colors.blue; // For active item
    final Color inactiveColor = Colors.white; // For inactive items
    final Color backgroundColor = Color(0xFF007A5E); // Dark green sidebar
    final Color hoverColor = Colors.white.withOpacity(0.1);

    return Container(
      width: 240,
      color: backgroundColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logo / App Name
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Text(
              'Accel-O-Rot',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          Divider(color: Colors.white.withOpacity(0.3), height: 1),

          // Menu Items
          _buildNavItem(
            icon: Icons.dashboard,
            label: 'Dashboard',
            isActive: _selectedIndex == 0,
            onPressed: () => setState(() => _selectedIndex = 0),
            activeColor: activeColor,
            inactiveColor: inactiveColor,
            hoverColor: hoverColor,
          ),
          _buildNavItem(
            icon: Icons.history,
            label: 'Activity Logs',
            isActive: _selectedIndex == 1,
            onPressed: () => setState(() => _selectedIndex = 1),
            activeColor: activeColor,
            inactiveColor: inactiveColor,
            hoverColor: hoverColor,
          ),
          _buildNavItem(
            icon: Icons.bar_chart,
            label: 'Statistics',
            isActive: _selectedIndex == 2,
            onPressed: () => setState(() => _selectedIndex = 2),
            activeColor: activeColor,
            inactiveColor: inactiveColor,
            hoverColor: hoverColor,
          ),
          _buildNavItem(
            icon: Icons.settings,
            label: 'Machines',
            isActive: _selectedIndex == 3,
            onPressed: () => setState(() => _selectedIndex = 3),
            activeColor: activeColor,
            inactiveColor: inactiveColor,
            hoverColor: hoverColor,
          ),
          _buildNavItem(
            icon: Icons.person,
            label: 'Users',
            isActive: _selectedIndex == 4,
            onPressed: () => setState(() => _selectedIndex = 4),
            activeColor: activeColor,
            inactiveColor: inactiveColor,
            hoverColor: hoverColor,
          ),
          _buildNavItem(
            icon: Icons.person_outline,
            label: 'Profile',
            isActive: _selectedIndex == 5,
            onPressed: () => setState(() => _selectedIndex = 5),
            activeColor: activeColor,
            inactiveColor: inactiveColor,
            hoverColor: hoverColor,
          ),
          Divider(color: Colors.white.withOpacity(0.3), height: 1),
          _buildNavItem(
            icon: Icons.logout,
            label: 'Logout',
            isActive: false, // Never active
            onPressed: () {
              // Add logout logic here
              print('Logout pressed');
            },
            activeColor: activeColor,
            inactiveColor: inactiveColor,
            hoverColor: hoverColor,
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onPressed,
    required Color activeColor,
    required Color inactiveColor,
    required Color hoverColor,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.zero,
        hoverColor: hoverColor,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 14, horizontal: 20),
          decoration: BoxDecoration(
            color: isActive ? Colors.blue.withOpacity(0.2) : Colors.transparent,
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: isActive ? activeColor : inactiveColor,
                size: 20,
              ),
              SizedBox(width: 16),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                  color: isActive ? activeColor : inactiveColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _getContentForIndex() {
    switch (_selectedIndex) {
      case 0:
        return _buildHomeContent();
      case 1:
        return const Center(child: Text('Activity Logs Screen'));
      case 2:
        return const Center(child: Text('Statistics Screen'));
      case 3:
        return const Center(child: Text('Machines Screen'));
      case 4:
        return const Center(child: Text('Users Screen'));
      case 5:
        return const Center(child: Text('Profile Screen'));
      default:
        return _buildHomeContent();
    }
  }

  Widget _buildHomeContent() {
    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(
        scrollbars: false,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Stats Cards (3 in a row)
            Row(
              children: [
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Text('Total Machines', style: TextStyle(fontSize: 14)),
                          SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('10', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                              Icon(Icons.devices, color: Colors.green),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Text('Total Admins', style: TextStyle(fontSize: 14)),
                          SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('10', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                              Icon(Icons.person, color: Colors.green),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Text('Total Users', style: TextStyle(fontSize: 14)),
                          SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('10', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                              Icon(Icons.person_outline, color: Colors.green),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),

            // Environmental Sensors
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Environmental Sensors', style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Card(
                            color: Colors.green.withOpacity(0.1),
                            child: Padding(
                              padding: EdgeInsets.all(12),
                              child: Column(
                                children: [
                                  Text('Temperature', style: TextStyle(fontSize: 12)),
                                  SizedBox(height: 8),
                                  Text('3°C', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                                  SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(Icons.fiber_manual_record, size: 8, color: Colors.green),
                                      SizedBox(width: 4),
                                      Text('+0 this week', style: TextStyle(fontSize: 10)),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Card(
                            color: Colors.orange.withOpacity(0.1),
                            child: Padding(
                              padding: EdgeInsets.all(12),
                              child: Column(
                                children: [
                                  Text('Moisture', style: TextStyle(fontSize: 12)),
                                  SizedBox(height: 8),
                                  Text('3 g/...', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                                  SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(Icons.fiber_manual_record, size: 8, color: Colors.orange),
                                      SizedBox(width: 4),
                                      Text('+0 this week', style: TextStyle(fontSize: 10)),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Card(
                            color: Colors.red.withOpacity(0.1),
                            child: Padding(
                              padding: EdgeInsets.all(12),
                              child: Column(
                                children: [
                                  Text('Humidity', style: TextStyle(fontSize: 12)),
                                  SizedBox(height: 8),
                                  Text('3%', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                                  SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(Icons.fiber_manual_record, size: 8, color: Colors.red),
                                      SizedBox(width: 4),
                                      Text('+0 this week', style: TextStyle(fontSize: 10)),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),

            // System Status
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('System', style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Uptime', style: TextStyle(fontSize: 14)),
                              Text('12:12:12', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Status', style: TextStyle(fontSize: 14)),
                              Row(
                                children: [
                                  Text('Excellent', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green)),
                                  Icon(Icons.check_circle, color: Colors.green),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Last Update', style: TextStyle(fontSize: 14)),
                              Text('12:12:13 Aug 30, 2025', style: TextStyle(fontSize: 14)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),

            // Composting Progress
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Composting Progress', style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(height: 16),
                    LinearProgressIndicator(
                      value: 0.4,
                      backgroundColor: Colors.grey[200],
                      color: Colors.yellow,
                    ),
                    SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Decomposition', style: TextStyle(fontSize: 12)),
                        Text('40%', style: TextStyle(fontSize: 12)),
                      ],
                    ),
                    SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Batch Start', style: TextStyle(fontSize: 12)),
                            Text('Sep 15, 2025 — 12 days ago', style: TextStyle(fontSize: 12)),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Est Completion', style: TextStyle(fontSize: 12)),
                            Text('Sep 27, 2025 — Completed', style: TextStyle(fontSize: 12)),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddWasteProductModal(BuildContext context) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => AddWasteProduct(), // Removed 'const' unless AddWasteProduct has const constructor
    );

    if (result != null) {
      setState(() {
        _wasteLogs.insert(0, result);
      });
    }
  }
}