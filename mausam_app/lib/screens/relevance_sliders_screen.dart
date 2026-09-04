import 'package:flutter/material.dart';
import '../models/app_models.dart';
import '../core/app_theme.dart';
import '../services/app_state.dart';
import '../widgets/frosted_glass_card.dart';
import '../widgets/pill_button.dart';


import 'main_shell_screen.dart';

class RelevanceSlidersScreen extends StatelessWidget {
  const RelevanceSlidersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: MausamColors.primary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Priority Weights', style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: MausamColors.primary)),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Rate Importance (out of 10)', style: Theme.of(context).textTheme.headlineLarge),
              const SizedBox(height: 6),
              Text(
                'Rate each category from 1 to 10 to determine how strongly the AI engine prioritizes it.',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 24),
              Expanded(
                child: ListView(
                  children: state.selectedPersonas.map((p) {
                    final scoreOutOf10 = state.personaWeights[p] ?? 8.0;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: FrostedGlassCard(
                        accentColor: p.color,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(p.icon, color: p.color),
                                const SizedBox(width: 12),
                                Text(p.title, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 16)),
                                const Spacer(),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: p.color.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    'Score: ${scoreOutOf10.round()} / 10',
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: p.color),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Slider(
                              value: scoreOutOf10,
                              min: 1.0,
                              max: 10.0,
                              divisions: 9,
                              activeColor: p.color,
                              inactiveColor: MausamColors.surfaceContainerHigh,
                              label: '${scoreOutOf10.round()} / 10',
                              onChanged: (val) => state.updateWeight(p, val),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: PillButton(
                  label: 'Finish Setup & Sync Live Feed',
                  icon: Icons.done_all,
                  onPressed: () async {
                    await state.submitSurveyAnswers();
                    if (context.mounted) {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (_) => const MainShellScreen()),
                        (route) => false,
                      );
                    }
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