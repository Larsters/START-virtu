import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/controllers/farm_data_controller.dart';
import 'package:frontend/models/farm.dart';
import 'package:frontend/view/farm_list/crop_type.dart';
import 'package:frontend/view/map/create_farm_view.dart';
import 'package:frontend/view/map/map_controller.dart';
import 'package:maplibre/maplibre.dart';
import 'package:provider/provider.dart';

@immutable
class MapView extends StatefulWidget {
  const MapView({super.key});

  @override
  State<MapView> createState() => _MyMapWidget();
}

class FarmPoint extends Point {
  final CropType cropType;
  final String name;

  FarmPoint({
    required Position coordinates,
    required this.cropType,
    required this.name,
  }) : super(coordinates: coordinates);

  String get iconKey {
    switch (cropType) {
      case CropType.soybean:
        return 'farm-soybean';
      case CropType.corn:
        return 'farm-corn';
      case CropType.cotton:
        return 'farm-cotton';
    }
  }
}

class _MyMapWidget extends State<MapView> {
  MapController? _mapController;
  final LocationController _locationController = LocationController();
  Position? _currentPosition;

  @override
  void initState() {
    super.initState();
    _loadCurrentPosition();
  }

  Future<void> _addCustomImage(StyleController styleController) async {
    try {
      final Map<String, String> farmIcons = {
        'farm-corn': 'assets/images/farm_icons/corn_icon.png',
        'farm-soybean': 'assets/images/farm_icons/soybean_icon.png',
        'farm-cotton': 'assets/images/farm_icons/cotton_icon.png',
      };

      for (var entry in farmIcons.entries) {
        final ByteData data = await rootBundle.load(entry.value);
        final Uint8List imageData = data.buffer.asUint8List();
        await styleController.addImage(entry.key, imageData);
      }
    } catch (e) {
      debugPrint('Error adding images: $e');
    }
  }

  Future<void> _loadCurrentPosition() async {
    try {
      final position = await _locationController.getCurrentPosition();
      setState(() {
        _currentPosition = position;
      });
    } catch (e) {
      debugPrint('Error getting location: $e');
    }
  }

  String _getIconKey(CropType cropType) {
    switch (cropType) {
      case CropType.soybean:
        return 'farm-soybean';
      case CropType.corn:
        return 'farm-corn';
      case CropType.cotton:
        return 'farm-cotton';
    }
  }

  Future<void> _showDeleteConfirmation(BuildContext context, Farm farm) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) =>
          AlertDialog(
            title: const Text('Delete Farm'),
            content: Text('Are you sure you want to delete "${farm.name}"?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Delete'),
              ),
            ],
          ),
    );

    if (confirmed == true && context.mounted) {
      final controller = Provider.of<FarmDataController>(
        context,
        listen: false,
      );
      await controller.deleteFarm(farm);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Farm "${farm.name}" deleted successfully'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_currentPosition == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Consumer<FarmDataController>(
      builder: (context, farmController, _) =>
          Scaffold(
            body: MapLibreMap(
              options: MapOptions(
                initCenter: _currentPosition,
                initZoom: 15,
                initStyle: 'https://tiles.openfreemap.org/styles/liberty',
                gestures: MapGestures(
                  rotate: false,
                  pan: true,
                  zoom: true,
                  pitch: true,
                ),
              ),
              onMapCreated: (controller) {
                _mapController = controller;
              },
              onStyleLoaded: _addCustomImage,
              layers: [
                for (final cropType in CropType.values)
                  MarkerLayer(
                    points: farmController.getFarmsByCrop(cropType)
                        .map((farm) =>
                        Point(
                          coordinates: Position(farm.longitude, farm.latitude),
                        ))
                        .toList(),
                    iconSize: cropType == CropType.soybean
                        ? 0.1
                        : cropType == CropType.cotton
                        ? 0.3
                        : 0.5,
                    iconImage: _getIconKey(cropType),
                  ),
              ],
              onEvent: (event) async {
                if (event case MapEventClick(:final point)) {
                  // Check if clicked on an existing farm
                  final clickedFarm = farmController.getFarmByLocation(
                    point.lat as double,
                    point.lng as double,
                  );

                  if (clickedFarm != null) {
                    // Show delete option on long press
                    await _showDeleteConfirmation(context, clickedFarm);
                  } else {
                    // Create new farm
                    final position = Position(point.lng, point.lat);
                    final Farm? newFarm = await Navigator.push<Farm>(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            CreateFarmView(position: position),
                      ),
                    );

                    if (newFarm != null && context.mounted) {
                      await farmController.addFarm(newFarm);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Farm "${newFarm.name}" (${newFarm.type
                                .displayName}) created successfully!',
                          ),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    }
                  }
                }
              },
            ),
      ),
    );
  }
}
