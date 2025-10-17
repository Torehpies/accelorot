import 'package:flutter/material.dart';
import '../widgets/slide_page_route.dart';
import '../view_screens/substrates_screen.dart';
import '../widgets/substrate_box.dart';

class SubstrateSection extends StatelessWidget {
  const SubstrateSection({super.key});

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
                      Navigator.of(
                        context,
                      ).push(SlidePageRoute(page: const SubstratesScreen()));
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

              // Boxes
              Expanded(
                child: Row(
                  children: const [
                    SubstrateBox(
                      icon: Icons.eco,
                      label: 'Green',
                      filterValue: 'Greens',
                    ),
                    SizedBox(width: 8),
                    SubstrateBox(
                      icon: Icons.energy_savings_leaf,
                      label: 'Brown',
                      filterValue: 'Browns',
                    ),
                    SizedBox(width: 8),
                    SubstrateBox(
                      icon: Icons.recycling,
                      label: 'Compost',
                      filterValue: 'Compost',
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

  Widget _buildBox(BuildContext context, IconData icon, String label) {
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () {
          // TODO: Add box function
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
