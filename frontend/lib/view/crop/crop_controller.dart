import 'package:flutter/material.dart';

import '../welcome_survey/models/crops.dart';

class CropRisk {
  final String name;
  final double percentage;
  final String description;

  const CropRisk({
    required this.name,
    required this.percentage,
    required this.description,
  });
}

class SoilHealthFactor {
  final String name;
  final double percentage;
  final String description;

  const SoilHealthFactor({
    required this.name,
    required this.percentage,
    required this.description,
  });
}

class CropController extends ChangeNotifier {
  final Crops crop;

  CropController({required this.crop});

  // Mocked risks data
  List<CropRisk> get risks => [
    CropRisk(
      name: 'Fungal Disease',
      percentage: 75.0,
      description:
          'High risk of fungal infection due to recent weather conditions',
    ),
    CropRisk(
      name: 'Pest Infestation',
      percentage: 30.0,
      description: 'Moderate risk of pest damage in the area',
    ),
    CropRisk(
      name: 'Root Rot',
      percentage: 15.0,
      description: 'Low risk of root rot based on soil conditions',
    ),
    CropRisk(
      name: 'Nutrient Deficiency',
      percentage: 45.0,
      description: 'Medium risk of nutrient deficiency',
    ),
  ];

  // Mocked soil health data
  List<SoilHealthFactor> get soilHealth => [
    SoilHealthFactor(
      name: 'Soil Moisture',
      percentage: 65.0,
      description: 'Adequate moisture levels for growth',
    ),
    SoilHealthFactor(
      name: 'Nutrient Content',
      percentage: 40.0,
      description: 'Below optimal nutrient levels',
    ),
    SoilHealthFactor(
      name: 'pH Balance',
      percentage: 85.0,
      description: 'Optimal pH range for crop growth',
    ),
    SoilHealthFactor(
      name: 'Organic Matter',
      percentage: 55.0,
      description: 'Moderate organic matter content',
    ),
  ];
}
