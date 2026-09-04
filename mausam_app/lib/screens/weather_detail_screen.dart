import 'package:flutter/material.dart';
import '../models/app_models.dart';
import '../core/app_theme.dart';
import '../services/app_state.dart';
import '../widgets/frosted_glass_card.dart';
import '../widgets/pill_button.dart';

IconData getWeatherIcon(String condition) {
  final c = condition.toLowerCase();
  if (c.contains('rain') || c.contains('shower') || c.contains('drizzle')) return Icons.water_drop;
  if (c.contains('thunder') || c.contains('storm')) return Icons.thunderstorm;
  if (c.contains('cloud') || c.contains('overcast')) return Icons.cloud;
  if (c.contains('snow')) return Icons.ac_unit;
  return Icons.wb_sunny;
}

class WeatherDetailScreen extends StatelessWidget {
  const WeatherDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);
    final w = state.weatherSummary;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: MausamColors.primary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Live Atmospheric Metrics', style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: MausamColors.primary)),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text('Open-Meteo & IMD Telemetry', style: Theme.of(context).textTheme.headlineLarge),
            Text('Real-time ambient context from backend', style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 20),

            // Bento Grid for Metrics
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              childAspectRatio: 1.2,
              children: [
                _MetricCard(
                  title: 'WIND SPEED',
                  value: state.formatSpeed(w?.windSpeed),
                  subtitle: 'Live Open-Meteo Speed',
                  icon: Icons.air,
                ),
                _MetricCard(
                  title: 'HUMIDITY',
                  value: '${(w?.humidity ?? 0).toInt()}%',
                  subtitle: (w?.humidity ?? 0) > 70 ? 'High Moisture' : 'Comfortable',
                  icon: Icons.water_drop,
                ),
                _MetricCard(
                  title: 'UV INDEX',
                  value: '${w?.uvIndex.toStringAsFixed(1) ?? 0.0}',
                  subtitle: (w?.uvIndex ?? 0) > 5 ? 'Sunscreen Advised' : 'Low Exposure',
                  icon: Icons.wb_sunny,
                ),
                _MetricCard(
                  title: 'RAIN CHANCE',
                  value: '${(w?.rainProbability ?? 0).toInt()}%',
                  subtitle: (w?.rainProbability ?? 0) > 40 ? 'Carry Umbrella' : 'Minimal Precipitation',
                  icon: Icons.umbrella,
                ),
                _MetricCard(
                  title: 'FEELS LIKE',
                  value: state.formatTemp(w?.apparentTemperature),
                  subtitle: 'Apparent Temperature',
                  icon: Icons.thermostat,
                ),
                _MetricCard(
                  title: 'AIR QUALITY',
                  value: 'AQI ${(w?.aqi ?? 0).toInt()}',
                  subtitle: (w?.aqi ?? 0) > 150 ? 'Unhealthy' : 'Moderate/Good',
                  icon: Icons.speed,
                ),
              ],
            ),
            const SizedBox(height: 24),

            FrostedGlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('LIVE CLIMATE ZONE & RADAR CONTEXT', style: Theme.of(context).textTheme.labelSmall),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          const Icon(Icons.public, color: MausamColors.primary),
                          const SizedBox(height: 4),
                          Text('Zone: ${w?.climateZone.toUpperCase() ?? 'TROPICAL'}', style: Theme.of(context).textTheme.bodyMedium),
                        ],
                      ),
                      Column(
                        children: [
                          const Icon(Icons.tsunami, color: MausamColors.beachAqua),
                          const SizedBox(height: 4),
                          Text('Wave: ${w?.waveHeight ?? 1.2} m', style: Theme.of(context).textTheme.bodyMedium),
                        ],
                      ),
                    ],
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;

  const _MetricCard({required this.title, required this.value, required this.subtitle, required this.icon});

  @override
  Widget build(BuildContext context) {
    return FrostedGlassCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: Theme.of(context).textTheme.labelSmall),
              Icon(icon, size: 18, color: MausamColors.primary),
            ],
          ),
          Text(value, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 20)),
          Text(subtitle, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 11)),
        ],
      ),
    );
  }
}