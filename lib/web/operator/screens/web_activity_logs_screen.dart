// lib/frontend/operator/web/web_activity_logs_screen.dart
import 'package:flutter/material.dart';
import '../../../frontend/operator/activity_logs/web/web_all_activity_section.dart';
import '../../../frontend/operator/activity_logs/web/web_substrate_section.dart';
import '../../../frontend/operator/activity_logs/web/web_alerts_section.dart';
import '../../../frontend/operator/activity_logs/web/web_cycles_recom_section.dart';

// ===== Web Detail Panel Component (Embedded) =====
class WebDetailPanel extends StatelessWidget {
  
  final Widget child;
  final String title;
  final VoidCallback onClose;
  final bool isVisible;

  const WebDetailPanel({
    super.key,
    required this.child,
    required this.title,
    required this.onClose,
    required this.isVisible,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: isVisible ? 500 : 0,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black,
            blurRadius: 10,
            offset: const Offset(-4, 0),
          ),
        ],
      ),
      child: isVisible
          ? Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  decoration: const BoxDecoration(
                    border: Border(bottom: BorderSide(color: Colors.grey)),
                  ),
                  child: Row(
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: onClose,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: child,
                  ),
                ),
              ],
            )
          : const SizedBox(),
    );
  }
}

// ===== Main Screen =====
class WebActivityLogsScreen extends StatefulWidget {
  final bool shouldRefresh;
  final String? focusedMachineId;

  
  const WebActivityLogsScreen({
    super.key, 
    this.shouldRefresh = false,
    this.focusedMachineId,
  });

  @override
  State<WebActivityLogsScreen> createState() => _WebActivityLogsScreenState();
}

class _WebActivityLogsScreenState extends State<WebActivityLogsScreen> {
  String selectedTab = 'all'; // ✅ No leading underscore
  bool isDetailPanelOpen = false;
  Widget? detailContent;
  String detailTitle = '';

  void openDetailPanel(String title, Widget content) { // ✅ No leading underscore
    setState(() {
      detailTitle = title;
      detailContent = content;
      isDetailPanelOpen = true;
    });
  }

  void closeDetailPanel() { // ✅ No leading underscore
    setState(() {
      isDetailPanelOpen = false;
      detailContent = null;
    });
  }

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
        child: Row(
          children: [
            // Main Content Area
            Expanded(
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
                        buildTabButton('all', 'All Activity', Icons.list),
                        buildTabButton('substrate', 'Substrate', Icons.eco),
                        buildTabButton('alerts', 'Alerts', Icons.warning),
                        buildTabButton('cycles', 'Cycles', Icons.refresh),
                      ],
                    ),
                  ),

                  // Scrollable Content
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.all(isWideScreen ? 32 : 24),
                      child: Center(
                        child: Container(
                          constraints: const BoxConstraints(maxWidth: 1400),
                          child: buildContent(isWideScreen, isMediumScreen),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Detail Panel (Web/Desktop Only)
            if (isWideScreen)
              WebDetailPanel(
                isVisible: isDetailPanelOpen,
                title: detailTitle,
                onClose: closeDetailPanel,
                child: detailContent ?? const SizedBox(),
              ),
          ],
        ),
      ),
    );
  }

  Widget buildTabButton(String value, String label, IconData icon) {
    final isSelected = selectedTab == value;

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            if (isDetailPanelOpen) closeDetailPanel();
            setState(() => selectedTab = value);
          },
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

  Widget buildContent(bool isWideScreen, bool isMediumScreen) {
    switch (selectedTab) {
      case 'substrate':
        return buildSubstrateView();
      case 'alerts':
        return buildAlertsView();
      case 'cycles':
        return buildCyclesView();
      case 'all':
      default:
        return isWideScreen
            ? buildWideLayout()
            : isMediumScreen
                ? buildMediumLayout()
                : buildNarrowLayout();
    }
  }

  Widget buildWideLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        WebAllActivitySection(focusedMachineId: widget.focusedMachineId),
        const SizedBox(height: 24),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: WebSubstrateSection(focusedMachineId: widget.focusedMachineId)),
            const SizedBox(width: 24),
            Expanded(child: WebAlertsSection(focusedMachineId: widget.focusedMachineId)),
          ],
        ),
        const SizedBox(height: 24),
        WebCyclesRecomSection(focusedMachineId: widget.focusedMachineId),
      ],
    );
  }

  Widget buildMediumLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        WebAllActivitySection(focusedMachineId: widget.focusedMachineId),
        const SizedBox(height: 20),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: WebSubstrateSection(focusedMachineId: widget.focusedMachineId)),
            const SizedBox(width: 20),
            Expanded(child: WebAlertsSection(focusedMachineId: widget.focusedMachineId)),
          ],
        ),
        const SizedBox(height: 20),
        WebCyclesRecomSection(focusedMachineId: widget.focusedMachineId),
      ],
    );
  }

  Widget buildNarrowLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        WebAllActivitySection(focusedMachineId: widget.focusedMachineId),
        const SizedBox(height: 20),
        WebSubstrateSection(focusedMachineId: widget.focusedMachineId),
        const SizedBox(height: 20),
        WebAlertsSection(focusedMachineId: widget.focusedMachineId),
        const SizedBox(height: 20),
        WebCyclesRecomSection(focusedMachineId: widget.focusedMachineId),
      ],
    );
  }

  Widget buildSubstrateView() {
    return Column(
      children: [
        buildSectionHeader('Substrate Entries', Icons.eco, Colors.green),
        const SizedBox(height: 16),
        WebSubstrateSection(focusedMachineId: widget.focusedMachineId),
      ],
    );
  }

  Widget buildAlertsView() {
    return Column(
      children: [
        buildSectionHeader('System Alerts', Icons.warning, Colors.orange),
        const SizedBox(height: 16),
        WebAlertsSection(focusedMachineId: widget.focusedMachineId),
      ],
    );
  }

  Widget buildCyclesView() {
    return Column(
      children: [
        buildSectionHeader('Composting Cycles & Recommendations', Icons.refresh, Colors.blue),
        const SizedBox(height: 16),
        WebCyclesRecomSection(focusedMachineId: widget.focusedMachineId),
      ],
    );
  }

  Widget buildSectionHeader(String title, IconData icon, MaterialColor color) {
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
                fontSize: 13,
                color: color.shade900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}