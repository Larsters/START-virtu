import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/map/map_controller.dart';
import 'package:frontend/view/map/create_farm_view.dart';
import 'package:frontend/view/welcome_survey/models/crops.dart';
import 'package:maplibre/maplibre.dart';
import 'package:frontend/view/map/create_farm_view.dart';

@immutable
class MapView extends StatefulWidget {
  const MapView({super.key});

  @override
  State<MapView> createState() => _MyMapWidget();
}

class FarmPoint extends Point {
  final Crops cropType;

  FarmPoint({
    required Position coordinates,
    required this.cropType,
  }) : super(coordinates: coordinates);

  String get iconKey {
    switch (cropType) {
      case Crops.soybean:
        return 'farm-soybean';
      case Crops.corn:
        return 'farm-corn';
      case Crops.cotton:
        return 'farm-cotton';
    }
  }
}

class _MyMapWidget extends State<MapView> {
  // Using this field to store the widget state
  MapController? _mapController;

  final LocationController _controller = LocationController();
  Position? _currentPosition;
  final List<FarmPoint> _markersPoints = [];

  @override
  void initState() {
    super.initState();
    _loadCurrentPosition();
  }

  Future<void> _addCustomImage(StyleController styleController) async {
    try {
      // Add all farm type icons
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

      print('Farm icons added successfully!');
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

  void _addMarker(Position position, Crops cropType) {
    setState(() {
      _markersPoints.add(FarmPoint(
        coordinates: position,
        cropType: cropType,
      ));
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_currentPosition == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      body: MapLibreMap(
        options: MapOptions(
          initCenter: _currentPosition,
          initZoom: 15, // Zooming in more since we're showing user's location
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
        onStyleLoaded: (StyleController styleController) {
          _addCustomImage(styleController);
        },
        layers: [
          MarkerLayer(
            points: _markersPoints.where((p) => p.cropType == Crops.corn).toList(),
            iconSize: 0.5,
            iconImage: 'farm-corn',
          ),
          MarkerLayer(
            points: _markersPoints.where((p) => p.cropType == Crops.soybean).toList(),
            iconSize: 0.1,
            iconImage: 'farm-soybean',
          ),
          MarkerLayer(
            points: _markersPoints.where((p) => p.cropType == Crops.cotton).toList(),
            iconSize: 0.3,
            iconImage: 'farm-cotton',
          ),
        ],
        onEvent: (event) {
          if (event case MapEventClick(:final point)) {
            final position = Position(point.lng, point.lat);
            Navigator.push<Farm>(
              context,
              MaterialPageRoute(
                builder: (context) => CreateFarmView(position: position),
              ),
            ).then((Farm? farm) {
              if (farm != null) {
                _addMarker(position, farm.cropType);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Farm "${farm.name}" (${farm.cropType.localized()}) created successfully!'),
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
