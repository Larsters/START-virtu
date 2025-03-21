import 'dart:convert';

import 'package:frontend/view/farm_details/farm_details_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PreferencesManager {
  static const String _hasCompletedSurveyKey = 'has_completed_survey';
  static const String _usedProductsKeyPrefix = 'used_products';
  static const String _lastHarvestKeyPrefix = 'last_harvest';

  static final PreferencesManager _instance = PreferencesManager._internal();

  factory PreferencesManager() {
    return _instance;
  }

  PreferencesManager._internal();

  Future<bool> hasCompletedSurvey() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_hasCompletedSurveyKey) ?? false;
  }

  Future<void> setCompletedSurvey(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_hasCompletedSurveyKey, value);
  }

  String _getFarmKey(String farmName, double latitude, double longitude) {
    return '${farmName}_${latitude}_${longitude}';
  }

  Future<List<ProductUsage>> getUsedProducts(
    String farmName,
    double latitude,
    double longitude,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final key =
        '${_usedProductsKeyPrefix}_${_getFarmKey(farmName, latitude, longitude)}';
    final savedData = prefs.getString(key);

    if (savedData == null) return [];

    try {
      final List<dynamic> productsList = jsonDecode(savedData) as List<dynamic>;
      return productsList
          .map((p) => ProductUsage.fromJson(p as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> saveUsedProducts(
    String farmName,
    double latitude,
    double longitude,
    List<ProductUsage> products,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final key =
        '${_usedProductsKeyPrefix}_${_getFarmKey(farmName, latitude, longitude)}';
    final data = jsonEncode(products.map((p) => p.toJson()).toList());
    await prefs.setString(key, data);
  }

  Future<HarvestData?> getLastHarvest(
    String farmName,
    double latitude,
    double longitude,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final key =
        '${_lastHarvestKeyPrefix}_${_getFarmKey(farmName, latitude, longitude)}';
    final savedData = prefs.getString(key);

    if (savedData == null) return null;

    try {
      final Map<String, dynamic> harvestData =
          jsonDecode(savedData) as Map<String, dynamic>;
      return HarvestData.fromJson(harvestData);
    } catch (e) {
      return null;
    }
  }

  Future<void> saveLastHarvest(
    String farmName,
    double latitude,
    double longitude,
    HarvestData? harvest,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final key =
        '${_lastHarvestKeyPrefix}_${_getFarmKey(farmName, latitude, longitude)}';

    if (harvest == null) {
      await prefs.remove(key);
    } else {
      final data = jsonEncode(harvest.toJson());
      await prefs.setString(key, data);
    }
  }

  Future<void> clearFarmData(
    String farmName,
    double latitude,
    double longitude,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final farmKey = _getFarmKey(farmName, latitude, longitude);
    await prefs.remove('${_usedProductsKeyPrefix}_$farmKey');
    await prefs.remove('${_lastHarvestKeyPrefix}_$farmKey');
  }

  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
