
import 'package:flutter/material.dart';
import 'package:flutter_application_1/ui/web_operator/widgets/tabs_row.dart';

class TeamHeaderWithTabs extends StatelessWidget {
  const TeamHeaderWithTabs({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      // decoration: BoxDecoration(
      //   color: Colors.white,
      //   borderRadius: BorderRadius.circular(8),
      //   border: Border.all(color: const Color(0xFFE5E7EB)),
      // ),
      child: Row(
        children: [
          const TabsRow(),

          const Spacer(),

          // Dummy date picker button
          TextButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.calendar_today_outlined, size: 18),
            label: const Text('Date'),
          ),
          const SizedBox(width: 12),

          // Dummy search field
          SizedBox(
            width: 220,
            child: TextField(
              decoration: InputDecoration(
                isDense: true,
                prefixIcon: const Icon(Icons.search, size: 18),
                hintText: 'Search…',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Dummy primary button
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            child: const Text('Add Operator'),
          ),
        ],
      ),
    );
  }
}
