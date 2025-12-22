import 'package:flutter/material.dart';
import 'package:flutter_application_1/ui/web_operator/widgets/tabs_row.dart';

class TeamHeaderWithTabs extends StatelessWidget {
  final TabController controller;

  const TeamHeaderWithTabs({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          TabsRow(controller: controller),
          const Spacer(),
          TextButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.calendar_today_outlined, size: 18),
            label: const Text('Date'),
          ),
          const SizedBox(width: 12),
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
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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
