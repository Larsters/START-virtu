import 'package:flutter/material.dart';
import 'package:frontend/view/crop/crop_controller.dart';
import 'package:provider/provider.dart';

class CropStatistics extends StatelessWidget {
  const CropStatistics({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<CropController>(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _StatisticsSection(
          title: 'Risk Analysis',
          items:
              controller.risks.map((risk) {
                return _StatItem(
                  name: risk.name,
                  percentage: risk.percentage,
                  description: risk.description,
                  isRisk: true,
                );
              }).toList(),
        ),
        const SizedBox(height: 24),
        _StatisticsSection(
          title: 'Soil Health',
          items:
              controller.soilHealth.map((health) {
                return _StatItem(
                  name: health.name,
                  percentage: health.percentage,
                  description: health.description,
                  isRisk: false,
                );
              }).toList(),
        ),
      ],
    );
  }
}

class _StatisticsSection extends StatelessWidget {
  final String title;
  final List<_StatItem> items;

  const _StatisticsSection({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Text(title, style: Theme.of(context).textTheme.titleLarge),
        ),
        ...items,
      ],
    );
  }
}

class _StatItem extends StatelessWidget {
  final String name;
  final double percentage;
  final String description;
  final bool isRisk;

  const _StatItem({
    required this.name,
    required this.percentage,
    required this.description,
    required this.isRisk,
  });

  Color _getColor() {
    if (isRisk) {
      if (percentage >= 70) return Colors.red;
      if (percentage >= 40) return Colors.orange;
      return Colors.green;
    } else {
      if (percentage >= 70) return Colors.green;
      if (percentage >= 40) return Colors.orange;
      return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  name,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              Text(
                '${percentage.toStringAsFixed(0)}%',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: _getColor(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percentage / 100,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(_getColor()),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}
