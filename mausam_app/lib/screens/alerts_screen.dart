import 'package:flutter/material.dart';
import '../models/app_models.dart';
import '../core/app_theme.dart';
import '../services/app_state.dart';
import '../widgets/frosted_glass_card.dart';
import '../widgets/pill_button.dart';


class AlertsScreen extends StatelessWidget {
  const AlertsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);
    final aqi = state.weatherSummary?.aqi ?? 225.0;
    final rainProb = state.weatherSummary?.rainProbability ?? 0.0;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text('Active Weather Alerts', style: Theme.of(context).textTheme.headlineLarge),
            Text('Automated warnings generated from live telemetry.', style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 20),

            if (aqi > 150)
              FrostedGlassCard(
                accentColor: MausamColors.errorRed,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: MausamColors.errorRed.withValues(alpha: 0.15),
                          child: const Icon(Icons.air, color: MausamColors.errorRed, size: 18),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text('Elevated AQI Advisory (${aqi.toInt()})', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 15)),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: MausamColors.errorRed.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text('POOR AIR', style: TextStyle(color: MausamColors.errorRed, fontSize: 10, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Text('Particulate levels (PM2.5 & PM10) are elevated. Sensitive individuals should limit prolonged outdoor exertion.', style: TextStyle(fontSize: 13)),
                    const SizedBox(height: 8),
                    const Text('Active live notice from Open-Meteo', style: TextStyle(fontSize: 11, color: MausamColors.secondary)),
                  ],
                ),
              ),

            const SizedBox(height: 14),

            FrostedGlassCard(
              accentColor: rainProb > 30 ? MausamColors.fitnessBlue : MausamColors.tertiary,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: (rainProb > 30 ? MausamColors.fitnessBlue : MausamColors.tertiary).withValues(alpha: 0.15),
                        child: Icon(rainProb > 30 ? Icons.umbrella : Icons.check_circle_outline, color: rainProb > 30 ? MausamColors.fitnessBlue : MausamColors.tertiary, size: 18),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          rainProb > 30 ? 'Rain Probability: ${rainProb.toInt()}%' : 'Precipitation Clear (0% Rain)',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 15),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: (rainProb > 30 ? MausamColors.fitnessBlue : MausamColors.tertiary).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(rainProb > 30 ? 'RAIN WATCH' : 'OPTIMAL', style: TextStyle(color: rainProb > 30 ? MausamColors.fitnessBlue : MausamColors.tertiary, fontSize: 10, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    rainProb > 30
                        ? 'Scattered showers possible during commuting windows.'
                        : 'No precipitation forecasted for current outdoor windows.',
                    style: const TextStyle(fontSize: 13),
                  ),
                  const SizedBox(height: 8),
                  const Text('Live Sensor Context Active', style: TextStyle(fontSize: 11, color: MausamColors.secondary)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}