//filter_box.dart
import 'package:flutter/material.dart';
import 'slide_page_route.dart';

class FilterBox extends StatelessWidget {
  final IconData icon;
  final String label;
  final String filterValue;
  final Widget destination;

  const FilterBox({
    super.key,
    required this.icon,
    required this.label,
    required this.filterValue,
    required this.destination,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () {
          Navigator.of(context).push(
            SlidePageRoute(page: destination),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
            color: Colors.white,
          ),
          padding: const EdgeInsets.symmetric(vertical: 18),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 26, color: Colors.grey),
              const SizedBox(height: 8),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}