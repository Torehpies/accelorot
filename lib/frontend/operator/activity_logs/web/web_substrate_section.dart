// lib/frontend/operator/activity_logs/web/web_substrate_section.dart
import 'package:flutter/material.dart';
import '../../../../services/firestore_activity_service.dart';
import '../models/activity_item.dart';
import 'package:intl/intl.dart';

class WebSubstrateSection extends StatefulWidget {
  final String? viewingOperatorId;
  final VoidCallback? onViewAll;
  final String? focusedMachineId;

  const WebSubstrateSection({
    super.key,
    this.viewingOperatorId,
    this.onViewAll,
    this.focusedMachineId,
  });

  @override
  State<WebSubstrateSection> createState() => _WebSubstrateSectionState();
}

class _WebSubstrateSectionState extends State<WebSubstrateSection> {
  bool _isLoading = true;
  List<ActivityItem> _substrates = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadSubstrates();
  }

  Future<void> _loadSubstrates() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final substrates = await FirestoreActivityService.getSubstrates(
        viewingOperatorId: widget.viewingOperatorId,
      );

      // Filter by machine if focusedMachineId is provided
      final filteredSubstrates = widget.focusedMachineId != null
          ? substrates.where((s) => s.machineId == widget.focusedMachineId).toList()
          : substrates;

      setState(() {
        _substrates = filteredSubstrates.take(5).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final diff = now.difference(timestamp);

    if (diff.inDays == 0) {
      return 'Today, ${DateFormat('h:mm a').format(timestamp)}';
    } else if (diff.inDays == 1) {
      return 'Yesterday';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} days ago';
    } else {
      return DateFormat('MMM d').format(timestamp);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color.fromARGB(255, 243, 243, 243), width: 1),
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.all(32),
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage != null) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color.fromARGB(255, 243, 243, 243), width: 1),
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.all(16),
        child: Text('Error: $_errorMessage', style: const TextStyle(color: Colors.red)),
      );
    }
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color.fromARGB(255, 243, 243, 243), width: 1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(Icons.eco, color: Colors.green, size: 20),
                const SizedBox(width: 12),
                // ✅ Title: explicitly black
                const Text(
                  'Substrate Log',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black, // 🔲 Explicit black
                  ),
                ),
                if (widget.onViewAll != null) ...[
                  const Spacer(),
                  TextButton(
                    onPressed: widget.onViewAll,
                    child: const Text(
                      'View All',
                      style: TextStyle(color: Colors.teal, fontSize: 13),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const Divider(height: 1, color: Color.fromARGB(255, 243, 243, 243)),
          
          if (_substrates.isEmpty)
            const Padding(
              padding: EdgeInsets.all(32),
              child: Center(
                child: Text(
                  'No substrate entries',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _substrates.length,
              itemBuilder: (context, index) {
                final item = _substrates[index];
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  leading: CircleAvatar(
                    radius: 16,
                    backgroundColor: _getTypeColor(item.category),
                    child: Icon(
                      _getTypeIcon(item.category),
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                  title: Text(
                    item.title,
                    style: const TextStyle(fontSize: 14, color: Color.fromARGB(255, 48, 47, 47)),
                  ),
                  subtitle: Text(
                    '${item.value} • ${item.machineName ?? 'Unknown'}',
                    style: const TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                  trailing: Text(
                    _formatTime(item.timestamp),
                    style: const TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'Greens': return Colors.green;
      case 'Browns': return Colors.brown;
      case 'Compost': return Colors.teal;
      default: return Colors.grey;
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'Greens': return Icons.local_dining;
      case 'Browns': return Icons.park;
      case 'Compost': return Icons.recycling;
      default: return Icons.eco;
    }
  }
}