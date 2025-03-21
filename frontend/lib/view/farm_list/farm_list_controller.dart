import 'package:flutter/material.dart';
import 'package:frontend/view/farm_list/crops.dart';

enum WeatherType {
  sunny,
  cloudy,
  rainy,
  stormy;

  String get backgroundImage {
    switch (this) {
      case WeatherType.sunny:
        return 'assets/images/weather/sunny.jpeg';
      case WeatherType.cloudy:
        return 'assets/images/weather/cloudy.jpeg';
      case WeatherType.rainy:
        return 'assets/images/weather/rainy.jpeg';
      case WeatherType.stormy:
        return 'assets/images/weather/stormy.jpeg';
    }
  }
}

class WeatherInfo {
  final WeatherType type;
  final double temperature;
  final int humidity;
  final double windSpeed;

  const WeatherInfo({
    required this.type,
    required this.temperature,
    required this.humidity,
    required this.windSpeed,
  });
}

class FarmHealth {
  final int overallScore;
  final String? alert;
  final bool hasRisk;

  const FarmHealth({
    required this.overallScore,
    this.alert,
    this.hasRisk = false,
  });
}

class Farm {
  final String name;
  final Crops crop;
  final FarmHealth health;
  final double latitude;
  final double longitude;

  const Farm({
    required this.name,
    required this.crop,
    required this.health,
    required this.latitude,
    required this.longitude,
  });
}

class FarmListController extends ChangeNotifier {
  // Mocked weather data
  WeatherInfo get currentWeather => WeatherInfo(
    type: WeatherType.stormy,
    temperature: 24.5,
    humidity: 65,
    windSpeed: 12.3,
  );

  // Mocked farms data
  List<Farm> get farms => [
    Farm(
      name: 'Green Valley Farm',
      crop: Crops.corn,
      health: FarmHealth(overallScore: 85, hasRisk: false),
      latitude: 42.3601,
      longitude: -71.0589,
    ),
    Farm(
      name: 'Sunset Fields',
      crop: Crops.soybean,
      health: FarmHealth(
        overallScore: 65,
        alert: 'High pest risk detected',
        hasRisk: true,
      ),
      latitude: 40.7128,
      longitude: -74.0060,
    ),
    Farm(
      name: 'Cotton Hills',
      crop: Crops.cotton,
      health: FarmHealth(overallScore: 92, hasRisk: false),
      latitude: 34.0522,
      longitude: -118.2437,
    ),
  ];
}
