  import 'package:flutter/material.dart';

class ActivityChart extends StatelessWidget {
  final List<Map<String, dynamic>> activities;

  const ActivityChart({super.key, required this.activities});

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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Activity Overview', style: Theme.of(context).textTheme.titleMedium),
                Row(
                  children: [
                    Container(width: 10, height: 10, color: Colors.green),
                    SizedBox(width: 5),
                    Text('Number of Activities Per Day', style: Theme.of(context).textTheme.bodyMedium),
                  ],
                ),
              ],
            ),
            SizedBox(height: 10),
            SizedBox(
              height: 200,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: activities.length,
                separatorBuilder: (_, _) => SizedBox(width: 10),
                itemBuilder: (context, index) {
                  final item = activities[index];
                  final percent = (item['count'] / 100) * 100;
                  return Column(
                    children: [
                      Container(
                        width: 40,
                        height: percent * 2,
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.vertical(top: Radius.circular(4)),
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(item['day'], style: Theme.of(context).textTheme.bodySmall),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}