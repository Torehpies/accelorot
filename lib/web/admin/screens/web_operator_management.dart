// lib/web/admin/screens/web_userlist_screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class WebUserListScreen extends StatefulWidget {
  const WebUserListScreen({super.key});

  @override
  State<WebUserListScreen> createState() => _WebUserListScreenState();
}

class _WebUserListScreenState extends State<WebUserListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _roleFilter = 'All';
  String _statusFilter = 'All';
  bool _isLoading = true;
  List<Map<String, dynamic>> _users = [];
  String? _error;

  final List<String> _roleOptions = ['All', 'Admin', 'Operator', 'User'];
  final List<String> _statusOptions = ['All', 'Active', 'Pending', 'Suspended'];

  @override
  void initState() {
    super.initState();
    _loadUsers();
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

  Future<void> _loadUsers() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final usersSnapshot = await FirebaseFirestore.instance.collection('users').get();

      final users = usersSnapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'email': data['email'] ?? '',
          'firstname': data['firstname'] ?? '',
          'lastname': data['lastname'] ?? '',
          'role': data['role'] ?? 'User',
          'status': data['status'] ?? 'Active',
          'createdAt': data['createdAt'] as Timestamp?,
          'lastLogin': data['lastLogin'] as Timestamp?,
          'phone': data['phone'] ?? '',
        };
      }).toList();

      setState(() {
        _users = users;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  List<Map<String, dynamic>> get _filteredUsers {
    return _users.where((user) {
      final fullName = '${user['firstname']} ${user['lastname']}'.toLowerCase();
      final email = user['email'].toString().toLowerCase();

      final matchesSearch = fullName.contains(_searchQuery) ||
                           email.contains(_searchQuery) ||
                           user['id'].toString().toLowerCase().contains(_searchQuery);

      final matchesRole = _roleFilter == 'All' || user['role'] == _roleFilter;
      final matchesStatus = _statusFilter == 'All' || user['status'] == _statusFilter;

      return matchesSearch && matchesRole && matchesStatus;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'User Management',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: ElevatedButton.icon(
              icon: const Icon(Icons.person_add),
              label: const Text('Add User'),
              onPressed: () => _showAddUserDialog(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadUsers,
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
                    'User Directory',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.teal[800],
                    ),
                  ),
                ),
                _buildStatsCard('Total Users', _users.length.toString(), Colors.blue),
                const SizedBox(width: 16),
                _buildStatsCard('Active', _users.where((u) => u['status'] == 'Active').length.toString(), Colors.green),
                const SizedBox(width: 16),
                _buildStatsCard('Admins', _users.where((u) => u['role'] == 'Admin').length.toString(), Colors.purple),
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
                          hintText: 'Search users by name or email...',
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
                      value: _roleFilter,
                      items: _roleOptions.map((role) {
                        return DropdownMenuItem<String>(
                          value: role,
                          child: Text(role),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _roleFilter = value!;
                        });
                      },
                      style: const TextStyle(color: Colors.black87),
                      underline: Container(
                        height: 2,
                        color: Colors.teal,
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

            // Users Table
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                      ? _buildErrorState()
                      : _buildUsersTable(),
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
            'Error loading users',
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
            onPressed: _loadUsers,
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

  Widget _buildUsersTable() {
    if (_filteredUsers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No users found',
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
            DataColumn(label: Text('Avatar', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Name', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Email', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Role', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Last Login', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold))),
          ],
          rows: _filteredUsers.map((user) {
            final fullName = '${user['firstname']} ${user['lastname']}'.trim();
            final initials = ((user['firstname']?[0] ?? '') + (user['lastname']?[0] ?? '')).toUpperCase();

            return DataRow(
              cells: [
                DataCell(CircleAvatar(
                  backgroundColor: Colors.teal[100],
                  child: Text(
                    initials.isNotEmpty ? initials : '?',
                    style: TextStyle(color: Colors.teal[800], fontWeight: FontWeight.bold),
                  ),
                )),
                DataCell(Text(fullName.isNotEmpty ? fullName : 'Unknown')),
                DataCell(Text(user['email'] ?? '')),
                DataCell(_buildRoleChip(user['role'])),
                DataCell(_buildStatusChip(user['status'])),
                DataCell(Text(_formatTimestamp(user['lastLogin']))),
                DataCell(_buildActionButtons(user)),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildRoleChip(String role) {
    Color color;
    switch (role) {
      case 'Admin':
        color = Colors.purple;
        break;
      case 'Operator':
        color = Colors.blue;
        break;
      case 'User':
        color = Colors.green;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        role,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w500,
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
      case 'Pending':
        color = Colors.orange;
        break;
      case 'Suspended':
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
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

  Widget _buildActionButtons(Map<String, dynamic> user) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.visibility),
          tooltip: 'View Details',
          onPressed: () => _showUserDetails(user),
        ),
        IconButton(
          icon: const Icon(Icons.edit),
          tooltip: 'Edit User',
          onPressed: () => _editUser(user),
        ),
        IconButton(
          icon: const Icon(Icons.admin_panel_settings),
          tooltip: 'Change Role',
          onPressed: () => _changeUserRole(user),
        ),
        IconButton(
          icon: user['status'] == 'Suspended' ? const Icon(Icons.check_circle) : const Icon(Icons.block),
          tooltip: user['status'] == 'Suspended' ? 'Activate User' : 'Suspend User',
          onPressed: () => _toggleUserStatus(user),
        ),
      ],
    );
  }

  void _showUserDetails(Map<String, dynamic> user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('User Details: ${user['firstname']} ${user['lastname']}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _detailRow('ID', user['id']),
              _detailRow('First Name', user['firstname']),
              _detailRow('Last Name', user['lastname']),
              _detailRow('Email', user['email']),
              _detailRow('Phone', user['phone']),
              _detailRow('Role', user['role']),
              _detailRow('Status', user['status']),
              _detailRow('Created', _formatTimestamp(user['createdAt'])),
              _detailRow('Last Login', _formatTimestamp(user['lastLogin'])),
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

  void _showAddUserDialog() {
    // TODO: Implement add user dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Add User feature coming soon!')),
    );
  }

  void _editUser(Map<String, dynamic> user) {
    // TODO: Implement edit user dialog
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Edit ${user['firstname']} ${user['lastname']} - Feature coming soon!')),
    );
  }

  void _changeUserRole(Map<String, dynamic> user) {
    // TODO: Implement role change dialog
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Change role for ${user['firstname']} ${user['lastname']} - Feature coming soon!')),
    );
  }

  void _toggleUserStatus(Map<String, dynamic> user) {
    // TODO: Implement status toggle
    final newStatus = user['status'] == 'Suspended' ? 'Active' : 'Suspended';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${user['firstname']} ${user['lastname']} status changed to $newStatus - Feature coming soon!')),
    );
  }

  String _formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return 'Never';
    final date = timestamp.toDate();
    return '${date.month}/${date.day}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}