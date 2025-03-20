import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:frontend/view/welcome_survey/models/crops.dart';
import 'package:frontend/view/welcome_survey/models/farm_location.dart';
import 'package:path_provider/path_provider.dart';

class AppDataManager {
  static const String _fileName = 'app_data.json';

  static final AppDataManager _instance = AppDataManager._internal();

  factory AppDataManager() {
    return _instance;
  }

  AppDataManager._internal();

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    final file = File('$path/$_fileName');

    // Create the file if it doesn't exist
    if (!await file.exists()) {
      await file.create(recursive: true);
      // Initialize with empty data structure
      await file.writeAsString(jsonEncode({'cropLocations': {}}));
    }

    return file;
  }

  Future<void> saveFarmLocations(
    Map<Crops, List<FarmLocation>> cropLocations,
  ) async {
    try {
      final file = await _localFile;

      // Convert the data to a format that can be serialized
      final data = {
        'cropLocations': cropLocations.map(
          (crop, locations) => MapEntry(
            crop.name,
            locations.map((loc) => loc.toJson()).toList(),
          ),
        ),
      };

      await file.writeAsString(jsonEncode(data));
    } catch (e) {
      debugPrint('Error saving farm locations: $e');
      rethrow;
    }
  }

  Future<Map<Crops, List<FarmLocation>>> loadFarmLocations() async {
    try {
      final file = await _localFile;
      final String contents = await file.readAsString();

      if (contents.isEmpty) {
        return {};
      }

      final Map<String, dynamic> data =
          jsonDecode(contents) as Map<String, dynamic>;

      if (!data.containsKey('cropLocations')) {
        return {};
      }

      final Map<Crops, List<FarmLocation>> cropLocations = {};

      final locationsData = data['cropLocations'] as Map<String, dynamic>;

      for (final entry in locationsData.entries) {
        final crop = Crops.values.firstWhere((c) => c.name == entry.key);
        final locationsList = entry.value as List;

        cropLocations[crop] =
            locationsList
                .map(
                  (loc) => FarmLocation.fromJson(loc as Map<String, dynamic>),
                )
                .toList();
      }

      return cropLocations;
    } catch (e) {
      debugPrint('Error loading farm locations: $e');
      return {};
    }
  }

  Future<void> clearData() async {
    try {
      final file = await _localFile;
      await file.writeAsString(jsonEncode({'cropLocations': {}}));
    } catch (e) {
      debugPrint('Error clearing data: $e');
      rethrow;
    }
  }
}
