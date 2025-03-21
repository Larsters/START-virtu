import 'package:flutter/foundation.dart';
import 'package:frontend/models/farm.dart';
import 'package:frontend/models/weather.dart';
import 'package:frontend/services/app_data_manager.dart';
import 'package:frontend/view/farm_list/crop_type.dart';
import 'package:frontend/view/farm_list/farm_location.dart';

class FarmDataController extends ChangeNotifier {
  final AppDataManager _appDataManager = AppDataManager();
  List<Farm> _farms = [];

  List<Farm> get farms => List.unmodifiable(_farms);

  // Mocked weather data
  WeatherInfo get currentWeather => WeatherInfo(
    type: WeatherType.stormy,
    temperature: 24.5,
    humidity: 65,
    windSpeed: 12.3,
  );

  FarmDataController() {
    _loadFarms();
  }

  Future<void> _loadFarms() async {
    try {
      final farmLocations = await _appDataManager.loadFarmLocations();
      _farms = [];

      for (var entry in farmLocations.entries) {
        for (var location in entry.value) {
          _farms.add(
            Farm(
              name: location.name,
              type: location.crop,
              latitude: location.latitude,
              longitude: location.longitude,
              healthScore: 85, // Default health score
            ),
          );
        }
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading farms: $e');
    }
  }

  Future<void> _saveFarms() async {
    try {
      final Map<CropType, List<FarmLocation>> farmLocations = {};

      for (var farm in _farms) {
        farmLocations.putIfAbsent(farm.type, () => []);
        farmLocations[farm.type]!.add(
          FarmLocation(
            name: farm.name,
            crop: farm.type,
            latitude: farm.latitude,
            longitude: farm.longitude,
          ),
        );
      }

      await _appDataManager.saveFarmLocations(farmLocations);
    } catch (e) {
      debugPrint('Error saving farms: $e');
    }
  }

  Future<void> addFarm(Farm farm) async {
    _farms.add(farm);
    await _saveFarms();
    notifyListeners();
  }

  Future<void> updateFarm(Farm oldFarm, Farm newFarm) async {
    final index = _farms.indexWhere(
      (f) =>
          f.name == oldFarm.name &&
          f.latitude == oldFarm.latitude &&
          f.longitude == oldFarm.longitude,
    );

    if (index != -1) {
      _farms[index] = newFarm;
      await _saveFarms();
      notifyListeners();
    }
  }

  Future<void> deleteFarm(Farm farm) async {
    _farms.removeWhere(
      (f) =>
          f.name == farm.name &&
          f.latitude == farm.latitude &&
          f.longitude == farm.longitude,
    );
    await _saveFarms();
    notifyListeners();
  }

  Farm? getFarmByLocation(double latitude, double longitude) {
    try {
      return _farms.firstWhere(
        (farm) => farm.latitude == latitude && farm.longitude == longitude,
      );
    } catch (e) {
      return null;
    }
  }

  List<Farm> getFarmsByCrop(CropType crop) {
    return _farms.where((farm) => farm.type == crop).toList();
  }
}
