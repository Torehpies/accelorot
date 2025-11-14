// lib/frontend/operator/dashboard/add_waste/widgets/add_waste_fab.dart
import 'package:flutter/material.dart';
import '../add_waste_product.dart';

class AddWasteFAB extends StatelessWidget {
  final VoidCallback? onAddHandled;

  const AddWasteFAB({super.key, this.onAddHandled});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, right: 16),
      child: SizedBox(
        width: 58,
        height: 58,
        child: FloatingActionButton(
          onPressed: () async {
            final result = await showDialog<Map<String, dynamic>>(
              context: context,
              builder: (context) => const AddWasteProduct(),
            );
            if (result != null && onAddHandled != null) {
              onAddHandled!();
            }
          },
          backgroundColor: Colors.teal,
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.add, size: 28, color: Colors.white),
        ),
      ),
    );
  }
}
