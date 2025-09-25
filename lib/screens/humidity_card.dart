import 'package:flutter/material.dart';

class HumidityCard extends StatelessWidget {
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
            Row(
              children: [
                Text('Humidity', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                Spacer(),
                Text('38%', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              ],
            ),
            Row(
              children: [
                Text('Quality: ', style: TextStyle(color: Colors.grey)),
                Text('Excellent', style: TextStyle(color: Colors.green)),
                Icon(Icons.check_circle, color: Colors.green, size: 18)
              ],
            ),
            SizedBox(height: 10),
            Text('Ideal Range: 40-65%', style: TextStyle(fontSize: 12, color: Colors.grey)),
            SizedBox(height: 6),
            LinearProgressIndicator(
              value: 0.38,
              minHeight: 7,
              backgroundColor: Colors.grey[200],
              color: Colors.green,
            ),
            SizedBox(height: 8),
            // Placeholder for chart area
            SizedBox(
              height: 80,
              child: Center(child: Text('<< Chart Placeholder >>', style: TextStyle(color: Colors.grey))),
            ),
          ],
        ),
      ),
    );
  }
}
