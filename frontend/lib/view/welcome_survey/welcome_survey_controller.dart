import 'package:flutter/material.dart';
import 'package:frontend/services/app_data_manager.dart';
import 'package:frontend/services/preferences_manager.dart';
import 'package:frontend/view/farm_list/crops.dart';
import 'package:frontend/view/farm_list/farm_location.dart';

class WelcomeSurveyController extends ChangeNotifier {
  // Selected crops and their locations
  final Map<Crops, List<FarmLocation>> _cropLocations = {};

  // Currently expanded crop
  Crops? _expandedCrop;

  // Form controllers for new location
  final TextEditingController nameController = TextEditingController();
  final TextEditingController latitudeController = TextEditingController();
  final TextEditingController longitudeController = TextEditingController();

  WelcomeSurveyController() {
    // Add listeners to all text controllers
    nameController.addListener(_onFormChanged);
    latitudeController.addListener(_onFormChanged);
    longitudeController.addListener(_onFormChanged);

    // Load existing data
    _loadSavedData();
  }

  Future<void> _loadSavedData() async {
    try {
      final savedLocations = await AppDataManager().loadFarmLocations();
      _cropLocations.clear();
      _cropLocations.addAll(savedLocations);
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading saved data: $e');
    }
  }

  // Getters
  Map<Crops, List<FarmLocation>> get cropLocations => _cropLocations;

  Crops? get expandedCrop => _expandedCrop;

  List<FarmLocation> getLocationsForCrop(Crops crop) =>
      _cropLocations[crop] ?? [];

  bool isCropSelected(Crops crop) =>
      _cropLocations.containsKey(crop) && _cropLocations[crop]!.isNotEmpty;

  void _onFormChanged() {
    notifyListeners();
  }

  void toggleCropExpansion(Crops crop) {
    _expandedCrop = _expandedCrop == crop ? null : crop;
    notifyListeners();
  }

  void addLocation(Crops crop) {
    if (!isValidForm()) return;

    final location = FarmLocation(
      crop: crop,
      name: nameController.text,
      latitude: double.parse(latitudeController.text),
      longitude: double.parse(longitudeController.text),
    );

    if (!_cropLocations.containsKey(crop)) {
      _cropLocations[crop] = [];
    }
    _cropLocations[crop]!.add(location);

    // Clear form
    nameController.clear();
    latitudeController.clear();
    longitudeController.clear();

    notifyListeners();
  }

  void removeLocation(Crops crop, int index) {
    if (_cropLocations.containsKey(crop)) {
      _cropLocations[crop]!.removeAt(index);
      if (_cropLocations[crop]!.isEmpty) {
        _cropLocations.remove(crop);
      }
      notifyListeners();
    }
  }

  bool isValidForm() {
    if (nameController.text.isEmpty) return false;

    try {
      final lat = double.parse(latitudeController.text);
      final lon = double.parse(longitudeController.text);

      return lat >= -90 && lat <= 90 && lon >= -180 && lon <= 180;
    } catch (_) {
      return false;
    }
  }

  bool canProceed() {
    return _cropLocations.isNotEmpty;
  }

  Future<void> saveSurveyData() async {
    try {
      // Save locations to file
      await AppDataManager().saveFarmLocations(_cropLocations);

      // Mark survey as completed
      await PreferencesManager().setCompletedSurvey(true);
    } catch (e) {
      debugPrint('Error saving survey data: $e');
      rethrow;
    }
  }

  @override
  void dispose() {
    nameController.removeListener(_onFormChanged);
    latitudeController.removeListener(_onFormChanged);
    longitudeController.removeListener(_onFormChanged);

    nameController.dispose();
    latitudeController.dispose();
    longitudeController.dispose();
    super.dispose();
  }
}
