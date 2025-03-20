import 'package:flutter/material.dart';

enum SeedType {
  corn,
  soybean,
  cotton;

  String get name {
    switch (this) {
      case SeedType.corn:
        return 'Corn';
      case SeedType.soybean:
        return 'Soybean';
      case SeedType.cotton:
        return 'Cotton';
    }
  }

  IconData get icon {
    switch (this) {
      case SeedType.corn:
        return Icons.grass;
      case SeedType.soybean:
        return Icons.eco;
      case SeedType.cotton:
        return Icons.spa;
    }
  }
}

class FarmWidget extends StatelessWidget {
  final SeedType seedType;
  final double progress; // 0-100 value
  final Color color;

  const FarmWidget({
    super.key,
    required this.seedType,
    required this.progress,
    this.color = Colors.green,
  }) : assert(progress >= 0 && progress <= 100, 'Progress must be between 0 and 100');

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            seedType.name,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              seedType.icon,
              color: color,
              size: 40,
            ),
          ),
          const SizedBox(height: 8),
          // Progress bar
          Container(
            height: 10,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              color: Colors.grey[200],
            ),
            child: FractionallySizedBox(
              widthFactor: progress / 100,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  color: color,
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${progress.toStringAsFixed(1)}%',
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
} 