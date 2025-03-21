import 'package:frontend/view/farm_list/crop_type.dart';

class Farm {
  final String name;
  final CropType type;
  final double latitude;
  final double longitude;
  final int healthScore;
  final String? alert;
  final bool hasRisk;

  const Farm({
    required this.name,
    required this.type,
    required this.latitude,
    required this.longitude,
    required this.healthScore,
    this.alert,
    this.hasRisk = false,
  });

  // Getters
  String get getName => name;
  CropType get getCropType => type;
  double get getLatitude => latitude;
  double get getLongitude => longitude;
  int get getHealthScore => healthScore;
  String? get getAlert => alert;
  bool get getHasRisk => hasRisk;

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'crop': type.name,
      'latitude': latitude,
      'longitude': longitude,
      'healthScore': healthScore,
      'alert': alert,
      'hasRisk': hasRisk,
    };
  }

  factory Farm.fromJson(Map<String, dynamic> json) {
    return Farm(
      name: json['name'] as String,
      type: CropType.values.firstWhere((crop) => crop.name == json['crop']),
      latitude: json['latitude'] as double,
      longitude: json['longitude'] as double,
      healthScore: json['healthScore'] as int,
      alert: json['alert'] as String?,
      hasRisk: json['hasRisk'] as bool? ?? false,
    );
  }

}
