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
      soilMoisture: json['soil_moisture'] as double,
      soilPh: json['soil_ph'] as double,
      soilNitrogenContent: json['soil_nitrogen_content'] as double,
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
}
