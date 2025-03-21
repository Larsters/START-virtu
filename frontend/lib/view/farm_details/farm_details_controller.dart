import 'package:flutter/material.dart';
import 'package:frontend/backend_controllers/backend_controller.dart';
import 'package:frontend/models/current_weather.dart';
import 'package:frontend/models/risk_stats.dart';
import 'package:frontend/models/soil_data.dart';
import 'package:frontend/services/preferences_manager.dart';
import 'package:frontend/view/debug/debug_controller.dart';
import 'package:frontend/view/farm_details/models/product.dart';
import 'package:frontend/view/farm_details/models/risk.dart';
import 'package:frontend/view/farm_details/models/risk_type.dart';
import 'package:frontend/view/farm_list/crop_type.dart';

class ProductUsage {
  final Product product;
  final DateTime date;

  const ProductUsage({required this.product, required this.date});

  // Convert ProductUsage to JSON
  Map<String, dynamic> toJson() {
    return {'product': product.name, 'date': date.toIso8601String()};
  }

  // Create ProductUsage from JSON
  factory ProductUsage.fromJson(Map<String, dynamic> json) {
    return ProductUsage(
      product: Product.values.firstWhere(
        (p) => p.name == json['product'],
        orElse: () => Product.stressBooster, // Fallback value
      ),
      date: DateTime.parse(json['date'] as String),
    );
  }
}

class HarvestData {
  final double harvestedAmount;
  final bool hadDiseases;
  final String? diseaseNotes;
  final List<ProductUsage> usedProducts;

  const HarvestData({
    required this.harvestedAmount,
    required this.hadDiseases,
    this.diseaseNotes,
    required this.usedProducts,
  });

  // Convert HarvestData to JSON
  Map<String, dynamic> toJson() {
    return {
      'harvestedAmount': harvestedAmount,
      'hadDiseases': hadDiseases,
      'diseaseNotes': diseaseNotes,
      'usedProducts': usedProducts.map((p) => p.toJson()).toList(),
    };
  }

  // Create HarvestData from JSON
  factory HarvestData.fromJson(Map<String, dynamic> json) {
    return HarvestData(
      harvestedAmount: json['harvestedAmount'] as double,
      hadDiseases: json['hadDiseases'] as bool,
      diseaseNotes: json['diseaseNotes'] as String?,
      usedProducts:
          (json['usedProducts'] as List)
              .map((p) => ProductUsage.fromJson(p as Map<String, dynamic>))
              .toList(),
    );
  }
}

class FarmDetailsController extends ChangeNotifier {
  final String farmName;
  CropType? _cropType;
  final double latitude;
  final double longitude;
  List<Risk> _risks;
  List<Product> _recommendedProducts = [];
  final List<ProductUsage> usedProducts;
  HarvestData? lastHarvestData;

  // New state variables for API data
  bool _isLoading = true;
  RiskStats? _riskStats;
  SoilData? _soilData;
  CurrentWeather? _weatherData;
  String? _error;

  final PreferencesManager _prefsManager = PreferencesManager();

  // Getters for the new state
  bool get isLoading => _isLoading;

  RiskStats? get riskStats => _riskStats;

  SoilData? get soilData => _soilData;

  CurrentWeather? get weatherData => _weatherData;

  String? get error => _error;
  CropType? get cropType => _cropType;

  List<Risk> get risks => _risks;

  FarmDetailsController({
    required this.farmName,
    required CropType? cropType,
    required this.latitude,
    required this.longitude,
  }) : _cropType = cropType,
       _risks =
           cropType == null
               ? []
               : [
                 Risk(
                   type: RiskType.dayHeating,
                   value: 28.5,
                   min: 20.0,
                   max: 30.0,
                 ),
                 Risk(
                   type: RiskType.nightHeating,
                   value: 15.0,
                   min: 12.0,
                   max: 18.0,
                 ),
                 Risk(type: RiskType.frost, value: 2.0, min: 0.0, max: 5.0),
                 Risk(
                   type: RiskType.drought,
                   value: 75.0,
                   min: 40.0,
                   max: 60.0,
                 ),
                 Risk(type: RiskType.yiel, value: 85.0, min: 70.0, max: 100.0),
               ],
       usedProducts = [] {
    // Load saved data and then fetch new data
    _loadSavedData().then((_) => _fetchData());
  }

  // Load saved data from PreferencesManager
  Future<void> _loadSavedData() async {
    try {
      // Load used products
      final savedProducts = await _prefsManager.getUsedProducts(
        farmName,
        latitude,
        longitude,
      );
      usedProducts.addAll(savedProducts);

      // Load last harvest data
      lastHarvestData = await _prefsManager.getLastHarvest(
        farmName,
        latitude,
        longitude,
      );
    } catch (e) {
      debugPrint('Error loading saved data: $e');
    }
  }

  // Save data using PreferencesManager
  Future<void> _saveData() async {
    try {
      await _prefsManager.saveUsedProducts(
        farmName,
        latitude,
        longitude,
        usedProducts,
      );

      await _prefsManager.saveLastHarvest(
        farmName,
        latitude,
        longitude,
        lastHarvestData,
      );
    } catch (e) {
      debugPrint('Error saving data: $e');
    }
  }

  // Method to fetch all required data
  Future<void> _fetchData() async {
    if (_cropType == null) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

      // Fetch all data in parallel
      final results = await Future.wait([
        BackendController.getRiskStats(
          latitude,
          longitude,
          _cropType!.name.toLowerCase(),
        ),
        BackendController.getSoilData(latitude, longitude),
        BackendController.getWeatherData(latitude, longitude),
      ]);

      _riskStats = results[0] as RiskStats;
      _soilData = results[1] as SoilData;
      _weatherData = results[2] as CurrentWeather;

      // Update recommended products based on risk stats
      _recommendedProducts =
          _riskStats?.recommendedProducts
              .map((p) => _stringToProduct(p as String))
              .where((p) => p != null)
              .cast<Product>()
              .toList() ??
          [];
      _isLoading = false;
      notifyListeners();
  }

  // Helper method to convert string to Product enum
  Product? _stringToProduct(String productName) {
    try {
      return Product.values.firstWhere(
        (p) => p.name.toLowerCase() == productName.toLowerCase(),
      );
    } catch (e) {
      return null;
    }
  }

  // Get recommended products that haven't been used yet
  List<Product> get activeRecommendedProducts {
    final usedProductTypes = usedProducts.map((usage) => usage.product).toSet();
    return _recommendedProducts
        .where((product) => !usedProductTypes.contains(product))
        .toList();
  }

  bool get isHarvestTime {
    if (cropType == null) return false;

    // Check debug override first
    if (DebugController().forceHarvestTime) return true;

    final now = DateTime.now();
    final month = now.month;

    // Simple season check (can be made more sophisticated)
    return (month == 2 || month == 5 || month == 8 || month == 11);
  }

  Future<void> recordProductUsage(Product product, DateTime date) async {
    usedProducts.add(ProductUsage(product: product, date: date));
    await _saveData();
    notifyListeners();
  }

  Future<void> recordHarvest(
    double harvestedAmount,
    bool hadDiseases,
    String? diseaseNotes,
  ) async {
    lastHarvestData = HarvestData(
      harvestedAmount: harvestedAmount,
      hadDiseases: hadDiseases,
      diseaseNotes: diseaseNotes,
      usedProducts: List.from(usedProducts),
    );
    // Clear current crop data
    _cropType = null;
    _risks = [];
    _recommendedProducts = [];
    usedProducts.clear();
    await _saveData();
    notifyListeners();
  }

  Future<void> plantNewCrop(CropType crop) async {
    _cropType = crop;
    usedProducts.clear();
    await _prefsManager.clearFarmData(farmName, latitude, longitude);
    // Fetch new data for the new crop
    await _fetchData();
  }

  // Method to refresh data
  Future<void> refreshData() async {
    await _fetchData();
  }
}
