import 'package:flutter/material.dart';
import '../view_screens/cycles_recom_screen.dart';
import '../widgets/slide_page_route.dart';

class CyclesRecomSection extends StatelessWidget {

  final String? focusedMachineId; 

  const CyclesRecomSection({
    super.key,

    this.focusedMachineId,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          SlidePageRoute(
            page: CyclesRecomScreen(
              focusedMachineId: focusedMachineId,
            ),
          ),
        );
      },
      child: SizedBox(
        width: 400,
        height: 80,
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Row(
                  children: [
                    Icon(Icons.auto_awesome, color: Colors.teal),
                    SizedBox(width: 8),
                    Text(
                      "Cycles & Recommendations",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                Icon(Icons.arrow_forward_ios, color: Colors.teal, size: 18),
              ],
            ),
          ),
        ),
      ),
    );
  }
}