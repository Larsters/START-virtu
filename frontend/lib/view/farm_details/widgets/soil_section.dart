import 'package:flutter/material.dart';
import 'package:frontend/models/soil_data.dart';

class SoilSection extends StatelessWidget {
  final SoilData soilData;

  const SoilSection({super.key, required this.soilData});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Text(
            'Soil Analysis',
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        _SoilMetricBar(
          label: 'Soil Moisture',
          value: soilData.soilMoisture,
          min: 30,
          max: 70,
          unit: '%',
        ),
        const SizedBox(height: 24),
        _SoilMetricBar(
          label: 'Soil pH',
          value: soilData.soilPh,
          min: 6.0,
          max: 7.5,
          unit: 'pH',
        ),
        const SizedBox(height: 24),
        _SoilMetricBar(
          label: 'Nitrogen Content',
          value: soilData.soilNitrogenContent,
          min: 20,
          max: 40,
          unit: 'mg/kg',
        ),
      ],
    );
  }
}

class _SoilMetricBar extends StatelessWidget {
  final String label;
  final double value;
  final double min;
  final double max;
  final String unit;

  const _SoilMetricBar({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.unit,
  });

  Color _getValueColor() {
    if (value >= min && value <= max) return Colors.green;
    return value < min ? Colors.blue : Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    // Find the total range to display
    final totalMin = min - (max - min) * 0.5;
    final totalMax = max + (max - min) * 0.5;
    final totalRange = totalMax - totalMin;

    // Calculate positions
    final minPosition = (min - totalMin) / totalRange;
    final maxPosition = (max - totalMin) / totalRange;
    final valuePosition = (value - totalMin) / totalRange;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: Theme.of(context).textTheme.titleMedium),
            Text(
              '${value.toStringAsFixed(1)} $unit',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: _getValueColor(),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: 24,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Stack(
            children: [
              // Optimal range
              Positioned(
                left: minPosition * MediaQuery.of(context).size.width * 0.8,
                right:
                    (1 - maxPosition) * MediaQuery.of(context).size.width * 0.8,
                top: 0,
                bottom: 0,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              // Current value marker
              Positioned(
                left:
                    valuePosition * MediaQuery.of(context).size.width * 0.8 - 8,
                top: 0,
                bottom: 0,
                child: Container(
                  width: 16,
                  decoration: BoxDecoration(
                    color: _getValueColor(),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Min: $min $unit',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            Text(
              'Max: $max $unit',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ],
    );
  }
}
