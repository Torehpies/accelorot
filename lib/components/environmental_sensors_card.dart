// lib/components/environmental_sensors_card.dart
import 'package:flutter/material.dart';

class EnvironmentalSensorsCard extends StatelessWidget {
  final double? temperature;
  final double? moisture; // in g/m³
  final double? humidity; // in %

  final String temperatureChange;
  final String moistureChange;
  final String humidityChange;

  const EnvironmentalSensorsCard({
    super.key,
    this.temperature,
    this.moisture,
    this.humidity,
    this.temperatureChange = '+0 this week',
    this.moistureChange = '+0 this week',
    this.humidityChange = '+0 this week',
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 400,
      height: 210,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Icon(Icons.eco_outlined, color: Colors.green, size: 20),
                  const SizedBox(width: 8),
                  const Text(
                    'Environmental Sensors',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Sensor Tiles Row — ✅ Equal spacing & height
              Expanded(
                child: Row(
                  children: [
                    Expanded(child: _buildSensorTile(
                      title: 'Temperature',
                      value: temperature != null ? '${temperature!.toStringAsFixed(1)}°C' : '--°C',
                      change: temperatureChange,
                      iconColor: Colors.green,
                      borderColor: Colors.green,
                    )),
                    const SizedBox(width: 8), // Small gap between tiles
                    Expanded(child: _buildSensorTile(
                      title: 'Moisture',
                      value: moisture != null ? '${moisture!.toStringAsFixed(1)} g/m³' : '-- g/m³',
                      change: moistureChange,
                      iconColor: Colors.orange,
                      borderColor: Colors.orange,
                    )),
                    const SizedBox(width: 8),
                    Expanded(child: _buildSensorTile(
                      title: 'Humidity',
                      value: humidity != null ? '${humidity!.toStringAsFixed(0)}%' : '--%',
                      change: humidityChange,
                      iconColor: Colors.red,
                      borderColor: Colors.red,
                    )),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSensorTile({
    required String title,
    required String value,
    required String change,
    required Color iconColor,
    required Color borderColor,
  }) {
    return Container(
      height: 100, // ✅ Fixed height for perfect alignment
      decoration: BoxDecoration(
        border: Border.all(color: borderColor, width: 2),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 9, color: Colors.grey),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Row(
            children: [
              Icon(Icons.circle, size: 8, color: iconColor),
              const SizedBox(width: 4),
              Text(
                change,
                style: const TextStyle(fontSize: 7, color: Colors.grey),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
