import 'package:flutter/material.dart';
import '../widgets/filter_section.dart';
import '../widgets/activity_card.dart';
import '../models/activity_item.dart';

class SubstratesScreen extends StatefulWidget {
  final String initialFilter;

  const SubstratesScreen({
    super.key,
    this.initialFilter = 'All',
  });

  @override
  State<SubstratesScreen> createState() => _SubstratesScreenState();
}

class _SubstratesScreenState extends State<SubstratesScreen> {
  late String selectedFilter;
  final filters = const ['All', 'Greens', 'Browns', 'Compost'];

  @override
  void initState() {
    super.initState();
    selectedFilter = widget.initialFilter;
  }

  void _onFilterChanged(String filter) {
    setState(() {
      selectedFilter = filter;
    });
    // TODO: Add your filtering logic here
  }

  // Mock data for substrates
  List<ActivityItem> get _mockSubstrates => [
        ActivityItem(
          title: 'Fruit Scraps Added',
          value: '1.2kg',
          statusColor: 'green',
          icon: Icons.eco,
          description: 'Kitchen scraps: apple peels, banana peel',
          category: 'Greens',
          timestamp: DateTime(2024, 8, 25, 0, 12),
        ),
        ActivityItem(
          title: 'Dry Leaves Added',
          value: '0.8kg',
          statusColor: 'green',
          icon: Icons.energy_savings_leaf,
          description: 'Garden waste: dried leaves, small twigs',
          category: 'Browns',
          timestamp: DateTime(2024, 8, 24, 14, 30),
        ),
        ActivityItem(
          title: 'Coffee Grounds Added',
          value: '0.3kg',
          statusColor: 'green',
          icon: Icons.eco,
          description: 'Morning coffee grounds from kitchen',
          category: 'Greens',
          timestamp: DateTime(2024, 8, 24, 8, 15),
        ),
        ActivityItem(
          title: 'Cardboard Shredded',
          value: '0.5kg',
          statusColor: 'yellow',
          icon: Icons.energy_savings_leaf,
          description: 'Packaging materials: egg cartons, boxes',
          category: 'Browns',
          timestamp: DateTime(2024, 8, 23, 16, 45),
        ),
        ActivityItem(
          title: 'Vegetable Scraps Added',
          value: '1.5kg',
          statusColor: 'green',
          icon: Icons.eco,
          description: 'Carrot peels, lettuce cores, tomato ends',
          category: 'Greens',
          timestamp: DateTime(2024, 8, 23, 11, 20),
        ),
        ActivityItem(
          title: 'Compost Ready',
          value: '5.2kg',
          statusColor: 'green',
          icon: Icons.recycling,
          description: 'Batch #12 completed decomposition',
          category: 'Compost',
          timestamp: DateTime(2024, 8, 22, 9, 0),
        ),
      ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text("Substrate Logs"),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              // Fixed filter section at top
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: FilterSection(
                  filters: filters,
                  initialFilter: selectedFilter,
                  onSelected: _onFilterChanged,
                ),
              ),

              // Scrollable cards list
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _mockSubstrates.length,
                  itemBuilder: (context, index) {
                    return ActivityCard(item: _mockSubstrates[index]);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}