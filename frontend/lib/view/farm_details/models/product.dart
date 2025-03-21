import 'package:flutter/material.dart';

enum Product {
  stressBooster(
    'Stress Booster',
    Icons.healing,
    'High stress levels detected. Apply stress booster to improve crop resilience.',
  ),
  nutrientBooster(
    'Nutrient Booster',
    Icons.local_florist,
    'Low nutrient levels detected. Apply nutrient booster to enhance growth.',
  ),
  yieldBooster(
    'Yield Booster',
    Icons.trending_up,
    'Suboptimal yield conditions detected. Apply yield booster to maximize production.',
  );

  final String displayName;
  final IconData icon;
  final String alertText;

  const Product(this.displayName, this.icon, this.alertText);
}
