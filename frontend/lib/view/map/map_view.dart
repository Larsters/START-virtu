import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/models/farm.dart';
import 'package:frontend/services/app_data_manager.dart';
import 'package:frontend/view/farm_list/crop_type.dart';
import 'package:frontend/view/farm_list/farm_location.dart';
import 'package:frontend/view/map/create_farm_view.dart';
import 'package:frontend/view/map/map_controller.dart';
import 'package:maplibre/maplibre.dart';

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
  final LocationController _controller = LocationController();
  final AppDataManager _appDataManager = AppDataManager();
  Position? _currentPosition;
  final List<FarmPoint> _markersPoints = [];

  @override
  void initState() {
    super.initState();
    _loadCurrentPosition();
    _loadSavedFarms();
  }

  Future<void> _addCustomImage(StyleController styleController) async {
    try {
      // Add all farm type icons
      final Map<String, String> farmIcons = {
        'farm-corn': 'assets/images/farm_icons/corn_icon.png',
        'farm-soybean': 'assets/images/farm_icons/soybean_icon.png',
        'farm-cotton': 'assets/images/farm_icons/cotton_icon.png',
        'user-icon': 'assets/images/user-icon.png'
      };

      for (var entry in farmIcons.entries) {
        final ByteData data = await rootBundle.load(entry.value);
        final Uint8List imageData = data.buffer.asUint8List();
        await styleController.addImage(entry.key, imageData);
      }

      print('Farm icons added successfully!');
      // Force a rebuild of the map layers
      setState(() {});
    } catch (e) {
      print('Error adding images: $e');
    }
  }

  Future<void> _loadCurrentPosition() async {
    try {
      final position = await _controller.getCurrentPosition();
      setState(() {
        _currentPosition = position;
      });
    } catch (e) {
      // Handle error - maybe show a dialog to the user
      print('Error getting location: $e');
    }
  }

  Future<void> _loadSavedFarms() async {
    try {
      final farmLocations = await _appDataManager.loadFarmLocations();
      setState(() {
        for (var entry in farmLocations.entries) {
          for (var location in entry.value) {
            _markersPoints.add(FarmPoint(
              coordinates: Position(location.longitude, location.latitude),
              cropType: entry.key, name: location.name,
            ));
          }
        }
      });
    } catch (e) {
      print('Error loading saved farms: $e');
    }
  }

  void _addMarker(Position position, CropType cropType, String name) {
    setState(() {
      _markersPoints.add(FarmPoint(
        coordinates: position,
        cropType: cropType, name: name,
      ));
    });
    
    // Save the updated farms
    _saveFarms();
  }

  Future<void> _saveFarms() async {
    try {
      // Convert FarmPoints to a Map<Crops, List<FarmLocation>>
      final Map<CropType, List<FarmLocation>> farmLocations = {};
      for (var point in _markersPoints) {
        farmLocations.putIfAbsent(point.cropType, () => []);
        farmLocations[point.cropType]!.add(FarmLocation(
          latitude: point.coordinates.lat as double,
          longitude: point.coordinates.lng as double, name: point.name, crop: point.cropType,
        ));
      }
      
      await _appDataManager.saveFarmLocations(farmLocations);
    } catch (e) {
      print('Error saving farms: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_currentPosition == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
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
        onStyleLoaded: (StyleController styleController) async {
          await _addCustomImage(styleController);
        },
        layers: [
          MarkerLayer(
            points: _markersPoints
                .where((p) => p.cropType == CropType.corn)
                .toList(),
            iconSize: 0.5,
            iconImage: 'farm-corn',
          ),
          MarkerLayer(
            points: _markersPoints
                .where((p) => p.cropType == CropType.soybean)
                .toList(),
            iconSize: 0.1,
            iconImage: 'farm-soybean',
          ),
          MarkerLayer(
            points: _markersPoints
                .where((p) => p.cropType == CropType.cotton)
                .toList(),
            iconSize: 0.5,
            iconImage: 'farm-cotton',
          ),
          MarkerLayer(
            points: [Point(coordinates: _currentPosition!)],
            iconSize: 0.25,
            iconImage: 'user-icon',
          ),
        ],
        onEvent: (event) {
          print(_currentPosition);
          if (event case MapEventClick(:final point)) {
            final position = Position(point.lng, point.lat);
            Navigator.push<Farm>(
              context,
              MaterialPageRoute(
                builder: (context) => CreateFarmView(position: position),
              ),
            ).then((Farm? farm) {
              if (farm != null) {
                _addMarker(position, farm.getCropType, farm.name);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Farm "${farm.name}" (${farm.getCropType.localized()}) created successfully!'),
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
            });
          }
        },
      ),
    );
  }
}
