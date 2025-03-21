import 'package:flutter/material.dart';
import 'package:frontend/view/farm_details/farm_details_controller.dart';
import 'package:frontend/view/farm_details/models/product.dart';
import 'package:provider/provider.dart';

class AlertsSection extends StatelessWidget {
  const AlertsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<FarmDetailsController>(context);

    if (controller.activeRecommendedProducts.isEmpty &&
        !controller.isHarvestTime) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Text('Alerts', style: Theme.of(context).textTheme.titleLarge),
        ),
        if (controller.isHarvestTime) const _HarvestAlert(),
        ...controller.activeRecommendedProducts.map(
          (product) => _AlertCard(product: product),
        ),
      ],
    );
  }
}

class _HarvestAlert extends StatelessWidget {
  const _HarvestAlert();

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<FarmDetailsController>(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.agriculture, color: Colors.green[700]),
                const SizedBox(width: 8),
                Text(
                  'Harvest Time',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'It\'s time to harvest your crops! Please record your harvest data.',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () => _showHarvestSurvey(context),
                icon: const Icon(Icons.check_circle_outline),
                label: const Text('Record Harvest'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showHarvestSurvey(BuildContext context) async {
    final controller = Provider.of<FarmDetailsController>(
      context,
      listen: false,
    );

    await showDialog<void>(
      context: context,
      builder:
          (context) =>
              _HarvestSurveyDialog(usedProducts: controller.usedProducts),
    );
  }
}

class _HarvestSurveyDialog extends StatefulWidget {
  final List<ProductUsage> usedProducts;

  const _HarvestSurveyDialog({required this.usedProducts});

  @override
  State<_HarvestSurveyDialog> createState() => _HarvestSurveyDialogState();
}

class _HarvestSurveyDialogState extends State<_HarvestSurveyDialog> {
  final _formKey = GlobalKey<FormState>();
  double? harvestedAmount;
  bool hadDiseases = false;
  String? diseaseNotes;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Harvest Survey'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.usedProducts.isNotEmpty) ...[
                Text(
                  'Products Used:',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                ...widget.usedProducts.map(
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
                const SizedBox(height: 16),
              ],
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Harvested Amount (kg)',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the harvested amount';
                  }
                  final amount = double.tryParse(value);
                  if (amount == null || amount <= 0) {
                    return 'Please enter a valid amount';
                  }
                  return null;
                },
                onSaved: (value) {
                  harvestedAmount = double.tryParse(value ?? '');
                },
              ),
              const SizedBox(height: 16),
              CheckboxListTile(
                title: const Text('Crops had diseases'),
                value: hadDiseases,
                onChanged: (value) {
                  setState(() {
                    hadDiseases = value ?? false;
                  });
                },
              ),
              if (hadDiseases)
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Disease Notes'),
                  maxLines: 3,
                  validator: (value) {
                    if (hadDiseases && (value == null || value.isEmpty)) {
                      return 'Please describe the diseases';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    diseaseNotes = value;
                  },
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(onPressed: _submitForm, child: const Text('Save')),
      ],
    );
  }

  void _submitForm() {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();
      final controller = Provider.of<FarmDetailsController>(
        context,
        listen: false,
      );
      controller.recordHarvest(harvestedAmount!, hadDiseases, diseaseNotes);
      Navigator.of(context).pop();
    }
  }
}

class _AlertCard extends StatelessWidget {
  final Product product;

  const _AlertCard({required this.product});

  Future<void> _showDatePicker(BuildContext context) async {
    final controller = Provider.of<FarmDetailsController>(
      context,
      listen: false,
    );
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 7)),
      lastDate: DateTime.now(),
    );

    if (selectedDate != null && context.mounted) {
      await controller.recordProductUsage(product, selectedDate);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(product.icon, color: Colors.orange),
                const SizedBox(width: 8),
                Text(
                  product.displayName,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              product.alertText,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () => _showDatePicker(context),
                icon: const Icon(Icons.check_circle_outline),
                label: const Text('Use Product'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
