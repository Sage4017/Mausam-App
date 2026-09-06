import 'package:flutter/material.dart';
import '../core/app_theme.dart';
import '../services/app_state.dart';
import '../widgets/frosted_glass_card.dart';
import '../widgets/pill_button.dart';
import '../widgets/imd_widgets.dart';
import 'location_permission_screen.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);
    final lat = state.weatherSummary?.latitude ?? 28.6139;
    final lon = state.weatherSummary?.longitude ?? 77.2090;

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [MausamColors.surface, MausamColors.surfaceContainerHigh],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Official IMD Branding Crest
                    const ImdLogoWidget(size: 82),
                    const SizedBox(height: 24),

                    Text(
                      'Weather for What Matters to You',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Hyper-personalized atmospheric insights calibrated to your routine, health, and local microclimate.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 28),

                    // Direct Live Microclimate Region Access on First Screen
                    FrostedGlassCard(
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: MausamColors.primaryContainer.withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.location_on_rounded, size: 28, color: MausamColors.primary),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      'Active Region: New Delhi',
                                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 16),
                                    ),
                                    const SizedBox(width: 6),
                                    const Icon(Icons.verified, size: 16, color: Color(0xFF138808)),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Lat: ${lat.toStringAsFixed(3)} ┬╖ Lon: ${lon.toStringAsFixed(3)} ┬╖ Tropical Zone',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 12),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'Live IMD & Satellite Telemetry Calibrated',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: MausamColors.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Direct Navigation to Persona Selection (Screen 2 removed)
                    SizedBox(
                      width: double.infinity,
                      child: PillButton(
                        label: 'Get Started & Calibrate',
                        icon: Icons.arrow_forward_rounded,
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const LocationPermissionScreen()),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
