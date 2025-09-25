import 'package:flutter/material.dart';

class SystemCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row with title and status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('System', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                Row(
                  children: [
                    Text('Status: ', style: TextStyle(color: Colors.grey)),
                    Text('Excellent', style: TextStyle(color: Colors.green)),
                    Icon(Icons.check_circle, color: Colors.green, size: 20)
                  ],
                ),
              ],
            ),
            SizedBox(height: 8),
            // Uptime and Last Update info
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Uptime\n12:12:12', style: TextStyle(color: Colors.grey)),
                Text('Last Update\n12:12:13 Aug 30, 2025', textAlign: TextAlign.right, style: TextStyle(color: Colors.grey)),
              ],
            ),
            SizedBox(height: 16),
            // Input and dropdown
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Set number of Cycles',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    value: 'Time Period',
                    onChanged: (value) {},
                    items: [
                      DropdownMenuItem(child: Text('Time Period'), value: 'Time Period'),
                      DropdownMenuItem(child: Text('1 Hour'), value: '1 Hour'),
                      DropdownMenuItem(child: Text('12 Hour'), value: '12 Hour'),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            // Start button
            Center(
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  elevation: 2,
                  padding: EdgeInsets.symmetric(horizontal: 36, vertical: 12),
                ),
                child: Text('Start'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
