import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:frontend/map/map_controller.dart';
import 'package:frontend/map/farm_widget.dart';
import 'package:maplibre/maplibre.dart';
import 'dart:math' as math;

class Farm {
  final Position position;
  final SeedType seedType;
  final double progress;

  Farm({
    required this.position,
    required this.seedType,
    required this.progress,
  });
}

@immutable
class MyMapWidget extends StatefulWidget {
  const MyMapWidget({super.key});

  @override
  State<MyMapWidget> createState() => _MyMapWidget();
}

class _MyMapWidget extends State<MyMapWidget> {
  // Using this field to store the widget state
  bool _gesturesEnabed = true;
  final LocationController _controller = LocationController();
  Position? _currentPosition;
  final List<Farm> _farms = [];
  final _random = math.Random();
  MapController? _mapController;

  @override
  void initState() {
    super.initState();
    _loadCurrentPosition();
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

  void _addFarm(Position position) {
    final farm = Farm(
      position: position,
      seedType: SeedType.values[_random.nextInt(SeedType.values.length)],
      progress: _random.nextDouble() * 100,
    );

    setState(() {
      _farms.add(farm);
    });
  }

  void _showFarmDetails(Farm farm, BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: FarmWidget(
          seedType: farm.seedType,
          progress: farm.progress,
          color: Colors.green,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
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
          print('Map controller created');
          _mapController = controller;
        },
        layers: [
          CircleLayer(
            points: _farms.map((farm) => Point(coordinates: farm.position)).toList(),
            radius: 10,
            color: Colors.red,
            strokeWidth: 2,
            strokeColor: Colors.white,
          ),
        ],
        onEvent: (event) {
          if (event case MapEventClick(:final point)) {
            print('Map clicked at: $point');
            // Check if we clicked near an existing farm
            final clickedPosition = Position(point.lng, point.lat);
            final nearbyFarm = _farms.cast<Farm?>().firstWhere(
              (farm) {
                final dx = farm!.position.lng - clickedPosition.lng;
                final dy = farm.position.lat - clickedPosition.lat;
                // Check if click is within 0.0001 degrees (roughly 10 meters)
                return (dx * dx + dy * dy) < 0.0001 * 0.0001;
              },
              orElse: () => null,
            );

            if (nearbyFarm != null) {
              _showFarmDetails(nearbyFarm, context);
            } else {
              _addFarm(clickedPosition);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Farm added at: ${clickedPosition.lat.toStringAsFixed(6)}, ${clickedPosition.lng.toStringAsFixed(6)}',
                  ),
                  duration: const Duration(seconds: 2),
                ),
              );
            }
          }
        },
      ),
    );
  }
}
