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
