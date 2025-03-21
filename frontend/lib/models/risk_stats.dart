import 'package:frontend/backend_controllers/backend_controller.dart';

class RiskStats {
  final List<dynamic> dayRisk;
  final List<dynamic> nightRisk;
  final List<dynamic> frostStress;
  final List<dynamic> droughtRisk;
  final List<dynamic> yieldRisk;
  final List<dynamic> recommendedProducts;

  RiskStats({
    required this.dayRisk,
    required this.nightRisk,
    required this.frostStress,
    required this.droughtRisk,
    required this.yieldRisk,
    required this.recommendedProducts,
  });

  // Factory method to create an instance from JSON
  factory RiskStats.fromJson(Map<String, dynamic> json) {
    return RiskStats(
      dayRisk: (json['daytime_heat_stress_risk'] as List<dynamic>?) ?? [],
      nightRisk: (json['nighttime_heat_stress_risk'] as List<dynamic>?) ?? [],
      frostStress: (json['frost_stress'] as List<dynamic>?) ?? [],
      droughtRisk: (json['drought_risk'] as List<dynamic>?) ?? [],
      yieldRisk: (json['yield_risk'] as List<dynamic>?) ?? [],
      recommendedProducts: List<dynamic>.from(json['recommended_products'] as List<dynamic>),
    );
  }

  // Method to convert an instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'dayRisk': dayRisk,
      'nightRisk': nightRisk,
      'frostStress': frostStress,
      'droughtRisk': droughtRisk,
      'yieldRisk': yieldRisk,
      'recommendedProducts': recommendedProducts,
    };
  }

  // Helper methods to get specific values from risk arrays
  String getRiskLevel(List<dynamic> riskArray) => riskArray.isNotEmpty ? riskArray[0].toString() : 'unknown';
  num getActualValue(List<dynamic> riskArray) => riskArray.length > 1 ? double.tryParse(riskArray[1].toString()) ?? 0.0 : 0.0;
  String getOptimalValue(List<dynamic> riskArray) => riskArray.length > 2 ? riskArray[2].toString() : '';
  String getWorstValue(List<dynamic> riskArray) => riskArray.length > 3 ? riskArray[3].toString() : '';

  // Risk level getters
  String get getDayRiskLevel => getRiskLevel(dayRisk);
  String get getNightRiskLevel => getRiskLevel(nightRisk);
  String get getFrostStressLevel => getRiskLevel(frostStress);
  String get getDroughtRiskLevel => getRiskLevel(droughtRisk);
  String get getYieldRiskLevel => getRiskLevel(yieldRisk);

  // Actual value getters
  num get getDayRiskValue => getActualValue(dayRisk);
  num get getNightRiskValue => getActualValue(nightRisk);
  num get getFrostStressValue => getActualValue(frostStress);
  num get getDroughtRiskValue => getActualValue(droughtRisk);
  num get getYieldRiskValue => getActualValue(yieldRisk);

  // Optimal value getters
  String get getDayRiskOptimal => getOptimalValue(dayRisk);
  String get getNightRiskOptimal => getOptimalValue(nightRisk);
  String get getFrostStressOptimal => getOptimalValue(frostStress);
  String get getDroughtRiskOptimal => getOptimalValue(droughtRisk);
  String get getYieldRiskOptimal => getOptimalValue(yieldRisk);

  // Worst value getters
  String get getDayRiskWorst => getWorstValue(dayRisk);
  String get getNightRiskWorst => getWorstValue(nightRisk);
  String get getFrostStressWorst => getWorstValue(frostStress);
  String get getDroughtRiskWorst => getWorstValue(droughtRisk);
  String get getYieldRiskWorst => getWorstValue(yieldRisk);

  // Raw data getters
  List<dynamic> get getDayRisk => dayRisk;
  List<dynamic> get getNightRisk => nightRisk;
  List<dynamic> get getFrostStress => frostStress;
  List<dynamic> get getDroughtRisk => droughtRisk;
  List<dynamic> get getYieldRisk => yieldRisk;
  List<dynamic> get getRecommendedProducts => recommendedProducts;

  @override
  String toString() {
    return '''RiskStats{
      dayRisk: $dayRisk,
      nightRisk: $nightRisk,
      frostStress: $frostStress,
      droughtRisk: $droughtRisk,
      yieldRisk: $yieldRisk,
      recommendedProducts: $recommendedProducts
    }''';
  }
}

Future<void> main() async {
  final result = await BackendController.getRiskStats(42.5, -5.2, 'cotton');
  print(result);
  print(result);
  print(result);
  print(result);
}
