import 'package:flutter/material.dart';
import '../filterable_card_list_container.dart';
import 'compost_card.dart';
import 'machine_status_card.dart';
import '../../themes/app_theme.dart';

/// Example usage of FilterableCardListContainer with CompostCard
class CompostListExample extends StatefulWidget {
  const CompostListExample({super.key});

  @override
  State<CompostListExample> createState() => _CompostListExampleState();
}

class _CompostListExampleState extends State<CompostListExample> {
  String _selectedFilter = 'All';
  String _searchQuery = '';

  // Sample data
  final List<Map<String, dynamic>> _allCompostItems = [
    {
      'title': 'Compost',
      'icon': Icons.recycling,
      'iconColor': Color(0xFF6B7280),
      'machine': 'MACHINE_101',
      'batch': 'BATCH_1',
      'user': 'Magdalmmaculada',
      'dateTime': '10-225-2025, 2:30 PM',
      'weight': '20.0kg',
      'category': 'Compost',
    },
    {
      'title': 'Fruit Trees',
      'icon': Icons.eco,
      'iconColor': Color(0xFF4CAF50),
      'machine': 'MACHINE_101',
      'batch': 'BATCH_1',
      'user': 'Magdalmmaculada',
      'dateTime': '10-225-2025, 2:30 PM',
      'weight': '20.0kg',
      'category': 'Greens',
    },
    {
      'title': 'Compost',
      'icon': Icons.recycling,
      'iconColor': Color(0xFF6B7280),
      'machine': 'MACHINE_101',
      'batch': 'BATCH_1',
      'user': 'Magdalmmaculada',
      'dateTime': '10-225-2025, 2:30 PM',
      'weight': '20.0kg',
      'category': 'Compost',
    },
  ];

  List<Map<String, dynamic>> get _filteredItems {
    var items = _allCompostItems;

    // Filter by category
    if (_selectedFilter != 'All') {
      items = items
          .where((item) => item['category'] == _selectedFilter)
          .toList();
    }

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      items = items
          .where((item) =>
              item['title']
                  .toString()
                  .toLowerCase()
                  .contains(_searchQuery.toLowerCase()) ||
              item['machine']
                  .toString()
                  .toLowerCase()
                  .contains(_searchQuery.toLowerCase()))
          .toList();
    }

    return items;
  }

  @override
  Widget build(BuildContext context) {
    final cards = _filteredItems
        .map((item) => CompostCard(
              title: item['title'],
              icon: item['icon'],
              iconColor: item['iconColor'],
              machineName: item['machine'],
              batchName: item['batch'],
              userName: item['user'],
              dateTime: item['dateTime'],
              weight: item['weight'],
              onTap: () {
                // Handle card tap
              },
            ))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Compost Items'),
        backgroundColor: AppColors.background,
      ),
      body: FilterableCardListContainer(
        filters: const ['All', 'Greens', 'Browns', 'Compost'],
        selectedFilter: _selectedFilter,
        onFilterChanged: (filter) {
          setState(() {
            _selectedFilter = filter;
          });
        },
        searchQuery: _searchQuery,
        onSearchChanged: (query) {
          setState(() {
            _searchQuery = query;
          });
        },
        cards: cards,
        searchHint: 'Search...',
      ),
    );
  }
}

/// Example usage of FilterableCardListContainer with MachineStatusCard
class MachineListExample extends StatefulWidget {
  const MachineListExample({super.key});

  @override
  State<MachineListExample> createState() => _MachineListExampleState();
}

class _MachineListExampleState extends State<MachineListExample> {
  String _selectedFilter = 'All';
  String _searchQuery = '';

  // Sample data
  final List<Map<String, dynamic>> _allMachines = [
    {
      'name': 'MACHINE_101',
      'id': '01',
      'assignedUser': 'All Team Members',
      'dateCreated': 'Oct-5-2025',
      'status': 'Active',
      'statusColor': Color(0xFF4CAF50),
      'category': 'Active',
    },
    {
      'name': 'MACHINE_101',
      'id': '01',
      'assignedUser': 'All Team Members',
      'dateCreated': 'Oct-5-2025',
      'status': 'Inactive',
      'statusColor': Color(0xFFFFA726),
      'category': 'Inactive',
    },
    {
      'name': 'MACHINE_101',
      'id': '01',
      'assignedUser': 'All Team Members',
      'dateCreated': 'Oct-5-2025',
      'status': 'Archived',
      'statusColor': Color(0xFFEF5350),
      'category': 'Archived',
    },
  ];

  List<Map<String, dynamic>> get _filteredMachines {
    var machines = _allMachines;

    // Filter by status
    if (_selectedFilter != 'All') {
      machines = machines
          .where((machine) => machine['category'] == _selectedFilter)
          .toList();
    }

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      machines = machines
          .where((machine) =>
              machine['name']
                  .toString()
                  .toLowerCase()
                  .contains(_searchQuery.toLowerCase()) ||
              machine['id']
                  .toString()
                  .toLowerCase()
                  .contains(_searchQuery.toLowerCase()))
          .toList();
    }

    return machines;
  }

  @override
  Widget build(BuildContext context) {
    final cards = _filteredMachines
        .map((machine) => MachineStatusCard(
              machineName: machine['name'],
              machineId: machine['id'],
              assignedUser: machine['assignedUser'],
              dateCreated: machine['dateCreated'],
              status: machine['status'],
              statusColor: machine['statusColor'],
              onTap: () {
                // Handle card tap
              },
            ))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Machines'),
        backgroundColor: AppColors.background,
      ),
      body: FilterableCardListContainer(
        filters: const ['All', 'Active', 'Inactive', 'Archived'],
        selectedFilter: _selectedFilter,
        onFilterChanged: (filter) {
          setState(() {
            _selectedFilter = filter;
          });
        },
        searchQuery: _searchQuery,
        onSearchChanged: (query) {
          setState(() {
            _searchQuery = query;
          });
        },
        cards: cards,
        searchHint: 'Search...',
        // Custom filter colors for different statuses
        filterColors: const {
          'All': Color(0xFF6B7280),
          'Active': Color(0xFF4CAF50),
          'Inactive': Color(0xFFFFA726),
          'Archived': Color(0xFFEF5350),
        },
      ),
    );
  }
}
