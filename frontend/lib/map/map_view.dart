import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:frontend/map/map_controller.dart';
import 'package:maplibre/maplibre.dart';

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
  final List<Widget> _markers = [];

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

  void _addMarker(Position position) {
    setState(() {
      _markers.add(
        Container(
          color: Colors.red,
          width: 50,
          height: 50,
        ),
      );
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
            initCenter: _currentPosition!,
            initZoom: 15, // Zooming in more since we're showing user's location
            initStyle: 'https://tiles.openfreemap.org/styles/liberty',
            gestures: _gesturesEnabed ? MapGestures.all() : MapGestures.none(),
          ),
          children: _markers,
          onEvent: (event) {
            if (event case MapEventClick()) {
              setState(() {
                _gesturesEnabed = !_gesturesEnabed;
              });
            } else if (event case MapEventLongPress(:final position)) {
              _addMarker(position);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Marker added at: ${position.latitude.toStringAsFixed(6)}, ${position.longitude.toStringAsFixed(6)}',
                  ),
                  duration: const Duration(seconds: 2),
                ),
              );
            }
          }
      ),
    );
  }
}