import 'package:flutter/material.dart';
import '../view_screens/all_activity_screen.dart';
import '../widgets/slide_page_route.dart';

class AllActivitySection extends StatelessWidget {
  final String? viewingOperatorId; 

  const AllActivitySection({
    super.key,
    this.viewingOperatorId, 
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          SlidePageRoute(
            page: AllActivityScreen(
              viewingOperatorId: viewingOperatorId, 
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
                    Icon(Icons.history, color: Colors.teal),
                    SizedBox(width: 8),
                    Text(
                      "View All Activity",
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
