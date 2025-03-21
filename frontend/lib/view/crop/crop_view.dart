import 'package:flutter/material.dart';
import 'package:frontend/view/crop/crop_controller.dart';
import 'package:frontend/view/crop/widgets/crop_header.dart';
import 'package:frontend/view/crop/widgets/crop_product_recommendations.dart';
import 'package:frontend/view/crop/widgets/crop_statistics.dart';
import 'package:frontend/view/farm_list/crops.dart';
import 'package:provider/provider.dart';

class CropView extends StatelessWidget {
  final Crops crop;

  const CropView({super.key, required this.crop});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CropController(crop: crop),
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CropHeader(crop: crop),
                  const SizedBox(height: 24),
                  const CropProductRecommendations(),
                  const SizedBox(height: 24),
                  const CropStatistics(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
