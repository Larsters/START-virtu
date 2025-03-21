import 'package:frontend/view/farm_details/models/risk_type.dart';

class Risk {
  final RiskType type;
  final double value;
  final double min;
  final double max;

  const Risk({
    required this.type,
    required this.value,
    required this.min,
    required this.max,
  });

  bool get isWithinOptimalRange => value >= min && value <= max;
}
