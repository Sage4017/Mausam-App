import 'package:flutter/material.dart';
import '../core/app_theme.dart';
import '../widgets/pill_button.dart';
import '../widgets/imd_widgets.dart';
import 'location_permission_screen.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
