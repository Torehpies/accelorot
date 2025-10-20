import 'package:flutter/material.dart';

class MachineManagementScreen extends StatelessWidget {
 MachineManagementScreen({super.key});

  //  Sample data — replace with real data from API or state management later
  final List<Map<String, String>> _machines = [
    {'name': 'Name of the Machine', 'code': '2BIZ7340'},
    {'name': 'Name of the Machine', 'code': '2BIZ7340'},
    {'name': 'Name of the Machine', 'code': '2BIZ7340'},
    {'name': 'Name of the Machine', 'code': '2BIZ7340'},
    {'name': 'Name of the Machine', 'code': '2BIZ7340'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context), // Go back if needed
        ),
        title: const Text('Machine Management'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔹 Action Cards Row
            Row(
              children: [
                Expanded(
                  child: _buildActionCard(
                    icon: Icons.archive,
                    label: 'Archive',
                    onPressed: () {
                     
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Archive feature coming soon')),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildActionCard(
                    icon: Icons.add_circle_outline,
                    label: 'Add Machine',
                    onPressed: () {
                      
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Add Machine feature coming soon')),
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // 🔹 Section Title
            const Text(
              'Lists of Machines',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            // 🔹 Machine List
            Expanded(
              child: ListView.separated(
                itemCount: _machines.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final machine = _machines[index];
                  return Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      leading: Icon(
                        Icons.devices,
                        color: Colors.blue[300],
                      ),
                      title: Text(machine['name']!),
                      subtitle: Text('Product Code/ID: ${machine['code']}'),
                      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                      onTap: () {
                       
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Viewing: ${machine['name']}')),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🔹 Reusable Action Card Widget
  Widget _buildActionCard({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 32, color: Colors.blue[300]),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ),
    );
  }
}