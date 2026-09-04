import 'package:flutter/material.dart';
import '../models/app_models.dart';
import '../core/app_theme.dart';
import '../services/app_state.dart';
import '../widgets/frosted_glass_card.dart';
import '../widgets/pill_button.dart';


class AqiDetailScreen extends StatelessWidget {
  const AqiDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);
    final aqi = state.weatherSummary?.aqi ?? 225.0;
    final pm25 = state.weatherSummary?.pm25 ?? 78.5;
    final pm10 = state.weatherSummary?.pm10 ?? 239.3;
    final dust = state.weatherSummary?.dust ?? 359.0;

    final pollutants = [
      PollutantDetail('PM2.5', pm25.toStringAsFixed(1), 'µg/m³', pm25 > 55 ? 'Unhealthy' : 'Moderate', (pm25 / 150.0).clamp(0.1, 1.0), MausamColors.errorRed),
      PollutantDetail('PM10', pm10.toStringAsFixed(1), 'µg/m³', pm10 > 150 ? 'High' : 'Moderate', (pm10 / 300.0).clamp(0.1, 1.0), MausamColors.warningAmber),
      PollutantDetail('Dust & Aerosols', dust.toStringAsFixed(1), 'µg/m³', dust > 200 ? 'Elevated' : 'Good', (dust / 500.0).clamp(0.1, 1.0), MausamColors.healthTeal),
      PollutantDetail('UV Index', (state.weatherSummary?.uvIndex ?? 0).toStringAsFixed(1), 'Index', 'Normal', 0.2, MausamColors.tertiary),
    ];

    final aqiColor = aqi > 200 ? MausamColors.errorRed : (aqi > 100 ? MausamColors.warningAmber : MausamColors.healthTeal);
    final aqiStatus = aqi > 200 ? 'Unhealthy / Very Poor' : (aqi > 100 ? 'Moderate' : 'Good');

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: MausamColors.primary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Air Quality Index', style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: MausamColors.primary)),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            FrostedGlassCard(
              accentColor: aqiColor,
              child: Row(
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: aqiColor.withValues(alpha: 0.15),
                    ),
                    child: Center(
                      child: Text(
                        '${aqi.toInt()}',
                        style: Theme.of(context).textTheme.headlineLarge?.copyWith(color: aqiColor, fontSize: 24),
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Air Quality: $aqiStatus', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 16)),
                        const SizedBox(height: 4),
                        Text(
                          aqi > 150
                              ? 'High particulate matter detected. Sensitive groups should wear masks outdoors.'
                              : 'Conditions are favorable for outdoor runs and routine activities.',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text('POLLUTANT BREAKDOWN (LIVE SENSOR DATA)', style: Theme.of(context).textTheme.labelSmall),
            const SizedBox(height: 12),
            ...pollutants.map((p) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: FrostedGlassCard(
                  accentColor: p.color,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(p.name, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 15)),
                          Text('${p.value} ${p.unit} (${p.status})', style: TextStyle(color: p.color, fontWeight: FontWeight.bold, fontSize: 12)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: p.progress,
                        backgroundColor: MausamColors.surfaceContainerHigh,
                        color: p.color,
                        minHeight: 6,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}