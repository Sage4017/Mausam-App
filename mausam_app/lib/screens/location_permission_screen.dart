import 'package:flutter/material.dart';
import '../models/app_models.dart';
import '../core/app_theme.dart';
import '../services/app_state.dart';
import '../widgets/frosted_glass_card.dart';
import '../widgets/pill_button.dart';


import 'persona_selection_screen.dart';

class LocationPermissionScreen extends StatelessWidget {
  const LocationPermissionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);
    final lat = state.weatherSummary?.latitude ?? 28.6139;
    final lon = state.weatherSummary?.longitude ?? 77.2090;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: MausamColors.primary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: MausamColors.primaryContainer.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.location_on, size: 36, color: MausamColors.primary),
              ),
              const SizedBox(height: 24),
              Text('Live Microclimate Location', style: Theme.of(context).textTheme.headlineLarge),
              const SizedBox(height: 12),
              Text(
                'Mausam connects to Open-Meteo & IMD models for real-time weather analytics and active warnings.',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const Spacer(),
              FrostedGlassCard(
                child: Row(
                  children: [
                    const Icon(Icons.my_location, color: MausamColors.primary),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Active Region: New Delhi', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 16)),
                          Text('Lat: ${lat.toStringAsFixed(3)}, Lon: ${lon.toStringAsFixed(3)}', style: Theme.of(context).textTheme.bodyMedium),
                        ],
                      ),
                    ),
                    const Icon(Icons.check_circle, color: MausamColors.primary),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: PillButton(
                  label: 'Confirm Live Region',
                  icon: Icons.check,
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const PersonaSelectionScreen()),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}