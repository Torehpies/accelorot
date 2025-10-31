// lib/components/environmental_sensors_card.dart
import 'package:flutter/material.dart';

class EnvironmentalSensorsCard extends StatelessWidget {
  final double? temperature; // °C
  final double? moisture; // %
  final double? oxygen; // MQ135 reading (0–4990)

  final String temperatureChange;
  final String moistureChange;
  final String oxygenChange;

  const EnvironmentalSensorsCard({
    super.key,
    this.temperature,
    this.moisture,
    this.oxygen,
    this.temperatureChange = '+0 this week',
    this.moistureChange = '+0 this week',
    this.oxygenChange = '+0 this week',
  });

  @override
  Widget build(BuildContext context) {
    // Determine status text & colors dynamically
    final tempStatus = _getTemperatureStatus(temperature);
    final moistStatus = _getMoistureStatus(moisture);
    final oxyStatus = _getOxygenStatus(oxygen);

    return SizedBox(
      width: 400,
      height: 220,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: const [
                  Icon(Icons.eco_outlined, color: Colors.green, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Environmental Sensors',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Sensor Tiles
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: _buildSensorTile(
                        title: 'Temperature',
                        value: temperature != null
                            ? '${temperature!.toStringAsFixed(1)}°C'
                            : '--°C',
                        change: temperatureChange,
                        status: tempStatus.$1,
                        color: tempStatus.$2,
                        ideal: '55–65°C',
                      ),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: _buildSensorTile(
                        title: 'Moisture',
                        value: moisture != null
                            ? '${moisture!.toStringAsFixed(1)} %'
                            : '-- %',
                        change: moistureChange,
                        status: moistStatus.$1,
                        color: moistStatus.$2,
                        ideal: '50–60%',
                      ),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: _buildSensorTile(
                        title: 'Air Quality',
                        value: oxygen != null
                            ? oxygen!.toStringAsFixed(0)
                            : '--',
                        change: oxygenChange,
                        status: oxyStatus.$1,
                        color: oxyStatus.$2,
                        ideal: '0–1500 (Healthy)',
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

  /// Builds an individual sensor display tile
  Widget _buildSensorTile({
    required String title,
    required String value,
    required String change,
    required String status,
    required Color color,
    required String ideal,
  }) {
    return Container(
      height: 110,
      decoration: BoxDecoration(
        border: Border.all(color: color.withValues(alpha: 0.8), width: 2),
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Title
          Text(
            title,
            style: const TextStyle(fontSize: 11, color: Colors.grey),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),

          // Value
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),

          // Ideal range
          Text(
            'Ideal: $ideal',
            style: const TextStyle(fontSize: 9, color: Colors.grey),
          ),

          // Status + change
          Row(
            children: [
              Icon(Icons.circle, size: 8, color: color),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  '$status • $change',
                  style: const TextStyle(fontSize: 8, color: Colors.grey),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Compost Temperature Logic
  (String, Color) _getTemperatureStatus(double? temp) {
    if (temp == null) return ('No Data', Colors.grey);
    if (temp < 25) return ('Too Cool', Colors.blue);
    if (temp >= 25 && temp < 55) return ('Heating Up', Colors.orange);
    if (temp >= 55 && temp <= 65) return ('Optimal', Colors.green);
    if (temp > 65 && temp <= 70) return ('Too Hot', Colors.redAccent);
    return ('Critical', Colors.red);
  }

  /// Compost Moisture Logic
  (String, Color) _getMoistureStatus(double? moist) {
    if (moist == null) return ('No Data', Colors.grey);
    if (moist < 40) return ('Too Dry', Colors.brown);
    if (moist >= 50 && moist <= 60) return ('Optimal', Colors.green);
    if (moist > 65) return ('Too Wet', Colors.blueAccent);
    return ('Moderate', Colors.orange);
  }

  /// Air Quality (MQ135) → inverse oxygen logic
  (String, Color) _getOxygenStatus(double? val) {
    if (val == null) return ('No Data', Colors.grey);
    if (val <= 1500) return ('Good (Well-Aerated)', Colors.green);
    if (val > 1500 && val <= 3000) return ('Moderate Gas Buildup', Colors.orange);
    if (val > 3000) return ('Poor (Low O₂)', Colors.red);
    return ('Unknown', Colors.grey);
  }
}
