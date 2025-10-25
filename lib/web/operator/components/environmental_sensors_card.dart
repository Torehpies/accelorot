// lib/web/operator/components/environmental_sensors_card.dart

import 'package:flutter/material.dart';

class EnvironmentalSensorsCard extends StatelessWidget {
  const EnvironmentalSensorsCard({super.key});

  @override
  Widget build(BuildContext context) {
    final sensors = [
      {
        'name': 'Temperature',
        'value': '32.7',
        'unit': '°C',
        'ideal': 'Ideal: 55–65°C',
        'trend': 'Heating Up +1.1° this week',
        'icon': Icons.thermostat,
        'color': Colors.orange,
      },
      {
        'name': 'Moisture',
        'value': '34.0',
        'unit': '%',
        'ideal': 'Ideal: 50–60%',
        'trend': 'Dry Day -2.4% this week',
        'icon': Icons.water_drop,
        'color': Colors.brown,
      },
      {
        'name': 'Oxygen Level',
        'value': '464',
        'unit': '',
        'ideal': 'Ideal: 0–1500 (Healthy)',
        'trend': 'Good (Well Aerated) +182 this week',
        'icon': Icons.air,
        'color': Colors.green,
      },
    ];

    return Card(
      elevation: 0,
      color: Colors.white, // ✅ CHANGED FROM Colors.grey[50] TO WHITE
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(Icons.sensors, color: Colors.grey[700], size: 18),
                const SizedBox(width: 8),
                Text(
                  'Environmental Sensors',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: List.generate(sensors.length, (index) {
                final sensor = sensors[index];
                final Color color = sensor['color'] as Color;

                return Expanded(
                  child: SizedBox(
                    height: 160,
                    child: Container(
                      margin: EdgeInsets.only(
                        right: index < sensors.length - 1 ? 12 : 0,
                      ),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white, // inner boxes already white
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: color, width: 1.5),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            sensor['name'] as String,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[700],
                            ),
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text(
                                sensor['value'] as String,
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[900],
                                ),
                              ),
                              if ((sensor['unit'] as String).isNotEmpty) ...[
                                const SizedBox(width: 2),
                                Text(
                                  sensor['unit'] as String,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ],
                            ],
                          ),
                          Text(
                            sensor['ideal'] as String,
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey[600],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Row(
                            children: [
                              Icon(
                                sensor['icon'] as IconData,
                                color: color,
                                size: 14,
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  sensor['trend'] as String,
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: color,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}