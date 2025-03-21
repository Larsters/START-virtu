import 'package:flutter/foundation.dart';
import 'package:frontend/models/farm.dart';
import 'package:frontend/models/current_weather.dart';
import 'package:frontend/services/app_data_manager.dart';
import 'package:frontend/view/farm_list/crop_type.dart';
import 'package:frontend/view/farm_list/farm_location.dart';
import 'package:frontend/backend_controllers/backend_controller.dart';

class FarmDataController extends ChangeNotifier {
  final AppDataManager _appDataManager = AppDataManager();
  List<Farm> _farms = [];
  CurrentWeather? _currentWeather;
  bool _isLoadingWeather = true;
  String? _weatherError;

  List<Farm> get farms => List.unmodifiable(_farms);
  CurrentWeather? get currentWeather => _currentWeather;
  bool get isLoadingWeather => _isLoadingWeather;
  String? get weatherError => _weatherError;

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
      
      // After loading farms, fetch weather data if we have farms
      if (_farms.isNotEmpty) {
        await _loadWeatherData();
      }
    } catch (e) {
      debugPrint('Error loading farms: $e');
    }
  }

  Future<void> _loadWeatherData() async {
    _isLoadingWeather = true;
    _weatherError = null;
    notifyListeners();

    try {
      final weather = await BackendController.getWeatherData(
        _farms[0].latitude,
        _farms[0].longitude,
      );
      _currentWeather = weather;
    } catch (e) {
      _weatherError = 'Failed to load weather data: $e';
      debugPrint('Error loading weather: $e');
    } finally {
      _isLoadingWeather = false;
      notifyListeners();
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

  Future<void> refresh() async {
    await _loadFarms();
  }
}
