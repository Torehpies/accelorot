// lib/ui/web_admin_home/widgets/recent_activities_table.dart
import 'package:flutter/material.dart';

class RecentActivitiesTable extends StatelessWidget {
  final List<Map<String, String>> activities;

  const RecentActivitiesTable({super.key, required this.activities});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Recent Activities', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF374151))),
          const SizedBox(height: 20),
          _buildHeader(),
          const Divider(height: 1, color: Color(0xFFE5E7EB)),
          const SizedBox(height: 8),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: activities.map((activity) => _buildRow(activity)).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: const [
          Expanded(flex: 3, child: Text('Description', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF9CA3AF)))),
          Expanded(child: Text('Category', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF9CA3AF)))),
          Expanded(child: Text('Status', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF9CA3AF)))),
          Expanded(child: Text('Date', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF9CA3AF)))),
        ],
      ),
    );
  }

  Widget _buildRow(Map<String, String> item) {
    final iconColor = _getIconColor(item['icon']!);
    final icon = _getIcon(item['icon']!);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(color: iconColor, borderRadius: BorderRadius.circular(6)),
                  child: Icon(icon, size: 16, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['description']!, 
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Color(0xFF374151)),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(item['username']!, style: const TextStyle(fontSize: 10, color: Color(0xFF9CA3AF))),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(child: Text(item['category']!, style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280)))),
          Expanded(child: Text(item['status']!, style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280)))),
          Expanded(child: Text(item['date']!, style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280)))),
        ],
      ),
    );
  }

  Color _getIconColor(String type) {
    switch (type) {
      case 'alert': return const Color(0xFFF59E0B); // Orange
      case 'check': return const Color(0xFF10B981); // Green
      case 'clipboard': return const Color(0xFFEC4899); // Pink/Red
      default: return const Color(0xFFF59E0B);
    }
  }

  IconData _getIcon(String type) {
    switch (type) {
      case 'alert': return Icons.error;
      case 'check': return Icons.check;
      default: return Icons.assignment;
    }
  }
}