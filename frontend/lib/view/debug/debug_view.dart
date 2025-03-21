import 'package:flutter/material.dart';
import 'package:frontend/view/debug/debug_controller.dart';
import 'package:provider/provider.dart';

class DebugView extends StatelessWidget {
  const DebugView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: DebugController(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Debug Menu')),
        body: const SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [_HarvestTimeSection()],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _HarvestTimeSection extends StatelessWidget {
  const _HarvestTimeSection();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Harvest Time', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            Consumer<DebugController>(
              builder:
                  (context, controller, _) => SwitchListTile(
                    title: const Text('Force Harvest Time'),
                    subtitle: Text(
                      'Override the season check to show harvest dialog',
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                    ),
                    value: controller.forceHarvestTime,
                    onChanged: (_) => controller.toggleHarvestTime(),
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
