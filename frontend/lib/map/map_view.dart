import 'package:flutter/material.dart';
import 'package:frontend/map/map_controller.dart';
import 'package:provider/provider.dart';

/// Only view elements of the map view
class MapView extends StatelessWidget {
  const MapView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MapController(),
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text('Map view'),
        ),
        body: Center(
          child: Consumer<MapController>(
            builder: (context, controller, _) {
              return Text('Holi ${controller.name}');
            },
          ),
        ),
      ),
    );
  }
}
