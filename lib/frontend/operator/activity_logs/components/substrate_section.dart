import 'package:flutter/material.dart';
import '../widgets/slide_page_route.dart';
import '../view_screens/substrates_screen.dart';
import '../widgets/filter_box.dart';

class SubstrateSection extends StatelessWidget {
  final String? viewingOperatorId; 

  const SubstrateSection({
    super.key,
    this.viewingOperatorId, 
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: Card(
        color: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.eco_outlined, color: Colors.grey, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Substrate',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        SlidePageRoute(
                          page: SubstratesScreen(
                            viewingOperatorId: viewingOperatorId, 
                          ),
                        ),
                      );
                    },
                    child: const Text(
                      'View All >',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.blue,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Boxes using unified FilterBox
              Expanded(
                child: Row(
                  children: [
                    FilterBox(
                      icon: Icons.eco,
                      label: 'Green',
                      filterValue: 'Greens',
                      destination: SubstratesScreen(
                        initialFilter: 'Greens',
                        viewingOperatorId: viewingOperatorId, 
                      ),
                    ),
                    const SizedBox(width: 8),
                    FilterBox(
                      icon: Icons.energy_savings_leaf,
                      label: 'Brown',
                      filterValue: 'Browns',
                      destination: SubstratesScreen(
                        initialFilter: 'Browns',
                        viewingOperatorId: viewingOperatorId, 
                      ),
                    ),
                    const SizedBox(width: 8),
                    FilterBox(
                      icon: Icons.recycling,
                      label: 'Compost',
                      filterValue: 'Compost',
                      destination: SubstratesScreen(
                        initialFilter: 'Compost',
                        viewingOperatorId: viewingOperatorId, 
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}