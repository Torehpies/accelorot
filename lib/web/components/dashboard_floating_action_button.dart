// lib/web/admin/components/dashboard_floating_action_button.dart
import 'package:flutter/material.dart';

class DashboardFloatingActionButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const DashboardFloatingActionButton({
    super.key,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: onPressed ?? () {},
      backgroundColor: Colors.green,
      // ignore: sort_child_properties_last
      child: const Icon(Icons.add, color: Colors.white, size: 24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      mini: true, // Small square button
      elevation: 4,
    );
  }
}