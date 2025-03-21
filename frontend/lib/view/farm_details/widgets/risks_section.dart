import 'package:flutter/material.dart';
import 'package:frontend/view/farm_details/farm_details_controller.dart';
import 'package:frontend/view/farm_details/models/risk.dart';
import 'package:provider/provider.dart';

class RisksSection extends StatelessWidget {
  const RisksSection({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<FarmDetailsController>(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Text(
            'Risk Analysis',
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        ...controller.risks.map(
          (risk) => Padding(
            padding: const EdgeInsets.only(bottom: 24),
            child: _RiskBar(risk: risk),
          ),
        ),
      ],
    );
  }
}

class _RiskBar extends StatelessWidget {
  final Risk risk;

  const _RiskBar({required this.risk});

  Color _getValueColor() {
    if (risk.isWithinOptimalRange) return Colors.green;
    return risk.value < risk.min ? Colors.blue : Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    // Find the total range to display
    final totalMin = risk.min - (risk.max - risk.min) * 0.5;
    final totalMax = risk.max + (risk.max - risk.min) * 0.5;
    final totalRange = totalMax - totalMin;

    // Calculate positions
    final minPosition = (risk.min - totalMin) / totalRange;
    final maxPosition = (risk.max - totalMin) / totalRange;
    final valuePosition = (risk.value - totalMin) / totalRange;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              risk.type.displayName,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Text(
              risk.value.toStringAsFixed(1),
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
              'Min: ${risk.min}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            Text(
              'Max: ${risk.max}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ],
    );
  }
}
