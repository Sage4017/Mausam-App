import 'package:flutter/material.dart';
import '../models/app_models.dart';
import '../core/app_theme.dart';
import '../services/app_state.dart';
import '../widgets/frosted_glass_card.dart';
import '../widgets/pill_button.dart';


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
          Center(
            child: Padding(
              padding: const EdgeInsets.all(28.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: MausamColors.primaryContainer,
                      boxShadow: [
                        BoxShadow(
                          color: MausamColors.primary.withValues(alpha: 0.2),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        )
                      ],
                    ),
                    child: const Icon(Icons.wb_cloudy_rounded, size: 48, color: MausamColors.onPrimary),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'Weather for What Matters to You',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Personalized atmospheric insights tailored directly to your routine, health, and hobbies.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 48),
                  SizedBox(
                    width: double.infinity,
                    child: PillButton(
                      label: 'Get Started',
                      icon: Icons.arrow_forward,
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
        ],
      ),
    );
  }
}