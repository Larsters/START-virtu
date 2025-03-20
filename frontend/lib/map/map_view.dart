import 'package:flutter/material.dart';
import 'package:frontend/map/map_controller.dart';
import 'package:provider/provider.dart';

/// Only view elements of the map view
class MapView extends StatelessWidget {
  const MapView({super.key});

  @override
  Widget build(BuildContext context) {
    final MapController controller = Provider.of<MapController>(context);

    return Scaffold(
      appBar: AppBar(title: Text('Map view')),
      body: Center(child: Text('Holi ${controller.name}')),
    );
  }
}
