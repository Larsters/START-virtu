import 'package:flutter/material.dart';
import 'package:frontend/view/farm_details/farm_details_controller.dart';
import 'package:provider/provider.dart';

class RisksSection extends StatelessWidget {
  const RisksSection({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<FarmDetailsController>(context);

    if (controller.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (controller.error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Failed to load risk data',
                style: Theme
                    .of(context)
                    .textTheme
                    .titleMedium,
              ),
              Text(
                controller.error!,
                style: Theme
                    .of(context)
                    .textTheme
                    .bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: () => controller.refreshData(),
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    final riskStats = controller.riskStats;
    if (riskStats == null) {
      return const SizedBox.shrink();
    }

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
        _RiskBar(
          label: 'Day Heat Stress',
          riskLevel: riskStats.getDayRiskLevel,
          value: riskStats.getDayRiskValue.toDouble(),
          optimal: double.tryParse(riskStats.getDayRiskOptimal) ?? 0.0,
          worst: double.tryParse(riskStats.getDayRiskWorst) ?? 0.0,
        ),
        const SizedBox(height: 24),
        _RiskBar(
          label: 'Night Heat Stress',
          riskLevel: riskStats.getNightRiskLevel,
          value: riskStats.getNightRiskValue.toDouble(),
          optimal: double.tryParse(riskStats.getNightRiskOptimal) ?? 0.0,
          worst: double.tryParse(riskStats.getNightRiskWorst) ?? 0.0,
        ),
        const SizedBox(height: 24),
        _RiskBar(
          label: 'Frost Stress',
          riskLevel: riskStats.getFrostStressLevel,
          value: riskStats.getFrostStressValue.toDouble(),
          optimal: double.tryParse(riskStats.getFrostStressOptimal) ?? 0.0,
          worst: double.tryParse(riskStats.getFrostStressWorst) ?? 0.0,
        ),
        const SizedBox(height: 24),
        _RiskBar(
          label: 'Drought Risk',
          riskLevel: riskStats.getDroughtRiskLevel,
          value: riskStats.getDroughtRiskValue.toDouble(),
          optimal: double.tryParse(riskStats.getDroughtRiskOptimal) ?? 0.0,
          worst: double.tryParse(riskStats.getDroughtRiskWorst) ?? 0.0,
        ),
        const SizedBox(height: 24),
        _RiskBar(
          label: 'Yield Risk',
          riskLevel: riskStats.getYieldRiskLevel,
          value: riskStats.getYieldRiskValue.toDouble(),
          optimal: double.tryParse(riskStats.getYieldRiskOptimal) ?? 0.0,
          worst: double.tryParse(riskStats.getYieldRiskWorst) ?? 0.0,
        ),
      ],
    );
  }
}

class _RiskBar extends StatelessWidget {
  final String label;
  final String riskLevel;
  final double value;
  final double optimal;
  final double worst;

  const _RiskBar({
    required this.label,
    required this.riskLevel,
    required this.value,
    required this.optimal,
    required this.worst,
  });

  Color _getRiskColor() {
    switch (riskLevel.toLowerCase()) {
      case 'low':
        return Colors.green;
      case 'medium':
        return Colors.orange;
      case 'high':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Calculate the range for visualization
    final min = optimal < worst ? optimal : worst;
    final max = optimal > worst ? optimal : worst;
    final totalMin = min - (max - min) * 0.5;
    final totalMax = max + (max - min) * 0.5;
    final totalRange = totalMax - totalMin;

    // Calculate positions
    final optimalPosition = (optimal - totalMin) / totalRange;
    final worstPosition = (worst - totalMin) / totalRange;
    final valuePosition = (value - totalMin) / totalRange;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getRiskColor().withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    riskLevel.toUpperCase(),
                    style: Theme
                        .of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(
                      color: _getRiskColor(),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  value.toStringAsFixed(1),
                  style: Theme
                      .of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(
                    color: _getRiskColor(),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
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
              // Optimal marker
              Positioned(
                left: optimalPosition * MediaQuery
                    .of(context)
                    .size
                    .width * 0.8 - 1,
                top: 0,
                bottom: 0,
                child: Container(
                  width: 2,
                  color: Colors.green,
                ),
              ),
              // Worst marker
              Positioned(
                left: worstPosition * MediaQuery
                    .of(context)
                    .size
                    .width * 0.8 - 1,
                top: 0,
                bottom: 0,
                child: Container(
                  width: 2,
                  color: Colors.red,
                ),
              ),
              // Current value marker
              Positioned(
                left: valuePosition * MediaQuery
                    .of(context)
                    .size
                    .width * 0.8 - 8,
                top: 0,
                bottom: 0,
                child: Container(
                  width: 16,
                  decoration: BoxDecoration(
                    color: _getRiskColor(),
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
              'Optimal: ${optimal.toStringAsFixed(1)}',
              style: Theme
                  .of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(
                color: Colors.green,
              ),
            ),
            Text(
              'Worst: ${worst.toStringAsFixed(1)}',
              style: Theme
                  .of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(
                color: Colors.red,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
