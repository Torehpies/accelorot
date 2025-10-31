// lib/frontend/operator/web/web_activity_logs_screen.dart
import 'package:flutter/material.dart';
import '../../../frontend/operator/activity_logs/components/all_activity_section.dart';
import '../../../frontend/operator/activity_logs/components/substrate_section.dart';
import '../../../frontend/operator/activity_logs/components/alerts_section.dart';
import '../../../frontend/operator/activity_logs/components/cycles_recom_section.dart';

class WebActivityLogsScreen extends StatefulWidget {

  
  const WebActivityLogsScreen({super.key, required bool shouldRefresh});

  @override
  State<WebActivityLogsScreen> createState() => _WebActivityLogsScreenState();
}

class _WebActivityLogsScreenState extends State<WebActivityLogsScreen> {
  String _selectedTab = 'all';

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWideScreen = screenWidth > 1200;
    final isMediumScreen = screenWidth > 800 && screenWidth <= 1200;

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
  actions: [], // <-- Now empty; notification icon removed
),
      body: SafeArea(
        child: Column(
          children: [
            // Tab Navigation Bar
            Container(
              margin: EdgeInsets.fromLTRB(
                isWideScreen ? 32 : 24,
                isWideScreen ? 24 : 16,
                isWideScreen ? 32 : 24,
                0,
              ),
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
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
                  _buildTabButton('cycles', 'Cycles', Icons.refresh),
                ],
              ),
            ),

            // Content Area
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(isWideScreen ? 32 : 24),
                child: Center(
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 1400),
                    child: _buildContent(isWideScreen, isMediumScreen),
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
              color: isSelected
                  ? Colors.teal
                  : Colors.transparent,
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
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
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

  Widget _buildContent(bool isWideScreen, bool isMediumScreen) {
    switch (_selectedTab) {
      case 'substrate':
        return _buildSubstrateView();
      case 'alerts':
        return _buildAlertsView();
      case 'cycles':
        return _buildCyclesView();
      case 'all':
      default:
        return isWideScreen
            ? _buildWideLayout()
            : isMediumScreen
                ? _buildMediumLayout()
                : _buildNarrowLayout();
    }
  }

  Widget _buildWideLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // All Activity Section (full width)
        const AllActivitySection(),
        const SizedBox(height: 24),
        
        // Substrate + Alerts side by side
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Expanded(child: SubstrateSection()),
            SizedBox(width: 24),
            Expanded(child: AlertsSection()),
          ],
        ),
        const SizedBox(height: 24),
        
        // Cycles & Recommendations (full width)
        const CyclesRecomSection(),
      ],
    );
  }

  Widget _buildMediumLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const AllActivitySection(),
        const SizedBox(height: 20),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Expanded(child: SubstrateSection()),
            SizedBox(width: 20),
            Expanded(child: AlertsSection()),
          ],
        ),
        const SizedBox(height: 20),
        const CyclesRecomSection(),
      ],
    );
  }

  Widget _buildNarrowLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: const [
        AllActivitySection(),
        SizedBox(height: 20),
        SubstrateSection(),
        SizedBox(height: 20),
        AlertsSection(),
        SizedBox(height: 20),
        CyclesRecomSection(),
      ],
    );
  }

  Widget _buildSubstrateView() {
    return Column(
      children: [
        _buildSectionHeader('Substrate Entries', Icons.eco, Colors.green),
        const SizedBox(height: 16),
        const SubstrateSection(),
      ],
    );
  }

  Widget _buildAlertsView() {
    return Column(
      children: [
        _buildSectionHeader('System Alerts', Icons.warning, Colors.orange),
        const SizedBox(height: 16),
        const AlertsSection(),
      ],
    );
  }

  Widget _buildCyclesView() {
    return Column(
      children: [
        _buildSectionHeader('Composting Cycles & Recommendations', Icons.refresh, Colors.blue),
        const SizedBox(height: 16),
        const CyclesRecomSection(),
      ],
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, MaterialColor color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.shade50, color.shade100],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.shade700,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: color.shade900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}