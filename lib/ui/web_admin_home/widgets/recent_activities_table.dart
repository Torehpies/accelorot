import 'package:flutter/material.dart';

class RecentActivitiesTable extends StatelessWidget {
  final List<Map<String, String>> activities;

  const RecentActivitiesTable({super.key, required this.activities});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Recent Activities', style: Theme.of(context).textTheme.titleMedium),
            SizedBox(height: 10),
            DataTable(
              columnSpacing: 10,
              headingRowHeight: 30,
              dataRowHeight: 60,
              columns: [
                DataColumn(label: Text('Description')),
                DataColumn(label: Text('Category')),
                DataColumn(label: Text('Status')),
                DataColumn(label: Text('Date')),
              ],
              rows: activities.map((activity) {
                return DataRow(
                  cells: [
                    DataCell(Row(
                      children: [
                        Icon(Icons.circle, color: _getIconColor(activity['icon']), size: 16),
                        SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(activity['description'] ?? '', maxLines: 1, overflow: TextOverflow.ellipsis),
                            Text(activity['username'] ?? '', style: TextStyle(fontSize: 12, color: Colors.grey)),
                          ],
                        ),
                      ],
                    )),
                    DataCell(Text(activity['category'] ?? '')),
                    DataCell(Text(activity['status'] ?? '')),
                    DataCell(Text(activity['date'] ?? '')),
                  ],
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Color _getIconColor(String? iconPath) {
    if (iconPath?.contains('alert') == true) return Colors.red;
    if (iconPath?.contains('check') == true) return Colors.green;
    return Colors.orange;
  }
}