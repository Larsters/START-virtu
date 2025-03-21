import 'package:flutter/material.dart';
import 'package:frontend/theme/app_theme.dart';
import 'package:frontend/view/farm_details/farm_details_view.dart';
import 'package:frontend/view/farm_list/farm_list_controller.dart';
import 'package:provider/provider.dart';

class FarmListView extends StatelessWidget {
  const FarmListView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => FarmListController(),
      child: Consumer<FarmListController>(
        builder:
            (context, controller, _) => Stack(
              children: [
                // Weather background
                Positioned.fill(
                  child: Image.asset(
                    controller.currentWeather.type.backgroundImage,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(color: Colors.blue[100]);
                    },
                  ),
                ),
                // Content
                CustomScrollView(
                  slivers: [
                    // Weather info
                    SliverToBoxAdapter(
                      child: _WeatherHeader(weather: controller.currentWeather),
                    ),
                    // Farms list
                    SliverToBoxAdapter(
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(30),
                            topRight: Radius.circular(30),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(24),
                              child: Text(
                                'My Farms',
                                style:
                                    Theme.of(context).textTheme.headlineMedium,
                              ),
                            ),
                            ...controller.farms.map(
                              (farm) => Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  16,
                                  0,
                                  16,
                                  16,
                                ),
                                child: _FarmCard(farm: farm),
                              ),
                            ),
                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
      ),
    );
  }
}

class _WeatherHeader extends StatelessWidget {
  final WeatherInfo weather;

  const _WeatherHeader({required this.weather});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.35,
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${weather.temperature.toStringAsFixed(1)}°C',
            style: Theme.of(
              context,
            ).textTheme.displayLarge?.copyWith(color: Colors.white, height: 1),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _WeatherStat(
                icon: Icons.water_drop,
                value: '${weather.humidity}%',
                label: 'Humidity',
              ),
              const SizedBox(width: 24),
              _WeatherStat(
                icon: Icons.air,
                value: '${weather.windSpeed} km/h',
                label: 'Wind',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _WeatherStat extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _WeatherStat({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Colors.white),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.white.withAlpha(200),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _FarmCard extends StatelessWidget {
  final Farm farm;

  const _FarmCard({required this.farm});

  Color _getHealthColor() {
    if (farm.health.overallScore >= 80) return Colors.green;
    if (farm.health.overallScore >= 60) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      elevation: 2,
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder:
                  (context) => FarmDetailsView(
                    farmName: farm.name,
                    cropType: farm.crop,
                    latitude: farm.latitude,
                    longitude: farm.longitude,
                    healthScore: farm.health.overallScore,
                  ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  // Crop image
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Color(farm.crop.color),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        farm.crop.imagePath,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.grass,
                            color: AppTheme.primaryColor,
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Farm info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          farm.name,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        Text(
                          farm.crop.displayName,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                  // Health score
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: _getHealthColor().withAlpha(30),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${farm.health.overallScore}',
                        style: Theme.of(
                          context,
                        ).textTheme.titleMedium?.copyWith(
                          color: _getHealthColor(),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              if (farm.health.hasRisk) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.warning_amber_rounded,
                        color: Colors.red[700],
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          farm.health.alert ?? 'Risk detected',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: Colors.red[700]),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
