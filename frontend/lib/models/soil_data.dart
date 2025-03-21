class SoilData {
  final double soilMoisture;
  final double soilPh;
  final double soilNitrogenContent;

  SoilData({
    required this.soilMoisture,
    required this.soilPh,
    required this.soilNitrogenContent,
  });

  // Factory constructor to create SoilData from JSON
  factory SoilData.fromJson(Map<String, dynamic> json) {
    return SoilData(
      soilMoisture: double.tryParse(json['soil_moisture'] as String? ?? '0') ?? 0.0,
      soilPh: double.tryParse(json['soil_ph'] as String? ?? '0') ?? 0.0,
      soilNitrogenContent: double.tryParse(json['soil_nitrogen_content'] as String? ?? '0') ?? 0.0,
    );
  }

  // Method to convert SoilData to JSON
  Map<String, dynamic> toJson() {
    return {
      'soil_moisture': soilMoisture,
      'soil_ph': soilPh,
      'soil_nitrogen_content': soilNitrogenContent,
    };
  }

  @override
  String toString() {
    return '''SoilData{
      soil_moisture: $soilMoisture,
      soil_ph: $soilPh,
      soil_nitrogen_content: $soilNitrogenContent
    }''';
  }

  // Getters
  double get getSoilMoisture => soilMoisture;
  double get getSoilPh => soilPh;
  double get getSoilNitrogenContent => soilNitrogenContent;
}
