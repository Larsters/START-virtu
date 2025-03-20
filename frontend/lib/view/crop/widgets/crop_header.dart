import 'package:flutter/material.dart';
import 'package:frontend/view/welcome_survey/models/crops.dart';

class CropHeader extends StatelessWidget {
  final Crops crop;

  const CropHeader({super.key, required this.crop});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Color(crop.color),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.asset(
                crop.imagePath,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(Icons.grass, size: 64);
                },
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black.withAlpha(80)],
              ),
            ),
          ),
          Positioned(
            left: 16,
            bottom: 16,
            child: Text(
              crop.displayName,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
