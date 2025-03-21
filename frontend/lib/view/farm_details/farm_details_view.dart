import 'package:flutter/material.dart';
import 'package:frontend/view/debug/debug_view.dart';
import 'package:frontend/view/farm_details/farm_details_controller.dart';
import 'package:frontend/view/farm_details/models/product.dart';
import 'package:frontend/view/farm_details/widgets/alerts_section.dart';
import 'package:frontend/view/farm_details/widgets/farm_header.dart';
import 'package:frontend/view/farm_details/widgets/risks_section.dart';
import 'package:frontend/view/farm_details/widgets/used_products_section.dart';
import 'package:frontend/view/farm_list/crop_type.dart';
import 'package:provider/provider.dart';

class FarmDetailsView extends StatelessWidget {
  final String farmName;
  final CropType? cropType;
  final double latitude;
  final double longitude;
  final int healthScore;

  const FarmDetailsView({
    super.key,
    required this.farmName,
    this.cropType,
    required this.latitude,
    required this.longitude,
    required this.healthScore,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create:
          (_) => FarmDetailsController(
            farmName: farmName,
            cropType: cropType,
            latitude: latitude,
            longitude: longitude,
          ),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.bug_report),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (context) => const DebugView(),
                  ),
                );
              },
            ),
            if (cropType != null)
              Consumer<FarmDetailsController>(
                builder:
                    (context, controller, _) => PopupMenuButton<Product>(
                      icon: const Icon(Icons.add),
                      itemBuilder:
                          (context) => [
                            const PopupMenuItem(
                              value: Product.stressBooster,
                              child: Row(
                                children: [
                                  Icon(Icons.healing),
                                  SizedBox(width: 8),
                                  Text('Add Stress Booster'),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: Product.nutrientBooster,
                              child: Row(
                                children: [
                                  Icon(Icons.local_florist),
                                  SizedBox(width: 8),
                                  Text('Add Nutrient Booster'),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: Product.yieldBooster,
                              child: Row(
                                children: [
                                  Icon(Icons.trending_up),
                                  SizedBox(width: 8),
                                  Text('Add Yield Booster'),
                                ],
                              ),
                            ),
                          ],
                      onSelected: (product) async {
                        final selectedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime.now().subtract(
                            const Duration(days: 7),
                          ),
                          lastDate: DateTime.now(),
                        );

                        if (selectedDate != null && context.mounted) {
                          await controller.recordProductUsage(
                            product,
                            selectedDate,
                          );
                        }
                      },
                    ),
              ),
          ],
        ),
        body: SafeArea(
          child: Consumer<FarmDetailsController>(
            builder:
                (context, controller, _) => SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (controller.cropType != null) ...[
                          FarmHeader(
                            farmName: farmName,
                            cropType: controller.cropType!,
                            healthScore: healthScore,
                          ),
                          const SizedBox(height: 24),
                          const AlertsSection(),
                          const SizedBox(height: 24),
                          const UsedProductsSection(),
                          const SizedBox(height: 24),
                          const RisksSection(),
                        ] else if (controller.lastHarvestData != null) ...[
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Colors.green.withOpacity(0.1),
                                  Colors.blue.withOpacity(0.1),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              children: [
                                const Icon(
                                  Icons.check_circle_outline,
                                  size: 48,
                                  color: Colors.green,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Season Complete',
                                  style:
                                      Theme.of(
                                        context,
                                      ).textTheme.headlineMedium,
                                ),
                                Text(
                                  farmName,
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(color: Colors.grey[600]),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          _LastHarvestInfo(data: controller.lastHarvestData!),
                          const SizedBox(height: 32),
                          Center(
                            child: FilledButton.icon(
                              onPressed: () => _showCropSelector(context),
                              icon: const Icon(Icons.add),
                              label: const Text('Plant New Crop'),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
          ),
        ),
      ),
    );
  }

  Future<void> _showCropSelector(BuildContext context) async {
    final controller = Provider.of<FarmDetailsController>(
      context,
      listen: false,
    );
    final selectedCrop = await showDialog<CropType>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Select Crop'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children:
                  CropType.values
                      .map(
                        (crop) => ListTile(
                          leading: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Color(crop.color),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.asset(
                                crop.imagePath,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Icon(Icons.grass);
                                },
                              ),
                            ),
                          ),
                          title: Text(crop.displayName),
                          onTap: () => Navigator.of(context).pop(crop),
                        ),
                      )
                      .toList(),
            ),
          ),
    );

    if (selectedCrop != null && context.mounted) {
      await controller.plantNewCrop(selectedCrop);
    }
  }
}

class _LastHarvestInfo extends StatelessWidget {
  final HarvestData data;

  const _LastHarvestInfo({required this.data});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Last Harvest', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            _InfoRow(
              label: 'Harvested Amount',
              value: '${data.harvestedAmount} kg',
            ),
            if (data.usedProducts.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                'Products Used:',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              ...data.usedProducts.map(
                (usage) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: [
                      Icon(usage.product.icon, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        '${usage.product.displayName} on ${usage.date.toString().split(' ')[0]}',
                      ),
                    ],
                  ),
                ),
              ),
            ],
            if (data.hadDiseases && data.diseaseNotes != null) ...[
              const SizedBox(height: 16),
              Text(
                'Disease Notes:',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              Text(data.diseaseNotes!),
            ],
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
        ),
        Text(
          value,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
