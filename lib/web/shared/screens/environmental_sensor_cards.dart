// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

// ignore: unused_element
Widget _buildEnvironmentalSensorsCard() {
  final sensors = [
    {
      'name': 'Temperature',
      'value': '3°C',
      'icon': Icons.thermostat,
      'trend': '+0 this week',
      'status': 'normal',
    },
    {
      'name': 'Moisture',
      'value': '3 g/m³',
      'icon': Icons.water_drop,
      'trend': '+0 this week',
      'status': 'normal',
    },
    {
      'name': 'Oxygen Level',
      'value': '3 CO₂',
      'icon': Icons.air,
      'trend': '+0 this week',
      'status': 'warning',
    },
  ];

  return Card(
    elevation: 2,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.sensors, color: Colors.teal, size: 20),
              SizedBox(width: 8),
              Text(
                'Environmental Sensors',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: sensors.map((sensor) {
              Color statusColor = Colors.green;
              if (sensor['status'] == 'warning') statusColor = Colors.orange;
              if (sensor['status'] == 'critical') statusColor = Colors.red;

              return Container(
                width: 140,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: statusColor.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          sensor['icon'] as IconData,
                          color: statusColor,
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          sensor['name'] as String,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      sensor['value'] as String,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
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
                        const SizedBox(width: 4),
                        Text(
                          sensor['trend'] as String,
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    ),
  );
}
