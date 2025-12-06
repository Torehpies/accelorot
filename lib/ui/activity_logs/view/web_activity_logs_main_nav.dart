// lib/ui/activity_logs/view/web_activity_logs_main_view.dart

import 'package:flutter/material.dart';
import 'web_dashboard_screen.dart';
import 'web_substrate_screen.dart';
import 'web_alerts_screen.dart';
import 'web_reports_screen.dart';
import 'web_cycles_screen.dart';

/// Main web activity logs screen with tab navigation
class WebActivityLogsMainView extends StatefulWidget {
  final String? focusedMachineId;

  const WebActivityLogsMainView({
    super.key,
    this.focusedMachineId,
  });

  @override
  State<WebActivityLogsMainView> createState() =>
      _WebActivityLogsMainViewState();
}

class _WebActivityLogsMainViewState extends State<WebActivityLogsMainView> {
  String _selectedTab = 'all';

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWideScreen = screenWidth > 1200;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Activity Logs',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        automaticallyImplyLeading: false,
        centerTitle: false,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.teal.shade700, Colors.teal.shade900],
            ),
          ),
        ),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Batch Selector (Optional - can be added here)
            // const WebBatchSelector(),

            // Tab Navigation Bar
            Container(
              margin: EdgeInsets.fromLTRB(
                isWideScreen ? 32 : 24,
                16,
                isWideScreen ? 32 : 24,
                0,
              ),
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300, width: 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  _buildTabButton('all', 'All Activity', Icons.list),
                  _buildTabButton('substrate', 'Substrate', Icons.eco),
                  _buildTabButton('alerts', 'Alerts', Icons.warning),
                  _buildTabButton('reports', 'Reports', Icons.report_outlined),
                  _buildTabButton('cycles', 'Cycles', Icons.refresh),
                ],
              ),
            ),

            // Content Area
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(32, 16, 32, 32),
                child: Center(
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 1400),
                    child: _buildContent(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabButton(String value, String label, IconData icon) {
    final isSelected = _selectedTab == value;

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => setState(() => _selectedTab = value),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            decoration: BoxDecoration(
              color: isSelected ? Colors.teal : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 18,
                  color: isSelected ? Colors.white : Colors.grey[700],
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    label,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.grey[700],
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                      fontSize: 14,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    return switch (_selectedTab) {
      'all' => WebDashboardScreen(
        focusedMachineId: widget.focusedMachineId,
        onViewAll: (tab) => setState(() => _selectedTab = tab),
      ),
      'substrate' => WebSubstrateScreen(
        focusedMachineId: widget.focusedMachineId,
      ),
      'alerts' => WebAlertsScreen(focusedMachineId: widget.focusedMachineId),
      'reports' => WebReportsScreen(focusedMachineId: widget.focusedMachineId),
      'cycles' => WebCyclesScreen(focusedMachineId: widget.focusedMachineId),
      _ => WebDashboardScreen(
        focusedMachineId: widget.focusedMachineId,
        onViewAll: (tab) => setState(() => _selectedTab = tab),
      ),
    };
  }
}
