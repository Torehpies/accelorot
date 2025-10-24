// lib/web/admin/screens/web_machine_management.dart

import 'package:flutter/material.dart';

class WebMachineManagement extends StatefulWidget {
  const WebMachineManagement({super.key});

  @override
  State<WebMachineManagement> createState() => _WebMachineManagementState();
}

class _WebMachineManagementState extends State<WebMachineManagement> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _statusFilter = 'All';
  bool _isLoading = true;
  List<Map<String, dynamic>> _machines = [];
  String? _error;

  final List<String> _statusOptions = ['All', 'Active', 'Inactive', 'Maintenance'];

  @override
  void initState() {
    super.initState();
    _loadMachines();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadMachines() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // For now, we'll simulate machine data
      // In a real implementation, this would fetch from Firestore
      await Future.delayed(const Duration(seconds: 1)); // Simulate loading

      setState(() {
        _machines = [
          {
            'id': 'M001',
            'name': 'Compost Reactor Alpha',
            'location': 'Greenhouse A',
            'status': 'Active',
            'temperature': 28.5,
            'oxygen': 15.2,
            'moisture': 65.0,
            'lastMaintenance': DateTime.now().subtract(const Duration(days: 7)),
            'nextMaintenance': DateTime.now().add(const Duration(days: 23)),
          },
          {
            'id': 'M002',
            'name': 'Compost Reactor Beta',
            'location': 'Greenhouse B',
            'status': 'Active',
            'temperature': 26.8,
            'oxygen': 18.1,
            'moisture': 58.3,
            'lastMaintenance': DateTime.now().subtract(const Duration(days: 14)),
            'nextMaintenance': DateTime.now().add(const Duration(days: 16)),
          },
          {
            'id': 'M003',
            'name': 'Compost Reactor Gamma',
            'location': 'Greenhouse A',
            'status': 'Maintenance',
            'temperature': 0.0,
            'oxygen': 0.0,
            'moisture': 0.0,
            'lastMaintenance': DateTime.now().subtract(const Duration(days: 1)),
            'nextMaintenance': DateTime.now().add(const Duration(days: 29)),
          },
          {
            'id': 'M004',
            'name': 'Compost Reactor Delta',
            'location': 'Greenhouse C',
            'status': 'Inactive',
            'temperature': 0.0,
            'oxygen': 0.0,
            'moisture': 0.0,
            'lastMaintenance': DateTime.now().subtract(const Duration(days: 30)),
            'nextMaintenance': DateTime.now().add(const Duration(days: 0)),
          },
        ];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  List<Map<String, dynamic>> get _filteredMachines {
    return _machines.where((machine) {
      final matchesSearch = machine['name'].toString().toLowerCase().contains(_searchQuery) ||
                           machine['id'].toString().toLowerCase().contains(_searchQuery) ||
                           machine['location'].toString().toLowerCase().contains(_searchQuery);

      final matchesStatus = _statusFilter == 'All' || machine['status'] == _statusFilter;

      return matchesSearch && matchesStatus;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Machine Management',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Add Machine'),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Add Machine feature coming soon!')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadMachines,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Machine Overview',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.teal[800],
                    ),
                  ),
                ),
                _buildStatsCard('Total Machines', _machines.length.toString(), Colors.blue),
                const SizedBox(width: 16),
                _buildStatsCard('Active', _machines.where((m) => m['status'] == 'Active').length.toString(), Colors.green),
                const SizedBox(width: 16),
                _buildStatsCard('Maintenance', _machines.where((m) => m['status'] == 'Maintenance').length.toString(), Colors.orange),
              ],
            ),

            const SizedBox(height: 24),

            // Filters and Search
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Search machines...',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    DropdownButton<String>(
                      value: _statusFilter,
                      items: _statusOptions.map((status) {
                        return DropdownMenuItem<String>(
                          value: status,
                          child: Text(status),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _statusFilter = value!;
                        });
                      },
                      style: const TextStyle(color: Colors.black87),
                      underline: Container(
                        height: 2,
                        color: Colors.teal,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Machines Table
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                      ? _buildErrorState()
                      : _buildMachinesTable(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCard(String title, String value, Color color) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
          const SizedBox(height: 16),
          Text(
            'Error loading machines',
            style: TextStyle(color: Colors.red[700], fontSize: 18),
          ),
          const SizedBox(height: 8),
          Text(
            _error ?? '',
            style: TextStyle(color: Colors.red[600], fontSize: 14),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _loadMachines,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMachinesTable() {
    if (_filteredMachines.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No machines found',
              style: TextStyle(color: Colors.grey[600], fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              'Try adjusting your search or filter criteria',
              style: TextStyle(color: Colors.grey[500], fontSize: 14),
            ),
          ],
        ),
      );
    }

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: SingleChildScrollView(
        child: DataTable(
          columns: const [
            DataColumn(label: Text('ID', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Name', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Location', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Temperature (°C)', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Oxygen (%)', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Moisture (%)', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold))),
          ],
          rows: _filteredMachines.map((machine) {
            return DataRow(
              cells: [
                DataCell(Text(machine['id'], style: const TextStyle(fontWeight: FontWeight.w500))),
                DataCell(Text(machine['name'])),
                DataCell(Text(machine['location'])),
                DataCell(_buildStatusChip(machine['status'])),
                DataCell(Text(machine['temperature'].toStringAsFixed(1))),
                DataCell(Text(machine['oxygen'].toStringAsFixed(1))),
                DataCell(Text(machine['moisture'].toStringAsFixed(1))),
                DataCell(_buildActionButtons(machine)),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    switch (status) {
      case 'Active':
        color = Colors.green;
        break;
      case 'Maintenance':
        color = Colors.orange;
        break;
      case 'Inactive':
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildActionButtons(Map<String, dynamic> machine) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.visibility),
          tooltip: 'View Details',
          onPressed: () => _showMachineDetails(machine),
        ),
        IconButton(
          icon: const Icon(Icons.edit),
          tooltip: 'Edit Machine',
          onPressed: () => _editMachine(machine),
        ),
        IconButton(
          icon: const Icon(Icons.settings),
          tooltip: 'Configure',
          onPressed: () => _configureMachine(machine),
        ),
      ],
    );
  }

  void _showMachineDetails(Map<String, dynamic> machine) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Machine Details: ${machine['name']}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _detailRow('ID', machine['id']),
              _detailRow('Name', machine['name']),
              _detailRow('Location', machine['location']),
              _detailRow('Status', machine['status']),
              _detailRow('Temperature', '${machine['temperature']}°C'),
              _detailRow('Oxygen Level', '${machine['oxygen']}%'),
              _detailRow('Moisture Level', '${machine['moisture']}%'),
              _detailRow('Last Maintenance', _formatDate(machine['lastMaintenance'])),
              _detailRow('Next Maintenance', _formatDate(machine['nextMaintenance'])),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  void _editMachine(Map<String, dynamic> machine) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Edit ${machine['name']} - Feature coming soon!')),
    );
  }

  void _configureMachine(Map<String, dynamic> machine) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Configure ${machine['name']} - Feature coming soon!')),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }
}