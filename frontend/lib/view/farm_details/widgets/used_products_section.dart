import 'package:flutter/material.dart';
import 'package:frontend/view/farm_details/farm_details_controller.dart';
import 'package:provider/provider.dart';

class UsedProductsSection extends StatelessWidget {
  const UsedProductsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<FarmDetailsController>(context);

    if (controller.usedProducts.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            'Products Used',
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                ...controller.usedProducts.map(
                  (usage) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            usage.product.icon,
                            color: Colors.orange,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                usage.product.displayName,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              Text(
                                'Used on ${usage.date.toString().split(' ')[0]}',
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.check_circle,
                          color: Colors.green[700],
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
