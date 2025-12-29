import 'package:flutter/foundation.dart';

/// Machine model
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

/// UI logic for machines screen (NO mock data)
class MachinesViewModel extends ChangeNotifier {
  /// Source of truth (loaded from API / Firestore)
  List<Machine> _allMachines = [];

  /// Filtered + paginated list
  List<Machine> _filteredMachines = [];

  /// Pagination
  int _currentPage = 1;
  final int _itemsPerPage = 8;
  int _totalPages = 1;

  /// Search
  String _searchQuery = '';

  /* =======================
   * GETTERS
   * ======================= */

  int get currentPage => _currentPage;
  int get totalPages => _totalPages;

  bool get canGoNext => _currentPage < _totalPages;
  bool get canGoPrevious => _currentPage > 1;

  /* =======================
   * STATS
   * ======================= */

  int get activeMachines =>
      _allMachines.where((m) => m.status == 'Active').length;

  int get inactiveMachines =>
      _allMachines.where((m) => m.status == 'Inactive').length;

  int get suspendedMachines =>
      _allMachines.where((m) => m.status == 'Suspended').length;

  /// Replace later with real analytics
  int get newMachines => 0;

  String get activeChange => '—';
  String get inactiveChange => '—';
  String get suspendedChange => '—';
  String get newChange => '—';

  /* =======================
   * DATA SETTER
   * ======================= */

  /// Call this when data is loaded from API / Firestore
  void setMachines(List<Machine> machines) {
    _allMachines = machines;
    _currentPage = 1;
    _applyFilters();
    notifyListeners();
  }

  /* =======================
   * SEARCH
   * ======================= */

  void searchMachines(String query) {
    _searchQuery = query.toLowerCase();
    _currentPage = 1;
    _applyFilters();
    notifyListeners();
  }

  void _applyFilters() {
    _filteredMachines = _allMachines.where((machine) {
      if (_searchQuery.isEmpty) return true;

      return machine.name.toLowerCase().contains(_searchQuery) ||
          machine.id.toLowerCase().contains(_searchQuery) ||
          machine.firstName.toLowerCase().contains(_searchQuery) ||
          machine.lastName.toLowerCase().contains(_searchQuery);
    }).toList();

    _calculatePagination();
  }

  /* =======================
   * PAGINATION
   * ======================= */

  void _calculatePagination() {
    _totalPages = (_filteredMachines.length / _itemsPerPage).ceil();
    if (_totalPages == 0) _totalPages = 1;
  }

  List<Machine> getMachinesForCurrentPage() {
    final startIndex = (_currentPage - 1) * _itemsPerPage;
    final endIndex = startIndex + _itemsPerPage;

    if (startIndex >= _filteredMachines.length) return [];

    return _filteredMachines.sublist(
      startIndex,
      endIndex > _filteredMachines.length
          ? _filteredMachines.length
          : endIndex,
    );
  }

  void goToPage(int page) {
    if (page >= 1 && page <= _totalPages) {
      _currentPage = page;
      notifyListeners();
    }
  }

  void nextPage() {
    if (canGoNext) {
      _currentPage++;
      notifyListeners();
    }
  }

  void previousPage() {
    if (canGoPrevious) {
      _currentPage--;
      notifyListeners();
    }
  }
}
