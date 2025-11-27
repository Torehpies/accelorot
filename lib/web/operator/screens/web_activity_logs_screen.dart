// lib/frontend/operator/screens/web_activity_logs_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_application_1/ui/activity_logs/web/web_batch_selector.dart';
import 'package:flutter_application_1/ui/activity_logs/web/web_all_activity_section.dart';
import 'package:flutter_application_1/ui/activity_logs/web/web_substrate_section.dart';
import 'package:flutter_application_1/ui/activity_logs/web/web_alerts_section.dart';
import 'package:flutter_application_1/ui/activity_logs/web/web_cycles_recom_section.dart';
import 'package:flutter_application_1/ui/activity_logs/web/web_reports_section.dart';
import 'package:flutter_application_1/ui/activity_logs/widgets/date_filter_button.dart';
import 'package:flutter_application_1/data/models/activity_item.dart';
import 'package:flutter_application_1/services/firestore_activity_service.dart';

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
  String selectedTab = 'all';

  // Substrate state
  String _substrateFilter = 'All';
  String _substrateSearch = '';
  int _substratePage = 1;
  DateFilterRange _substrateDateFilter = DateFilterRange(
    type: DateFilterType.none,
  );
  final TextEditingController _substrateSearchController =
      TextEditingController();

  // Alerts state
  String _alertsFilter = 'All';
  String _alertsSearch = '';
  int _alertsPage = 1;
  DateFilterRange _alertsDateFilter = DateFilterRange(
    type: DateFilterType.none,
  );
  final TextEditingController _alertsSearchController = TextEditingController();

  // Reports state
  String _reportsFilter = 'All';
  String _reportsSearch = '';
  int _reportsPage = 1;
  DateFilterRange _reportsDateFilter = DateFilterRange(
    type: DateFilterType.none,
  );
  final TextEditingController _reportsSearchController =
      TextEditingController();

  // Cycles state
  String _cyclesFilter = 'All';
  String _cyclesSearch = '';
  int _cyclesPage = 1;
  DateFilterRange _cyclesDateFilter = DateFilterRange(
    type: DateFilterType.none,
  );
  final TextEditingController _cyclesSearchController = TextEditingController();

  final int _itemsPerPage = 10;

  @override
  void dispose() {
    _substrateSearchController.dispose();
    _alertsSearchController.dispose();
    _reportsSearchController.dispose();
    _cyclesSearchController.dispose();
    super.dispose();
  }

  void _resetAllFilters() {
    setState(() {
      _substrateFilter = 'All';
      _substrateSearch = '';
      _substratePage = 1;
      _substrateDateFilter = DateFilterRange(type: DateFilterType.none);
      _substrateSearchController.clear();

      _alertsFilter = 'All';
      _alertsSearch = '';
      _alertsPage = 1;
      _alertsDateFilter = DateFilterRange(type: DateFilterType.none);
      _alertsSearchController.clear();

      _reportsFilter = 'All';
      _reportsSearch = '';
      _reportsPage = 1;
      _reportsDateFilter = DateFilterRange(type: DateFilterType.none);
      _reportsSearchController.clear();

      _cyclesFilter = 'All';
      _cyclesSearch = '';
      _cyclesPage = 1;
      _cyclesDateFilter = DateFilterRange(type: DateFilterType.none);
      _cyclesSearchController.clear();
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
        actions: [
          if (selectedTab != 'all') ...[
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: _buildDateFilter(),
            ),
          ],
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Batch Selector (Fixed at top)
            const WebBatchSelector(),

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
                padding: const EdgeInsets.fromLTRB(32, 16, 32, 32),
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
    );
  }

  Widget _buildDateFilter() {
    ValueChanged<DateFilterRange> onChanged;

    switch (selectedTab) {
      case 'substrate':
        onChanged = (filter) => setState(() {
          _substrateDateFilter = filter;
          _substratePage = 1;
        });
        break;
      case 'alerts':
        onChanged = (filter) => setState(() {
          _alertsDateFilter = filter;
          _alertsPage = 1;
        });
        break;
      case 'reports':
        onChanged = (filter) => setState(() {
          _reportsDateFilter = filter;
          _reportsPage = 1;
        });
        break;
      case 'cycles':
        onChanged = (filter) => setState(() {
          _cyclesDateFilter = filter;
          _cyclesPage = 1;
        });
        break;
      default:
        return const SizedBox();
    }

    return DateFilterButton(onFilterChanged: onChanged);
  }

  Widget buildTabButton(String value, String label, IconData icon) {
    final isSelected = selectedTab == value;

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            setState(() {
              if (value == 'all') {
                _resetAllFilters();
              }
              selectedTab = value;
            });
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

  Widget buildContent(bool isWideScreen, bool isMediumScreen) {
    switch (selectedTab) {
      case 'substrate':
        return buildSubstrateFullView();
      case 'alerts':
        return buildAlertsFullView();
      case 'reports':
        return buildReportsFullView();
      case 'cycles':
        return buildCyclesFullView();
      case 'all':
      default:
        return isWideScreen
            ? buildWideLayout()
            : isMediumScreen
            ? buildMediumLayout()
            : buildNarrowLayout();
    }
  }

  // ===== All Activity Layouts =====
  Widget buildWideLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        WebAllActivitySection(focusedMachineId: widget.focusedMachineId),
        const SizedBox(height: 24),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: WebSubstrateSection(
                focusedMachineId: widget.focusedMachineId,
                onViewAll: () => setState(() => selectedTab = 'substrate'),
              ),
            ),
            const SizedBox(width: 24),
            Expanded(
              child: WebAlertsSection(
                focusedMachineId: widget.focusedMachineId,
                onViewAll: () => setState(() => selectedTab = 'alerts'),
              ),
            ),
            const SizedBox(width: 24),
            Expanded(
              child: WebReportsSection(
                focusedMachineId: widget.focusedMachineId,
                onViewAll: () => setState(() => selectedTab = 'reports'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        WebCyclesRecomSection(
          focusedMachineId: widget.focusedMachineId,
          onViewAll: () => setState(() => selectedTab = 'cycles'),
        ),
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
            Expanded(
              child: WebSubstrateSection(
                focusedMachineId: widget.focusedMachineId,
                onViewAll: () => setState(() => selectedTab = 'substrate'),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: WebAlertsSection(
                focusedMachineId: widget.focusedMachineId,
                onViewAll: () => setState(() => selectedTab = 'alerts'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: WebReportsSection(
                focusedMachineId: widget.focusedMachineId,
                onViewAll: () => setState(() => selectedTab = 'reports'),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: WebCyclesRecomSection(
                focusedMachineId: widget.focusedMachineId,
                onViewAll: () => setState(() => selectedTab = 'cycles'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget buildNarrowLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        WebAllActivitySection(focusedMachineId: widget.focusedMachineId),
        const SizedBox(height: 20),
        WebSubstrateSection(
          focusedMachineId: widget.focusedMachineId,
          onViewAll: () => setState(() => selectedTab = 'substrate'),
        ),
        const SizedBox(height: 20),
        WebAlertsSection(
          focusedMachineId: widget.focusedMachineId,
          onViewAll: () => setState(() => selectedTab = 'alerts'),
        ),
        const SizedBox(height: 20),
        WebReportsSection(
          focusedMachineId: widget.focusedMachineId,
          onViewAll: () => setState(() => selectedTab = 'reports'),
        ),
        const SizedBox(height: 20),
        WebCyclesRecomSection(
          focusedMachineId: widget.focusedMachineId,
          onViewAll: () => setState(() => selectedTab = 'cycles'),
        ),
      ],
    );
  }

  // ===== Full View Builders =====
  Widget buildSubstrateFullView() {
    return FutureBuilder<List<ActivityItem>>(
      future: FirestoreActivityService.getSubstrates(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error loading substrates',
              style: TextStyle(color: Colors.grey[600]),
            ),
          );
        }

        final allItems = snapshot.data ?? [];
        final filteredItems = _filterItems(
          allItems,
          _substrateFilter,
          _substrateSearch,
          _substrateDateFilter,
        );

        return buildFullViewContent(
          items: filteredItems,
          filterOptions: const ['All', 'Greens', 'Browns', 'Compost'],
          currentFilter: _substrateFilter,
          currentSearch: _substrateSearch,
          currentPage: _substratePage,
          searchController: _substrateSearchController,
          onFilterChanged: (filter) => setState(() {
            _substrateFilter = filter;
            _substratePage = 1;
          }),
          onSearchChanged: (search) => setState(() {
            _substrateSearch = search;
            _substratePage = 1;
          }),
          onPageChanged: (page) => setState(() => _substratePage = page),
        );
      },
    );
  }

  Widget buildAlertsFullView() {
    return FutureBuilder<List<ActivityItem>>(
      future: FirestoreActivityService.getAlerts(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error loading alerts',
              style: TextStyle(color: Colors.grey[600]),
            ),
          );
        }

        final allItems = snapshot.data ?? [];
        final filteredItems = _filterItems(
          allItems,
          _alertsFilter,
          _alertsSearch,
          _alertsDateFilter,
        );

        return buildFullViewContent(
          items: filteredItems,
          filterOptions: const ['All', 'Temp', 'Moisture', 'Air Quality'],
          currentFilter: _alertsFilter,
          currentSearch: _alertsSearch,
          currentPage: _alertsPage,
          searchController: _alertsSearchController,
          onFilterChanged: (filter) => setState(() {
            _alertsFilter = filter;
            _alertsPage = 1;
          }),
          onSearchChanged: (search) => setState(() {
            _alertsSearch = search;
            _alertsPage = 1;
          }),
          onPageChanged: (page) => setState(() => _alertsPage = page),
        );
      },
    );
  }

  Widget buildReportsFullView() {
    return FutureBuilder<List<ActivityItem>>(
      future: FirestoreActivityService.getReports(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error loading reports',
              style: TextStyle(color: Colors.grey[600]),
            ),
          );
        }

        final allItems = snapshot.data ?? [];
        final filteredItems = _filterItems(
          allItems,
          _reportsFilter,
          _reportsSearch,
          _reportsDateFilter,
        );

        return buildFullViewContent(
          items: filteredItems,
          filterOptions: const [
            'All',
            'Maintenance Issue',
            'Observation',
            'Safety Concern',
          ],
          currentFilter: _reportsFilter,
          currentSearch: _reportsSearch,
          currentPage: _reportsPage,
          searchController: _reportsSearchController,
          onFilterChanged: (filter) => setState(() {
            _reportsFilter = filter;
            _reportsPage = 1;
          }),
          onSearchChanged: (search) => setState(() {
            _reportsSearch = search;
            _reportsPage = 1;
          }),
          onPageChanged: (page) => setState(() => _reportsPage = page),
        );
      },
    );
  }

  Widget buildCyclesFullView() {
    return FutureBuilder<List<ActivityItem>>(
      future: FirestoreActivityService.getCyclesRecom(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error loading cycles',
              style: TextStyle(color: Colors.grey[600]),
            ),
          );
        }

        final allItems = snapshot.data ?? [];
        final filteredItems = _filterItems(
          allItems,
          _cyclesFilter,
          _cyclesSearch,
          _cyclesDateFilter,
        );

        return buildFullViewContent(
          items: filteredItems,
          filterOptions: const ['All', 'Active', 'Completed', 'Paused'],
          currentFilter: _cyclesFilter,
          currentSearch: _cyclesSearch,
          currentPage: _cyclesPage,
          searchController: _cyclesSearchController,
          onFilterChanged: (filter) => setState(() {
            _cyclesFilter = filter;
            _cyclesPage = 1;
          }),
          onSearchChanged: (search) => setState(() {
            _cyclesSearch = search;
            _cyclesPage = 1;
          }),
          onPageChanged: (page) => setState(() => _cyclesPage = page),
        );
      },
    );
  }

  // ===== Filter Logic =====
  List<ActivityItem> _filterItems(
    List<ActivityItem> items,
    String filter,
    String search,
    DateFilterRange dateFilter,
  ) {
    var filtered = items;

    // Apply category filter
    if (filter != 'All') {
      filtered = filtered.where((item) {
        if (item.isReport) {
          return item.reportType?.toLowerCase() ==
                  filter.toLowerCase().replaceAll(' ', '_') ||
              item.category.toLowerCase() == filter.toLowerCase();
        }
        return item.category.toLowerCase() == filter.toLowerCase();
      }).toList();
    }

    // Apply search filter
    if (search.isNotEmpty) {
      filtered = filtered
          .where((item) => item.matchesSearchQuery(search))
          .toList();
    }

    // Apply date filter
    if (dateFilter.isActive &&
        dateFilter.startDate != null &&
        dateFilter.endDate != null) {
      filtered = filtered.where((item) {
        return item.timestamp.isAfter(dateFilter.startDate!) &&
            item.timestamp.isBefore(dateFilter.endDate!);
      }).toList();
    }

    return filtered;
  }

  // ===== Full View Content Builder =====
  Widget buildFullViewContent({
    required List<ActivityItem> items,
    required List<String> filterOptions,
    required String currentFilter,
    required String currentSearch,
    required int currentPage,
    required TextEditingController searchController,
    required ValueChanged<String> onFilterChanged,
    required ValueChanged<String> onSearchChanged,
    required ValueChanged<int> onPageChanged,
  }) {
    final totalPages = items.isEmpty
        ? 1
        : (items.length / _itemsPerPage).ceil();
    final startIndex = (currentPage - 1) * _itemsPerPage;
    final endIndex = startIndex + _itemsPerPage;
    final paginatedItems = items.sublist(
      startIndex,
      endIndex > items.length ? items.length : endIndex,
    );

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Filter Chips (Full Width)
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: filterOptions.map((filter) {
                final isSelected = currentFilter == filter;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => onFilterChanged(filter),
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 10,
                            horizontal: 8,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.teal
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            filter,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : Colors.grey[700],
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 16),

          // Search Bar (40% width)
          Row(
            children: [
              Expanded(
                flex: 4,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: TextField(
                    controller: searchController,
                    onChanged: onSearchChanged,
                    decoration: InputDecoration(
                      hintText: 'Search activities...',
                      hintStyle: TextStyle(color: Colors.grey.shade400),
                      prefixIcon: Icon(
                        Icons.search,
                        color: Colors.grey.shade600,
                      ),
                      suffixIcon: currentSearch.isNotEmpty
                          ? IconButton(
                              icon: Icon(
                                Icons.clear,
                                color: Colors.grey.shade600,
                              ),
                              onPressed: () {
                                searchController.clear();
                                onSearchChanged('');
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                  ),
                ),
              ),
              const Spacer(flex: 6),
            ],
          ),

          const SizedBox(height: 12),

          // Results Count
          Text(
            items.isEmpty
                ? 'No results found'
                : 'Showing ${items.isEmpty ? 0 : startIndex + 1}-${startIndex + paginatedItems.length} of ${items.length}',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 12),

          const Divider(height: 1),

          const SizedBox(height: 8),

          // Activity Cards
          if (items.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(48),
                child: Text(
                  'No activities found',
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: paginatedItems.length,
              separatorBuilder: (context, index) =>
                  const Divider(height: 1, color: Colors.grey),
              itemBuilder: (context, index) {
                final item = paginatedItems[index];
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  leading: CircleAvatar(
                    radius: 16,
                    backgroundColor: item.statusColorValue,
                    child: Icon(item.icon, color: Colors.white, size: 16),
                  ),
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          item.title,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF302F2F),
                          ),
                        ),
                      ),
                      Text(
                        item.value,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  subtitle: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          '${item.category} • Machine: ${item.machineName ?? item.machineId ?? '-'} | By: ${item.operatorName ?? '-'}',
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                      Text(
                        item.formattedTimestamp,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),

          // Pagination
          if (totalPages > 1) ...[
            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: currentPage > 1
                      ? () => onPageChanged(currentPage - 1)
                      : null,
                ),
                const SizedBox(width: 8),
                ...List.generate(totalPages > 5 ? 5 : totalPages, (index) {
                  int pageNumber;
                  if (totalPages <= 5) {
                    pageNumber = index + 1;
                  } else if (currentPage <= 3) {
                    pageNumber = index + 1;
                  } else if (currentPage >= totalPages - 2) {
                    pageNumber = totalPages - 4 + index;
                  } else {
                    pageNumber = currentPage - 2 + index;
                  }

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: TextButton(
                      onPressed: () => onPageChanged(pageNumber),
                      style: TextButton.styleFrom(
                        backgroundColor: currentPage == pageNumber
                            ? Colors.teal
                            : Colors.grey[200],
                        minimumSize: const Size(40, 40),
                        padding: EdgeInsets.zero,
                      ),
                      child: Text(
                        '$pageNumber',
                        style: TextStyle(
                          color: currentPage == pageNumber
                              ? Colors.white
                              : Colors.black87,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                }),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: currentPage < totalPages
                      ? () => onPageChanged(currentPage + 1)
                      : null,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
