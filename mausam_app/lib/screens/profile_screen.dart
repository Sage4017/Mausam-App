import 'package:flutter/material.dart';
import '../models/app_models.dart';
import '../core/app_theme.dart';
import '../services/app_state.dart';
import '../widgets/frosted_glass_card.dart';
import '../widgets/pill_button.dart';


class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Row(
              children: [
                const CircleAvatar(
                  radius: 34,
                  backgroundColor: MausamColors.primaryContainer,
                  child: Icon(Icons.person, size: 38, color: Colors.white),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Mausam User', style: Theme.of(context).textTheme.headlineLarge?.copyWith(fontSize: 20)),
                    Text('FastAPI Scoring Connected', style: Theme.of(context).textTheme.bodyMedium),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),

            Text('ACTIVE FOCUS PRIORITIES', style: Theme.of(context).textTheme.labelSmall),
            const SizedBox(height: 12),
            FrostedGlassCard(
              child: Column(
                children: state.selectedPersonas.map((p) {
                  final scoreOutOf10 = state.personaWeights[p] ?? 8.0;
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(p.icon, color: p.color),
                    title: Text(p.title),
                    subtitle: Text('Score: ${scoreOutOf10.round()}/10 · ${p.description}', style: const TextStyle(fontSize: 11)),
                    trailing: const Icon(Icons.check_circle, color: MausamColors.primary, size: 18),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 24),

            Text('PREFERENCES', style: Theme.of(context).textTheme.labelSmall),
            const SizedBox(height: 12),
            FrostedGlassCard(
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Text('Metric Units (°C, km/h)'),
                    subtitle: Text(state.isCelsius ? 'Celsius & km/h' : 'Fahrenheit & mph'),
                    value: state.isCelsius,
                    onChanged: (val) => state.toggleUnits(),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    title: const Text('Sync Backend Feed Now'),
                    subtitle: const Text('Refresh scored cards from FastAPI server'),
                    trailing: const Icon(Icons.sync, color: MausamColors.primary),
                    onTap: () => state.fetchLiveFeed(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}