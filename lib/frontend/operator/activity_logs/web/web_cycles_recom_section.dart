// lib/frontend/operator/activity_logs/web/web_cycles_recom_section.dart
import 'package:flutter/material.dart';
import '../../../../services/firestore_activity_service.dart';
import '../models/activity_item.dart';
import 'package:intl/intl.dart';

class WebCyclesRecomSection extends StatefulWidget {
  final String? viewingOperatorId;
  final VoidCallback? onViewAll;
  final String? focusedMachineId;

  const WebCyclesRecomSection({
    super.key,
    this.viewingOperatorId,
    this.onViewAll,
    this.focusedMachineId,
  });

  @override
  State<WebCyclesRecomSection> createState() => _WebCyclesRecomSectionState();
}

class _WebCyclesRecomSectionState extends State<WebCyclesRecomSection> {
  bool _isLoading = true;
  List<ActivityItem> _cycles = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadCycles();
  }

  Future<void> _loadCycles() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final cycles = await FirestoreActivityService.getCyclesRecom(
        viewingOperatorId: widget.viewingOperatorId,
      );

      // Filter by machine if focusedMachineId is provided
      final filteredCycles = widget.focusedMachineId != null
          ? cycles.where((c) => c.machineId == widget.focusedMachineId).toList()
          : cycles;

      setState(() {
        _cycles = filteredCycles.take(5).toList();
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
      return 'Today';
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
          border: Border.all(
            color: const Color.fromARGB(255, 243, 243, 243),
            width: 1,
          ),
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
          border: Border.all(
            color: const Color.fromARGB(255, 243, 243, 243),
            width: 1,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.all(16),
        child: Text(
          'Error: $_errorMessage',
          style: const TextStyle(color: Colors.red),
        ),
      );
    }
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: const Color.fromARGB(255, 243, 243, 243),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(Icons.auto_awesome, color: Colors.blue, size: 20),
                const SizedBox(width: 12),
                const Text(
                  'Composting Cycles',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
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
          _cycles.isEmpty
              ? const Padding(
                  padding: EdgeInsets.all(32.0),
                  child: Center(
                    child: Text(
                      'No recent cycles',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _cycles.length,
                  itemBuilder: (context, index) {
                    final cycle = _cycles[index];
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                      ),
                      title: Text(
                        cycle.title,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color.fromARGB(255, 48, 47, 47),
                        ),
                      ),
                      subtitle: Text(
                        '${_formatTime(cycle.timestamp)} • ${cycle.value}',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.grey,
                        ),
                      ),
                      trailing: Chip(
                        label: Text(cycle.category),
                        backgroundColor: cycle.statusColorValue.withValues(
                          alpha: 0.1,
                        ),
                        labelStyle: TextStyle(
                          color: cycle.statusColorValue,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    );
                  },
                ),
        ],
      ),
    );
  }
}
