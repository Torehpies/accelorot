import 'package:flutter/material.dart';
import '../view_screens/all_activity_screen.dart';
import '../widgets/slide_page_route.dart';

class AllActivitySection extends StatelessWidget {

  final String? focusedMachineId;

  const AllActivitySection({
    super.key,

    this.focusedMachineId,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: Card(
        // ...existing code...
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Header with View All
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // ...existing code...
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        SlidePageRoute(
                          page: AllActivityScreen(

                            focusedMachineId: focusedMachineId, 
                          ),
                        ),
                      );
                    },
                    child: const Text('View All >'),
                  ),
                ],
              ),
              // ...existing filter boxes with focusedMachineId passed...
            ],
          ),
        ),
      ),
    );
  }
}