// lib/frontend/operator/activity_logs/web/web_focused_view.dart
import 'package:flutter/material.dart';
import '../../activity_logs/models/activity_item.dart';

class WebFocusedView extends StatefulWidget {
  final String title;
  final IconData icon;
  final List<ActivityItem> items;
  final List<String> filterOptions;
  final VoidCallback onClose;

  const WebFocusedView({
    super.key,
    required this.title,
    required this.icon,
    required this.items,
    required this.filterOptions,
    required this.onClose,
  });

  @override
  State<WebFocusedView> createState() => _WebFocusedViewState();
}

class _WebFocusedViewState extends State<WebFocusedView> {
  String _selectedFilter = 'All';
  String _searchQuery = '';
  int _currentPage = 1;
  final int _itemsPerPage = 20;

  List<ActivityItem> get _filteredItems {
    var items = widget.items;

    // Apply filter
    if (_selectedFilter != 'All') {
      items = items.where((item) {
        if (item.isReport) {
          return item.reportType?.toLowerCase() == _selectedFilter.toLowerCase() ||
                 item.category.toLowerCase() == _selectedFilter.toLowerCase();
        }
        return item.category == _selectedFilter;
      }).toList();
    }

    // Apply search
    if (_searchQuery.isNotEmpty) {
      items = items.where((item) => item.matchesSearchQuery(_searchQuery)).toList();
    }

    return items;
  }

  List<ActivityItem> get _paginatedItems {
    final startIndex = (_currentPage - 1) * _itemsPerPage;
    final endIndex = startIndex + _itemsPerPage;
    return _filteredItems.sublist(
      startIndex,
      endIndex > _filteredItems.length ? _filteredItems.length : endIndex,
    );
  }

  int get _totalPages => (_filteredItems.length / _itemsPerPage).ceil();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.grey, width: 0.5)),
          ),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: widget.onClose,
                tooltip: 'Back',
              ),
              const SizedBox(width: 8),
              Icon(widget.icon, color: Colors.teal, size: 20),
              const SizedBox(width: 8),
              Text(
                widget.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.calendar_today, size: 18),
                onPressed: () {
                },
                tooltip: 'Filter by date',
              ),
            ],
          ),
        ),

        // Filter Chips
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            border: const Border(bottom: BorderSide(color: Colors.grey, width: 0.5)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Filter:',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: widget.filterOptions.map((filter) {
                  final isSelected = _selectedFilter == filter;
                  return FilterChip(
                    label: Text(filter),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedFilter = filter;
                        _currentPage = 1; // Reset to first page
                      });
                    },
                    backgroundColor: Colors.white,
                    selectedColor: Colors.teal,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.black87,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      fontSize: 12,
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),

        // Search Bar
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search...',
              prefixIcon: const Icon(Icons.search, size: 20),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              filled: true,
              fillColor: Colors.white,
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
                _currentPage = 1; // Reset to first page
              });
            },
          ),
        ),

        // Results Count
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Showing ${_filteredItems.isEmpty ? 0 : ((_currentPage - 1) * _itemsPerPage) + 1}-${_paginatedItems.length + ((_currentPage - 1) * _itemsPerPage)} of ${_filteredItems.length}',
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ),

        const SizedBox(height: 8),

        // Content List
        Expanded(
          child: _filteredItems.isEmpty
              ? Center(
                  child: Text(
                    'No results found',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _paginatedItems.length,
                  itemBuilder: (context, index) {
                    final item = _paginatedItems[index];
                    return _buildActivityCard(item);
                  },
                ),
        ),

        // Pagination
        if (_totalPages > 1)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: Colors.grey, width: 0.5)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: _currentPage > 1
                      ? () => setState(() => _currentPage--)
                      : null,
                ),
                const SizedBox(width: 8),
                ...List.generate(
                  _totalPages > 5 ? 5 : _totalPages,
                  (index) {
                    int pageNumber;
                    if (_totalPages <= 5) {
                      pageNumber = index + 1;
                    } else if (_currentPage <= 3) {
                      pageNumber = index + 1;
                    } else if (_currentPage >= _totalPages - 2) {
                      pageNumber = _totalPages - 4 + index;
                    } else {
                      pageNumber = _currentPage - 2 + index;
                    }

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: TextButton(
                        onPressed: () => setState(() => _currentPage = pageNumber),
                        style: TextButton.styleFrom(
                          backgroundColor: _currentPage == pageNumber
                              ? Colors.teal
                              : Colors.grey[200],
                          minimumSize: const Size(40, 40),
                          padding: EdgeInsets.zero,
                        ),
                        child: Text(
                          '$pageNumber',
                          style: TextStyle(
                            color: _currentPage == pageNumber ? Colors.white : Colors.black87,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: _currentPage < _totalPages
                      ? () => setState(() => _currentPage++)
                      : null,
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildActivityCard(ActivityItem item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row: Icon + Title + Status + Time
            Row(
              children: [
                Icon(item.icon, size: 20, color: Colors.teal),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    item.title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: item.statusColorValue,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  item.value,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Description
            Text(
              item.description,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.black87,
                height: 1.4,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: 8),

            // Divider
            Divider(height: 1, color: Colors.grey.shade300),

            const SizedBox(height: 8),

            // Metadata Row
            Row(
              children: [
                if (item.machineId != null) ...[
                  const Icon(Icons.precision_manufacturing, size: 12, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    item.machineName ?? item.machineId!,
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                  const SizedBox(width: 12),
                ],
                if (item.batchId != null) ...[
                  const Icon(Icons.inventory_2, size: 12, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    'Batch: ${item.batchId}',
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                  const SizedBox(width: 12),
                ],
                if (item.operatorName != null) ...[
                  const Icon(Icons.person, size: 12, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    item.operatorName!,
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                ],
                const Spacer(),
                Text(
                  item.formattedTimestamp,
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}