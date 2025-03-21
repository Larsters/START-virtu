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

  // Factory constructor to create SoilData from JSON
  factory CurrentWeather.fromJson(Map<String, dynamic> json) {
    return CurrentWeather(
      latitude: json['latitude'] as double,
      longitude: json['longitude'] as double,
      temperature: json['temperature'] as double,
      temperature_felt: json['temperature_felt'] as double,
      wind_speed: json['wind_speed'] as double,
      wind_direction: json['v'] as String,
      humidity: json['humidity'] as double,
      air_pressure: json['air_pressure'] as double,
    );
  }

  // Method to convert SoilData to JSON
  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'temperature': temperature,
      'temperature_felt': temperature_felt,
      'wind_speed': wind_speed,
      'wind_direction': wind_direction,
      'humidity': humidity,
      'air_pressure': air_pressure,
    };
  }
}
