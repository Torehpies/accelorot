import 'package:flutter/material.dart';

class CalendarWidget extends StatelessWidget {
  final DateTime currentDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final year = currentDate.year;
    final month = currentDate.month;
    final firstDayOfMonth = DateTime(year, month, 1);
    final lastDayOfMonth = DateTime(year, month + 1, 0);
    final daysInMonth = lastDayOfMonth.day;
    final firstDayWeekday = firstDayOfMonth.weekday; // 1=Mon, 7=Sun

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
                Text('December 2025', style: Theme.of(context).textTheme.titleMedium),
                Row(
                  children: [
                    IconButton(onPressed: () {}, icon: Icon(Icons.arrow_back_ios, size: 16)),
                    IconButton(onPressed: () {}, icon: Icon(Icons.arrow_forward_ios, size: 16)),
                  ],
                ),
              ],
            ),
            SizedBox(height: 10),
            Table(
              border: TableBorder.all(color: Colors.grey[300]!),
              children: [
                TableRow(
                  children: ['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su']
                      .map((day) => TableCell(
                            child: Padding(
                              padding: EdgeInsets.all(8),
                              child: Center(child: Text(day, style: Theme.of(context).textTheme.bodySmall)),
                            ),
                          ))
                      .toList(),
                ),
                ...List.generate(
                  (daysInMonth + firstDayWeekday - 1) ~/ 7 + 1,
                  (weekIndex) {
                    return TableRow(
                      children: List.generate(7, (dayIndex) {
                        final dayNum = weekIndex * 7 + dayIndex - firstDayWeekday + 2;
                        if (dayNum < 1 || dayNum > daysInMonth) {
                          return TableCell(child: Container());
                        }
                        final isToday = dayNum == currentDate.day && month == currentDate.month;
                        return TableCell(
                          child: Padding(
                            padding: EdgeInsets.all(8),
                            child: Center(
                              child: Container(
                                width: 30,
                                height: 30,
                                decoration: BoxDecoration(
                                  color: isToday ? Colors.green : Colors.transparent,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Center(
                                  child: Text(
                                    '$dayNum',
                                    style: TextStyle(
                                      color: isToday ? Colors.white : Colors.black,
                                      fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}