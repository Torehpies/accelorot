import 'package:flutter/material.dart';
import 'package:flutter_application_1/ui/core/themes/app_theme.dart';
import 'package:flutter_application_1/ui/core/ui/unerlined_text_button.dart';

class CustomTabbedContainer extends StatefulWidget {
  const CustomTabbedContainer({super.key});

  @override
  _CustomTabbedContainerState createState() => _CustomTabbedContainerState();
}

class _CustomTabbedContainerState extends State<CustomTabbedContainer> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background2,
        borderRadius: BorderRadius.circular(20),
      ),
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              UnderlinedToggleButtons(
                labels: ['Active', 'For Approval'],
                onPressed: (index) {
                  setState(() {
                    _selectedIndex = index;
                  });
                },
                isSelected: List.generate(2, (i) => i == _selectedIndex),
              ),
              IconButton(onPressed: () {}, icon: Icon(Icons.filter_alt)),
            ],
          ),
          // Main content container
          Expanded(
            child: IndexedStack(
              index: _selectedIndex,
              children: [_activeTabContent(), _approvalTabContent()],
            ),
          ),
        ],
      ),
    );
  }

  Widget _activeTabContent() => SingleChildScrollView(
    child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: _buildActiveTable(),
    ),
  );

  Widget _approvalTabContent() =>
      const Center(child: Text('Approval tables/rows'));
  Widget _buildActiveTable() {
    return SizedBox(
      width: double.infinity,
      child: DataTableTheme(
        data: DataTableThemeData(
          // decoration: TableBorder.all(color: Colors.grey),
          headingRowColor: WidgetStateProperty.all(AppColors.background),
        ),
        child: DataTable(
          columns: [
            _buildSortableColumn('First Name'),
            _buildSortableColumn('Last Name'),
            _buildSortableColumn('Email'),
            _buildSortableColumn('Date Applied'),
            _buildSortableColumn('Actions'),
          ],
          rows: [
            DataRow(
              cells: [
                DataCell(Text('Seiffer')),
                DataCell(Text('Salupado')),
                DataCell(Text('salupado@gmail.com')),
                DataCell(Text('10/10/03')),
                DataCell(Text('hatdog')),
              ],
            ),
            DataRow(
              cells: [
                DataCell(Text('Seiffer')),
                DataCell(Text('Salupado')),
                DataCell(Text('salupado@gmail.com')),
                DataCell(Text('10/10/03')),
                DataCell(Text('hatdog')),
              ],
            ),
          ], // Your data
        ),
      ),
    );
  }

  DataColumn _buildSortableColumn(String label) {
    return DataColumn(
      label: Container(
        decoration: BoxDecoration(),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label),
            IconButton(
              onPressed: null,
              icon: const Icon(Icons.import_export, size: 20),
            ),
          ],
        ),
      ),
    );
  }
}
