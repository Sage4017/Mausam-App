import 'relevance_sliders_screen.dart';
import '../models/app_models.dart';
import 'package:flutter/material.dart';
import '../core/app_theme.dart';
import '../services/app_state.dart';
import '../widgets/frosted_glass_card.dart';
import '../widgets/pill_button.dart';
import 'persona_question_screen.dart';

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
                  Text('Choose up to 4 priorities (or proceed with general forecast).', style: Theme.of(context).textTheme.bodyLarge),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: count > 0 ? MausamColors.primaryContainer.withValues(alpha: 0.15) : MausamColors.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '$count OF 4 SELECTED',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: count > 0 ? MausamColors.primary : MausamColors.secondary,
                        fontWeight: FontWeight.bold,
                      ),
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
                    onTap: () {
                      if (!isSelected && count >= 4) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('You can select up to 4 priorities maximum.'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                        return;
                      }
                      state.togglePersona(persona);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isSelected ? persona.color.withValues(alpha: 0.18) : MausamColors.surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected ? persona.color : MausamColors.outlineVariant,
                          width: isSelected ? 2.2 : 1,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: persona.color.withValues(alpha: 0.2),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                )
                              ]
                            : null,
                      ),
                      child: Stack(
                        children: [
                          if (isSelected)
                            Positioned(
                              top: 0,
                              right: 0,
                              child: CircleAvatar(
                                radius: 10,
                                backgroundColor: persona.color,
                                child: const Icon(Icons.check, size: 12, color: Colors.white),
                              ),
                            ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(persona.icon, size: 36, color: isSelected ? persona.color : MausamColors.secondary),
                              const SizedBox(height: 10),
                              Text(
                                persona.title,
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                  fontSize: 15,
                                  color: isSelected ? persona.color : MausamColors.onSurfaceStrong,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
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
                  label: count > 0
                      ? 'Start Questions ($count Focuses)'
                      : 'Continue with General Forecast',
                  icon: Icons.arrow_forward,
                  onPressed: () {
                    if (count > 0) {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => PersonaQuestionScreen(
                            personaList: state.selectedPersonas.toList(),
                            currentIndex: 0,
                          ),
                        ),
                      );
                    } else {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const RelevanceSlidersScreen(),
                        ),
                      );
                    }
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

// --- Dedicated Persona Question Screen (Expansive, Full-Viewport Layout) ---