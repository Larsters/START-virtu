import 'package:flutter/material.dart';
import 'package:frontend/map/map_view.dart';
import 'package:frontend/theme/app_theme.dart';
import 'package:frontend/theme/constants.dart';
import 'package:frontend/view/welcome_survey/models/crops.dart';
import 'package:frontend/view/welcome_survey/models/farm_location.dart';
import 'package:frontend/view/welcome_survey/welcome_survey_controller.dart';
import 'package:provider/provider.dart';

class WelcomeSurveyView extends StatelessWidget {
  const WelcomeSurveyView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => WelcomeSurveyController(),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(Spacings.l),
            child: ListView(
              // crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Spacer(flex: 1),
                Text(
                  'Welcome to\nVirtu Farming! 🌱',
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    color: AppTheme.primaryColor,
                    height: 1.1,
                  ),
                ),
                SizedBox(height: Spacings.xl),
                Text(
                  'What crops do you have planted?',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: AppTheme.darkColor,
                  ),
                ),
                SizedBox(height: Spacings.m),
                Text(
                  'Select your crops and add their locations',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
                ),
                SizedBox(height: Spacings.xl),
                Column(
                  children: [
                    ...Crops.values.map(
                      (crop) => Padding(
                        padding: EdgeInsets.only(bottom: Spacings.m),
                        child: CropSelectionButton(crop: crop),
                      ),
                    ),
                  ],
                ),
                Consumer<WelcomeSurveyController>(
                  builder:
                      (context, controller, _) => SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed:
                              controller.canProceed()
                                  ? () async {
                                    await controller.saveSurveyData();
                                    if (context.mounted) {
                                      Navigator.of(context).pushReplacement(
                                        MaterialPageRoute<MapView>(
                                          builder: (context) => const MapView(),
                                        ),
                                      );
                                    }
                                  }
                                  : null,
                          child: const Text('Continue'),
                        ),
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CropSelectionButton extends StatelessWidget {
  final Crops crop;

  const CropSelectionButton({super.key, required this.crop});

  @override
  Widget build(BuildContext context) {
    return Consumer<WelcomeSurveyController>(
      builder: (context, controller, _) {
        final isExpanded = controller.expandedCrop == crop;
        final isSelected = controller.isCropSelected(crop);
        final locations = controller.getLocationsForCrop(crop);

        return Column(
          children: [
            GestureDetector(
              onTap: () => controller.toggleCropExpansion(crop),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: 100,
                decoration: BoxDecoration(
                  color: Color(crop.color),
                  borderRadius: BorderRadius.circular(Radiuses.l),
                  border: Border.all(
                    color:
                        isSelected ? AppTheme.primaryColor : Colors.transparent,
                    width: BorderWidth.m,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(20),
                      blurRadius: Elevations.s,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Padding(
                  padding: EdgeInsets.all(Spacings.m),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 80,
                        height: 80,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(Radiuses.m),
                          child: Image.asset(
                            crop.imagePath,
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(
                                Icons.grass,
                                size: 32,
                                color: AppTheme.primaryColor,
                              );
                            },
                          ),
                        ),
                      ),
                      SizedBox(width: Spacings.l),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              crop.localized(),
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(color: AppTheme.darkColor),
                            ),
                            if (locations.isNotEmpty)
                              Text(
                                '${locations.length} location${locations.length == 1 ? '' : 's'}',
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(color: Colors.grey[600]),
                              ),
                          ],
                        ),
                      ),
                      Icon(
                        isExpanded ? Icons.expand_less : Icons.expand_more,
                        color: AppTheme.darkColor,
                        size: 28,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (isExpanded) ...[
              SizedBox(height: Spacings.m),
              _LocationsList(crop: crop, locations: locations),
              SizedBox(height: Spacings.m),
              _AddLocationForm(crop: crop),
            ],
          ],
        );
      },
    );
  }
}

class _LocationsList extends StatelessWidget {
  final Crops crop;
  final List<FarmLocation> locations;

  const _LocationsList({required this.crop, required this.locations});

  @override
  Widget build(BuildContext context) {
    if (locations.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: Spacings.s),
          child: Text(
            'Saved Locations',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        SizedBox(height: Spacings.s),
        ...locations.asMap().entries.map((entry) {
          final index = entry.key;
          final location = entry.value;
          return Padding(
            padding: EdgeInsets.only(bottom: Spacings.s),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(Radiuses.m),
                border: Border.all(
                  color: Colors.grey[300]!,
                  width: BorderWidth.m,
                ),
              ),
              child: ListTile(
                title: Text(location.name),
                subtitle: Text(
                  'Lat: ${location.latitude.toStringAsFixed(6)}\n'
                  'Lon: ${location.longitude.toStringAsFixed(6)}',
                ),
                trailing: Consumer<WelcomeSurveyController>(
                  builder:
                      (context, controller, _) => IconButton(
                        icon: const Icon(Icons.delete_outline),
                        color: AppTheme.errorColor,
                        onPressed: () => controller.removeLocation(crop, index),
                      ),
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}

class _AddLocationForm extends StatelessWidget {
  final Crops crop;

  const _AddLocationForm({required this.crop});

  @override
  Widget build(BuildContext context) {
    return Consumer<WelcomeSurveyController>(
      builder:
          (context, controller, _) => Container(
            padding: EdgeInsets.all(Spacings.m),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(Radiuses.m),
              border: Border.all(
                color: Colors.grey[300]!,
                width: BorderWidth.m,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Add New Location',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                SizedBox(height: Spacings.m),
                TextField(
                  controller: controller.nameController,
                  decoration: const InputDecoration(
                    labelText: 'Farm Name',
                    hintText: 'Enter a name for this location',
                  ),
                ),
                SizedBox(height: Spacings.m),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: controller.latitudeController,
                        decoration: const InputDecoration(
                          labelText: 'Latitude',
                          hintText: '-90 to 90',
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                          signed: true,
                        ),
                      ),
                    ),
                    SizedBox(width: Spacings.m),
                    Expanded(
                      child: TextField(
                        controller: controller.longitudeController,
                        decoration: const InputDecoration(
                          labelText: 'Longitude',
                          hintText: '-180 to 180',
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                          signed: true,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: Spacings.m),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed:
                        controller.isValidForm()
                            ? () => controller.addLocation(crop)
                            : null,
                    child: const Text('Add Location'),
                  ),
                ),
              ],
            ),
          ),
    );
  }
}
