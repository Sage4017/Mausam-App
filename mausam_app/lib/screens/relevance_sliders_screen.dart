import 'package:flutter/material.dart';
import '../core/app_theme.dart';
import '../services/app_state.dart';
import '../widgets/pill_button.dart';
import '../widgets/frosted_glass_card.dart';
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
                'Smoothly drag each slider to fine-tune how strongly the scoring engine weights your selected focuses.',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 20),
              Expanded(
                child: state.selectedPersonas.isEmpty
                    ? Center(
                        child: FrostedGlassCard(
                          accentColor: MausamColors.primary,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.wb_sunny_rounded, size: 48, color: MausamColors.warningAmber),
                              const SizedBox(height: 12),
                              Text('General Atmospheric Scoring Active', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 16)),
                              const SizedBox(height: 6),
                              Text(
                                'No specific priorities were selected. Mausam will automatically rank cards based on live weather severity and regional forecasts.',
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                      )
                    : ListView(
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
                                      CircleAvatar(
                                        radius: 16,
                                        backgroundColor: p.color.withValues(alpha: 0.15),
                                        child: Icon(p.icon, color: p.color, size: 18),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(p.title, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 16)),
                                            Text(p.description, style: const TextStyle(fontSize: 11, color: MausamColors.secondary)),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: p.color.withValues(alpha: 0.15),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          '${scoreOutOf10.toStringAsFixed(1)} / 10',
                                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: p.color),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  SliderTheme(
                                    data: SliderTheme.of(context).copyWith(
                                      activeTrackColor: p.color,
                                      inactiveTrackColor: MausamColors.surfaceContainerHigh,
                                      thumbColor: p.color,
                                      overlayColor: p.color.withValues(alpha: 0.2),
                                      trackHeight: 6,
                                      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
                                    ),
                                    child: Slider(
                                      value: scoreOutOf10,
                                      min: 1.0,
                                      max: 10.0,
                                      // Continuous smooth sliding without discrete jumping
                                      onChanged: (val) => state.updateWeight(p, double.parse(val.toStringAsFixed(1))),
                                    ),
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

// ============================================================================
// 5. MASTER SHELL & ROUTER
// ============================================================================

