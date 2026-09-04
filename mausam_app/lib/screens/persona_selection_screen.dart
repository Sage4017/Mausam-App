import 'package:flutter/material.dart';
import '../models/app_models.dart';
import '../core/app_theme.dart';
import '../services/app_state.dart';
import '../widgets/frosted_glass_card.dart';
import '../widgets/pill_button.dart';


import 'persona_question_screen.dart';
import 'relevance_sliders_screen.dart';

class PersonaSelectionScreen extends StatelessWidget {
  const PersonaSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);
    final count = state.selectedPersonas.length;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Mausam Priorities', style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: MausamColors.primary)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Column(
                children: [
                  Text('What matters to you today?', style: Theme.of(context).textTheme.headlineLarge),
                  const SizedBox(height: 6),
                  Text('Choose up to 4 priorities to calibrate your live scoring feed.', style: Theme.of(context).textTheme.bodyLarge),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: MausamColors.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '$count OF 4 SELECTED',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(color: MausamColors.primary),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  childAspectRatio: 1.1,
                ),
                itemCount: PersonaType.values.length,
                itemBuilder: (context, index) {
                  final persona = PersonaType.values[index];
                  final isSelected = state.selectedPersonas.contains(persona);

                  return InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => state.togglePersona(persona),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isSelected ? MausamColors.primaryContainer.withValues(alpha: 0.18) : MausamColors.surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected ? MausamColors.primary : MausamColors.outlineVariant,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Stack(
                        children: [
                          if (isSelected)
                            const Positioned(
                              top: 0,
                              right: 0,
                              child: CircleAvatar(
                                radius: 10,
                                backgroundColor: MausamColors.primary,
                                child: Icon(Icons.check, size: 12, color: Colors.white),
                              ),
                            ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(persona.icon, size: 36, color: isSelected ? MausamColors.primary : MausamColors.secondary),
                              const SizedBox(height: 10),
                              Text(
                                persona.title,
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                  fontSize: 15,
                                  color: isSelected ? MausamColors.primary : MausamColors.onSurfaceStrong,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                child: PillButton(
                  label: 'Start Questions (${state.selectedPersonas.length} Focuses)',
                  icon: Icons.arrow_forward,
                  onPressed: () {
                    // Navigate to the first selected persona screen
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => PersonaQuestionScreen(
                          personaList: state.selectedPersonas.toList(),
                          currentIndex: 0,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}