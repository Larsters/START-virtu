import 'package:flutter/material.dart';

class CropProductRecommendations extends StatelessWidget {
  const CropProductRecommendations({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Text(
            'Recommended Actions',
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        Row(
          children: [
            Expanded(
              child: _RecommendationCard(
                title: 'Stress Buster',
                icon: Icons.healing,
                color: Colors.blue[100]!,
                iconColor: Colors.blue,
                onTap: () {
                  // Handle stress buster tap
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _RecommendationCard(
                title: 'Nutrient Booster',
                icon: Icons.local_florist,
                color: Colors.green[100]!,
                iconColor: Colors.green,
                onTap: () {
                  // Handle nutrient booster tap
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _RecommendationCard(
                title: 'Yield Booster',
                icon: Icons.trending_up,
                color: Colors.orange[100]!,
                iconColor: Colors.orange,
                onTap: () {
                  // Handle yield booster tap
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _RecommendationCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final Color iconColor;
  final VoidCallback onTap;

  const _RecommendationCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 32, color: iconColor),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
