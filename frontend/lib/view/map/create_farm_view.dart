import 'package:flutter/material.dart';
import 'package:frontend/map/map_controller.dart';
import 'package:frontend/theme/app_theme.dart';
import 'package:frontend/theme/constants.dart';
import 'package:frontend/view/welcome_survey/models/crops.dart';
import 'package:maplibre/maplibre.dart';

class Farm {
  final String name;
  final Crops cropType;
  final Position position;

  Farm({
    required this.name,
    required this.cropType,
    required this.position,
  });
}

class CreateFarmView extends StatefulWidget {
  final Position position;

  const CreateFarmView({
    super.key,
    required this.position,
  });

  @override
  State<CreateFarmView> createState() => _CreateFarmViewState();
}

class _CreateFarmViewState extends State<CreateFarmView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  Crops? _selectedCrop;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create New Farm'),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(Spacings.l),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Create a New Farm 🌱',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  color: AppTheme.primaryColor,
                  height: 1.1,
                ),
              ),
              SizedBox(height: Spacings.xl),
              Form(
                key: _formKey,
                child: TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Farm Name',
                    hintText: 'Enter a name for your farm',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(Radiuses.m),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a farm name';
                    }
                    return null;
                  },
                ),
              ),
              SizedBox(height: Spacings.xl),
              Text(
                'Select your crop type:',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppTheme.darkColor,
                ),
              ),
              SizedBox(height: Spacings.m),
              Expanded(
                child: ListView(
                  children: [
                    ...Crops.values.map(
                      (crop) => Padding(
                        padding: EdgeInsets.only(bottom: Spacings.m),
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedCrop = crop;
                            });
                          },
                          child: Container(
                            height: 100,
                            decoration: BoxDecoration(
                              color: Color(crop.color),
                              borderRadius: BorderRadius.circular(Radiuses.l),
                              border: Border.all(
                                color: _selectedCrop == crop
                                    ? AppTheme.primaryColor
                                    : Colors.transparent,
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
                                    child: Text(
                                      crop.localized(),
                                      style: Theme.of(context).textTheme.titleLarge
                                          ?.copyWith(color: AppTheme.darkColor),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                'Location: ${widget.position.lat.toStringAsFixed(6)}, ${widget.position.lng.toStringAsFixed(6)}',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: Spacings.m),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _selectedCrop != null && _nameController.text.isNotEmpty
                      ? () {
                          if (_formKey.currentState!.validate()) {
                            final farm = Farm(
                              name: _nameController.text,
                              cropType: _selectedCrop!,
                              position: widget.position,
                            );
                            Navigator.pop(context, farm);
                          }
                        }
                      : null,
                  child: const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text('Create Farm'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}