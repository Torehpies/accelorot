// lib/frontend/operator/screens/web_activity_logs_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_application_1/frontend/operator/activity_logs/web/web_batch_selector.dart';
import 'package:flutter_application_1/frontend/operator/activity_logs/web/web_all_activity_section.dart';
import 'package:flutter_application_1/frontend/operator/activity_logs/web/web_substrate_section.dart';
import 'package:flutter_application_1/frontend/operator/activity_logs/web/web_alerts_section.dart';
import 'package:flutter_application_1/frontend/operator/activity_logs/web/web_cycles_recom_section.dart';
import 'package:flutter_application_1/frontend/operator/activity_logs/web/web_reports_section.dart';
import 'package:flutter_application_1/frontend/operator/activity_logs/web/web_focused_view.dart';
import 'package:flutter_application_1/services/firestore_activity_service.dart';

// ===== Web Detail Panel Component =====
class WebDetailPanel extends StatelessWidget {
  final Widget child;
  final bool isVisible;

  const WebDetailPanel({
    super.key,
    required this.child,
    required this.isVisible,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: isVisible ? 500 : 0,
      decoration: BoxDecoration(  // ✅ Use BoxDecoration
        color: Colors.white,
        boxShadow: [  // ✅ boxShadow takes a List<BoxShadow>
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(-4, 0),
          ),
        ],
      ),
      child: isVisible
          ? child  // ✅ Simplified - no need for extra Container
          : const SizedBox(),
    );
  }
}

// ===== Main Screen =====
class WebActivityLogsScreen extends StatefulWidget {
  final bool shouldRefresh;

  const WebActivityLogsScreen({super.key, this.shouldRefresh = false});

  @override
  State<WebActivityLogsScreen> createState() => _WebActivityLogsScreenState();
}

class _WebActivityLogsScreenState extends State<WebActivityLogsScreen> {
  String selectedTab = 'all';
  bool isDetailPanelOpen = false;
  Widget? detailContent;

  void openDetailPanel(Widget content) {
    setState(() {
      detailContent = content;
      isDetailPanelOpen = true;
    });
  }

  void closeDetailPanel() {
    setState(() {
      isDetailPanelOpen = false;
      detailContent = null;
    });
  }

  // Fetch data methods
  Future<void> _openSubstratesFocusedView() async {
    final items = await FirestoreActivityService.getSubstrates();
    openDetailPanel(
      WebFocusedView(
        title: 'Substrate Logs',
        icon: Icons.eco,
        items: items,
        filterOptions: const ['All', 'Greens', 'Browns', 'Compost'],
        onClose: closeDetailPanel,
      ),
    );
  }

  Future<void> _openAlertsFocusedView() async {
    final items = await FirestoreActivityService.getAlerts();
    openDetailPanel(
      WebFocusedView(
        title: 'System Alerts',
        icon: Icons.warning,
        items: items,
        filterOptions: const ['All', 'Temp', 'Moisture', 'Air Quality'],
        onClose: closeDetailPanel,
      ),
    );
  }

  Future<void> _openReportsFocusedView() async {
    final items = await FirestoreActivityService.getReports();
    openDetailPanel(
      WebFocusedView(
        title: 'Reports',
        icon: Icons.report_outlined,
        items: items,
        filterOptions: const ['All', 'Maintenance Issue', 'Observation', 'Safety Concern'],
        onClose: closeDetailPanel,
      ),
    );
  }

  Future<void> _openCyclesFocusedView() async {
    final items = await FirestoreActivityService.getCyclesRecom();
    openDetailPanel(
      WebFocusedView(
        title: 'Composting Cycles',
        icon: Icons.auto_awesome,
        items: items,
        filterOptions: const ['All', 'Active', 'Completed', 'Paused'],
        onClose: closeDetailPanel,
      ),
    );
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
        actions: const [],
      ),
      body: SafeArea(
        child: Row(
          children: [
            // Main Content Area
            Expanded(
              child: Column(
                children: [
                  // Batch Selector (Fixed at top)
                  const WebBatchSelector(),

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
                        buildTabButton('reports', 'Reports', Icons.report_outlined),
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

            // Detail Panel (Side Panel)
            if (isWideScreen)
              WebDetailPanel(
                isVisible: isDetailPanelOpen,
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
      case 'reports':
        return buildReportsView();
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
        const WebAllActivitySection(),
        const SizedBox(height: 24),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: WebSubstrateSection(onViewAll: _openSubstratesFocusedView)),
            const SizedBox(width: 24),
            Expanded(child: WebAlertsSection(onViewAll: _openAlertsFocusedView)),
            const SizedBox(width: 24),
            Expanded(child: WebReportsSection(onViewAll: _openReportsFocusedView)),
          ],
        ),
        const SizedBox(height: 24),
        WebCyclesRecomSection(onViewAll: _openCyclesFocusedView),
      ],
    );
  }

  Widget buildMediumLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const WebAllActivitySection(),
        const SizedBox(height: 20),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: WebSubstrateSection(onViewAll: _openSubstratesFocusedView)),
            const SizedBox(width: 20),
            Expanded(child: WebAlertsSection(onViewAll: _openAlertsFocusedView)),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: WebReportsSection(onViewAll: _openReportsFocusedView)),
            const SizedBox(width: 20),
            Expanded(child: WebCyclesRecomSection(onViewAll: _openCyclesFocusedView)),
          ],
        ),
      ],
    );
  }

  Widget buildNarrowLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const WebAllActivitySection(),
        const SizedBox(height: 20),
        WebSubstrateSection(onViewAll: _openSubstratesFocusedView),
        const SizedBox(height: 20),
        WebAlertsSection(onViewAll: _openAlertsFocusedView),
        const SizedBox(height: 20),
        WebReportsSection(onViewAll: _openReportsFocusedView),
        const SizedBox(height: 20),
        WebCyclesRecomSection(onViewAll: _openCyclesFocusedView),
      ],
    );
  }

  Widget buildSubstrateView() {
    return Column(
      children: [
        buildSectionHeader('Substrate Entries', Icons.eco, Colors.green),
        const SizedBox(height: 16),
        WebSubstrateSection(onViewAll: _openSubstratesFocusedView),
      ],
    );
  }

  Widget buildAlertsView() {
    return Column(
      children: [
        buildSectionHeader('System Alerts', Icons.warning, Colors.orange),
        const SizedBox(height: 16),
        WebAlertsSection(onViewAll: _openAlertsFocusedView),
      ],
    );
  }

  Widget buildReportsView() {
    return Column(
      children: [
        buildSectionHeader('Reports', Icons.report_outlined, Colors.deepPurple),
        const SizedBox(height: 16),
        WebReportsSection(onViewAll: _openReportsFocusedView),
      ],
    );
  }

  Widget buildCyclesView() {
    return Column(
      children: [
        buildSectionHeader('Composting Cycles & Recommendations', Icons.refresh, Colors.blue),
        const SizedBox(height: 16),
        WebCyclesRecomSection(onViewAll: _openCyclesFocusedView),
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
