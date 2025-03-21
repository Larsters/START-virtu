class CurrentWeather {
  final double latitude;
  final double longitude;
  final double temperature;
  final double temperature_felt;
  final double wind_speed;
  final String wind_direction;
  final double humidity;
  final double air_pressure;

  CurrentWeather({
    required this.latitude,
    required this.longitude,
    required this.temperature,
    required this.temperature_felt,
    required this.wind_speed,
    required this.wind_direction,
    required this.humidity,
    required this.air_pressure
  });

  // Factory constructor to create CurrentWeather from JSON
  factory CurrentWeather.fromJson(Map<String, dynamic> json) {
    return CurrentWeather(
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      temperature: double.tryParse(json['temperature'] as String? ?? '0') ?? 0.0,
      temperature_felt: double.tryParse(json['temperature_felt'] as String? ?? '0') ?? 0.0,
      wind_speed: double.tryParse(json['wind_speed'] as String? ?? '0') ?? 0.0,
      wind_direction: json['wind_direction'] as String? ?? 'N/A',
      humidity: double.tryParse(json['humidity'] as String? ?? '0') ?? 0.0,
      air_pressure: double.tryParse(json['air_pressure'] as String? ?? '0') ?? 0.0,
    );
  }

  // Method to convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'temperature': temperature.toString(),
      'temperature_felt': temperature_felt.toString(),
      'wind_speed': wind_speed.toString(),
      'wind_direction': wind_direction,
      'humidity': humidity.toString(),
      'air_pressure': air_pressure.toString(),
    };
  }

  @override
  String toString() {
    return '''CurrentWeather{
      latitude: $latitude,
      longitude: $longitude,
      temperature: $temperature,
      temperature_felt: $temperature_felt,
      wind_speed: $wind_speed,
      wind_direction: $wind_direction,
      humidity: $humidity,
      air_pressure: $air_pressure
    }''';
  }

  // Getters
  double get getLatitude => latitude;
  double get getLongitude => longitude;
  double get getTemperature => temperature;
  double get getTemperatureFelt => temperature_felt;
  double get getWindSpeed => wind_speed;
  String get getWindDirection => wind_direction;
  double get getHumidity => humidity;
  double get getAirPressure => air_pressure;
}
