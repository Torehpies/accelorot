import 'package:flutter/foundation.dart';

/// Mock Machine Model (just for UI)
class Machine {
  final String id;
  final String name;
  final String firstName;
  final String lastName;
  final String status;

  Machine({
    required this.id,
    required this.name,
    required this.firstName,
    required this.lastName,
    required this.status,
  });
}

/// UI logic for machines screen with mock data
class MachinesViewModel extends ChangeNotifier {
  // Mock data
  final List<Machine> _allMachines = [
    Machine(id: '001', name: 'Machine A', firstName: 'John', lastName: 'Doe', status: 'Active'),
    Machine(id: '002', name: 'Machine B', firstName: 'Jane', lastName: 'Smith', status: 'Active'),
    Machine(id: '003', name: 'Machine C', firstName: 'Bob', lastName: 'Johnson', status: 'Inactive'),
    Machine(id: '004', name: 'Machine D', firstName: 'Alice', lastName: 'Williams', status: 'Inactive'),
    Machine(id: '005', name: 'Machine E', firstName: 'Charlie', lastName: 'Brown', status: 'Active'),
    Machine(id: '006', name: 'Machine F', firstName: 'Diana', lastName: 'Davis', status: 'Suspended'),
    Machine(id: '007', name: 'Machine G', firstName: 'Eve', lastName: 'Miller', status: 'Active'),
    Machine(id: '008', name: 'Machine H', firstName: 'Frank', lastName: 'Wilson', status: 'Suspended'),
    Machine(id: '009', name: 'Machine I', firstName: 'Grace', lastName: 'Moore', status: 'Active'),
    Machine(id: '010', name: 'Machine J', firstName: 'Henry', lastName: 'Taylor', status: 'Active'),
    Machine(id: '011', name: 'Machine K', firstName: 'Ivy', lastName: 'Anderson', status: 'Inactive'),
    Machine(id: '012', name: 'Machine L', firstName: 'Jack', lastName: 'Thomas', status: 'Active'),
    Machine(id: '013', name: 'Machine M', firstName: 'Kate', lastName: 'Jackson', status: 'Active'),
    Machine(id: '014', name: 'Machine N', firstName: 'Leo', lastName: 'White', status: 'Inactive'),
    Machine(id: '015', name: 'Machine O', firstName: 'Mia', lastName: 'Harris', status: 'Active'),
  ];

  List<Machine> _filteredMachines = [];
  
  // Pagination
  int _currentPage = 1;
  final int _itemsPerPage = 8;
  int _totalPages = 1;
  
  // Search
  String _searchQuery = '';
  
  // Getters
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;
  
  // Stats
  int get activeMachines => _allMachines.where((m) => m.status == 'Active').length;
  int get inactiveMachines => _allMachines.where((m) => m.status == 'Inactive').length;
  int get suspendedMachines => _allMachines.where((m) => m.status == 'Suspended').length;
  int get newMachines => 5; // Mock value
  
  String get activeChange => '+ 25%';
  String get inactiveChange => '+ 25%';
  String get suspendedChange => '- 10%';
  String get newChange => '- 50%';
  
  MachinesViewModel() {
    _filteredMachines = _allMachines;
    _calculatePagination();
  }
  
  /// Search machines
  void searchMachines(String query) {
    _searchQuery = query.toLowerCase();
    _currentPage = 1;
    _applyFilters();
    notifyListeners();
  }
  
  void _applyFilters() {
    _filteredMachines = _allMachines.where((machine) {
      return _searchQuery.isEmpty ||
          machine.name.toLowerCase().contains(_searchQuery) ||
          machine.id.toLowerCase().contains(_searchQuery) ||
          machine.firstName.toLowerCase().contains(_searchQuery) ||
          machine.lastName.toLowerCase().contains(_searchQuery);
    }).toList();
    
    _calculatePagination();
  }
  
  void _calculatePagination() {
    _totalPages = (_filteredMachines.length / _itemsPerPage).ceil();
    if (_totalPages == 0) _totalPages = 1;
  }
  
  /// Get machines for current page
  List<Machine> getMachinesForCurrentPage() {
    final startIndex = (_currentPage - 1) * _itemsPerPage;
    final endIndex = startIndex + _itemsPerPage;
    
    if (startIndex >= _filteredMachines.length) {
      return [];
    }
    
    return _filteredMachines.sublist(
      startIndex,
      endIndex > _filteredMachines.length ? _filteredMachines.length : endIndex,
    );
  }
  
  /// Go to specific page
  void goToPage(int page) {
    if (page >= 1 && page <= _totalPages) {
      _currentPage = page;
      notifyListeners();
    }
  }
  
  /// Go to next page
  void nextPage() {
    if (_currentPage < _totalPages) {
      _currentPage++;
      notifyListeners();
    }
  }
  
  /// Go to previous page
  void previousPage() {
    if (_currentPage > 1) {
      _currentPage--;
      notifyListeners();
    }
  }
  
  bool get canGoNext => _currentPage < _totalPages;
  bool get canGoPrevious => _currentPage > 1;
}