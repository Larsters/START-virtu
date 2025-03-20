import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:permission_handler/permission_handler.dart';

/// Only view elements of the map view
class MapView extends StatelessWidget {
  const MapView({super.key});

  @override
  Widget build(BuildContext context) {
  return MaterialApp(
  debugShowCheckedModeBanner: false,
  title: 'MapBox Example',
  home: MapScreen(),
  );
  }
  }

  class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
  }

  class _MapScreenState extends State<MapScreen> {
  MapboxMapController? mapController;
  LatLng? currentLocation;
  final String mapboxAccessToken = 'YOUR_MAPBOX_ACCESS_TOKEN_HERE';  // Replace this with your own token

  @override
  void initState() {
  super.initState();
  _getCurrentLocation(); // Get user's location when the app starts
  }

  /// Function to get the user's location
  Future<void> _getCurrentLocation() async {
  // Request permission for location
  var status = await Permission.location.request();

  if (status.isGranted) {
  Location location = Location();
  var userLocation = await location.getLocation();

  setState(() {
  currentLocation = LatLng(userLocation.latitude!, userLocation.longitude!);
  });

  // Move the map to the user's location
  if (mapController != null) {
  mapController!.animateCamera(CameraUpdate.newLatLng(currentLocation!));
  }
  } else {
  print('Location permission denied');
  }
  }

  /// Callback when the map is created
  void _onMapCreated(MapboxMapController controller) {
  mapController = controller;
  if (currentLocation != null) {
  mapController!.animateCamera(CameraUpdate.newLatLng(currentLocation!));
  }
  }

  @override
  Widget build(BuildContext context) {
  return Scaffold(
  appBar: AppBar(title: Text('MapBox Example')),
  body: currentLocation == null
  ? Center(child: CircularProgressIndicator())  // Show loading until location is found
      : MapboxMap(
  accessToken: mapboxAccessToken,
  onMapCreated: _onMapCreated,
  initialCameraPosition: CameraPosition(
  target: currentLocation!,
  zoom: 14.0,
  ),
  myLocationEnabled: true,
  myLocationTrackingMode: MyLocationTrackingMode.TrackingGPS,
  ),
  );
  }
  }
