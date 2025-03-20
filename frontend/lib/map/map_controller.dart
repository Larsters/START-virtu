import 'package:flutter/cupertino.dart';
import 'package:geolocator/geolocator.dart';
import 'package:maplibre/maplibre.dart' as maplibre;

/// Logic for the map view, like variables and stuff. Anything that is
/// related to the model of the view goes here.
class LocationController with ChangeNotifier {
  Future<maplibre.Position> getCurrentPosition() async {
    // Request location permission
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permission denied');
      }
    }

    // Get current position
    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high
    );

    // Convert to MapLibre Position
    return maplibre.Position(position.longitude, position.latitude);
  }
}
