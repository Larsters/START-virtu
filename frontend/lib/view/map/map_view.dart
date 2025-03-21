import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/view/map/map_controller.dart';
import 'package:maplibre/maplibre.dart';

@immutable
class MapView extends StatefulWidget {
  const MapView({super.key});

  @override
  State<MapView> createState() => _MyMapWidget();
}

class _MyMapWidget extends State<MapView> {
  // Using this field to store the widget state
  MapController? _mapController;

  final LocationController _controller = LocationController();
  Position? _currentPosition;
  final List<Point> _markersPoints = [];

  @override
  void initState() {
    super.initState();
    _loadCurrentPosition();
  }

  Future<void> _addCustomImage(StyleController styleController) async {
    try {
      final ByteData data = await rootBundle.load('assets/images/farm.png'); // Load from assets
      final Uint8List imageData = data.buffer.asUint8List();

      // Ensure `addImage` is awaited
      await styleController.addImage('custom-marker', imageData);

      print('Custom image added successfully!');
    } catch (e) {
      print('Error adding image: $e');
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

  void _addMarker(Position position) {
    setState(() {
      _markersPoints.add(Point(coordinates: position));
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
              points: _markersPoints,
              iconSize: 0.5,  // Choose a size that works well for your use case
              iconImage: 'custom-marker',
          ),
        ],
        onEvent: (event) {
          if (event case MapEventClick(:final point)) {
            final position = Position(point.lng, point.lat);
            _addMarker(position);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Marker added at: ${position.lat.toStringAsFixed(6)}, ${position.lng.toStringAsFixed(6)}',
                ),
                duration: const Duration(seconds: 2),
              ),
            );
          }
        },
      ),
    );
  }
}
