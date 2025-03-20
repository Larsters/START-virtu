import 'package:flutter/material.dart';
import 'package:frontend/map/map_controller.dart';
import 'package:frontend/map/map_view.dart';
import 'package:provider/provider.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder:
                        (context) => ChangeNotifierProvider(
                          create: (_) => LocationController(),
                          child: const MyMapWidget(),
                        ),
                  ),
                );
              },
              child: const Text('Map view'),
            ),
          ],
        ),
      ),
    );
  }
}
