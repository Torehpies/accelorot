// lib/web/operator/components/environmental_sensors_card.dart

import 'package:flutter/material.dart';

class EnvironmentalSensorsCard extends StatelessWidget {
  const EnvironmentalSensorsCard({super.key});

  @override
  Widget build(BuildContext context) {
    final sensors = [
      {'name': 'Temperature', 'value': '3°C', 'icon': Icons.thermostat, 'trend': '+0 this week', 'status': 'normal'},
      {'name': 'Moisture', 'value': '3 g/m³', 'icon': Icons.water_drop, 'trend': '+0 this week', 'status': 'normal'},
      {'name': 'Oxygen Level', 'value': '3 CO₂', 'icon': Icons.air, 'trend': '+0 this week', 'status': 'warning'},
    ];

    return Card(
      elevation: 2,
      color: Colors.white, // ✅ ADD THIS LINE → makes entire card white
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Icon(Icons.sensors, color: Colors.teal, size: 20),
                SizedBox(width: 8),
                Text(
                  'Environmental Sensors',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Row(
                children: List.generate(sensors.length, (index) {
                  final sensor = sensors[index];
                  Color statusColor = Colors.green;
                  if (sensor['status'] == 'warning') statusColor = Colors.orange;
                  if (sensor['status'] == 'critical') statusColor = Colors.red;

                  return Expanded(
                    child: Container(
                      margin: EdgeInsets.only(
                        right: index < sensors.length - 1 ? 12 : 0,
                      ),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white, // Inner box white (already correct)
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Icon(
                            sensor['icon'] as IconData,
                            color: statusColor,
                            size: 24,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            sensor['name'] as String,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[700],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const Spacer(),
                          Text(
                            sensor['value'] as String,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: statusColor,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  sensor['trend'] as String,
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey[600],
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}