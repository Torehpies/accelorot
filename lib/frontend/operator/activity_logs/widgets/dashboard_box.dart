import 'package:flutter/material.dart';
import '../widgets/slide_page_route.dart';

class DashboardBox extends StatelessWidget {
  final IconData icon;
  final String label;
  final String filterValue;
  final Widget Function(String filter)? onTapNavigateTo;

  const DashboardBox({
    super.key,
    required this.icon,
    required this.label,
    required this.filterValue,
    this.onTapNavigateTo,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () {
          if (onTapNavigateTo != null) {
            Navigator.of(context).push(
              SlidePageRoute(page: onTapNavigateTo!(filterValue)),
            );
          }
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
