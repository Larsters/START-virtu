import 'package:flutter/material.dart';
import 'package:frontend/view/debug/debug_controller.dart';
import 'package:frontend/view/farm_details/models/product.dart';
import 'package:frontend/view/farm_details/models/risk.dart';
import 'package:frontend/view/farm_details/models/risk_type.dart';
import 'package:frontend/view/farm_list/crop_type.dart';

class ProductUsage {
  final Product product;
  final DateTime date;

  const ProductUsage({required this.product, required this.date});
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
}

class FarmDetailsController extends ChangeNotifier {
  final String farmName;
  CropType? _cropType;
  final double latitude;
  final double longitude;
  List<Risk> _risks;
  List<Product> _recommendedProducts;
  final List<ProductUsage> usedProducts;
  HarvestData? lastHarvestData;

  CropType? get cropType => _cropType;

  List<Risk> get risks => _risks;

  List<Product> get recommendedProducts => _recommendedProducts;

  FarmDetailsController({
    required this.farmName,
    required CropType? cropType,
    required this.latitude,
    required this.longitude,
  })
      : _cropType = cropType,
        _risks = cropType == null
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
        _recommendedProducts = cropType == null
            ? []
            : [Product.stressBooster, Product.nutrientBooster],
        usedProducts = [];

  // Get recommended products that haven't been used yet
  List<Product> get activeRecommendedProducts {
    final usedProductTypes = usedProducts.map((usage) => usage.product).toSet();
    return recommendedProducts
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
    notifyListeners();
  }

  Future<void> plantNewCrop(CropType crop) async {
    _cropType = crop;
    _risks = [
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
    ];
    _recommendedProducts = [Product.stressBooster, Product.nutrientBooster];
    lastHarvestData = null;
    notifyListeners();
  }
}
