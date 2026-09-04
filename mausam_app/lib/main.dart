import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'services/api_client.dart';
import 'models/app_models.dart';
import 'core/app_theme.dart';
import 'services/app_state.dart';
import 'screens/onboarding/onboarding_screen.dart';

void main() {
  runApp(const MausamApp());
}

// ============================================================================
// 1. DESIGN SYSTEM & THEME TOKENS (Atmospheric Premium)
// ============================================================================





// ============================================================================
// 2. DATA MODELS & STATE MANAGEMENT (Live API Integrated)
// ============================================================================

















// Inherited Provider for seamless state sharing across all screens


// ============================================================================
// 3. REUSABLE ATOMIC & GLASSMORPHIC COMPONENTS
// ============================================================================

class FrostedGlassCard extends StatelessWidget {
  final Widget child;
  final Color? accentColor;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;

  const FrostedGlassCard({
    super.key,
    required this.child,
    this.accentColor,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: MausamColors.surfaceContainerLowest.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: MausamColors.surfaceVariant),
        boxShadow: [
          BoxShadow(
            color: MausamColors.primary.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Stack(
            children: [
              if (accentColor != null)
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  child: Container(
                    width: 4,
                    decoration: BoxDecoration(
                      color: accentColor,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        bottomLeft: Radius.circular(16),
                      ),
                    ),
                  ),
                ),
              Padding(
                padding: padding,
                child: child,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PillButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback onPressed;
  final bool isPrimary;
  final double height;

  const PillButton({
    super.key,
    required this.label,
    this.icon,
    required this.onPressed,
    this.isPrimary = true,
    this.height = 50,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: isPrimary ? MausamColors.primary : MausamColors.surfaceContainerHigh,
          foregroundColor: isPrimary ? MausamColors.onPrimary : MausamColors.primary,
          elevation: isPrimary ? 3 : 0,
          shape: const StadiumBorder(),
          padding: const EdgeInsets.symmetric(horizontal: 24),
        ),
        onPressed: onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label, style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: isPrimary ? MausamColors.onPrimary : MausamColors.primary,
              fontWeight: FontWeight.bold,
            )),
            if (icon != null) ...[
              const SizedBox(width: 8),
              Icon(icon, size: 18, color: isPrimary ? MausamColors.onPrimary : MausamColors.primary),
            ],
          ],
        ),
      ),
    );
  }
}

IconData getWeatherIcon(String condition) {
  final c = condition.toLowerCase();
  if (c.contains('rain') || c.contains('shower') || c.contains('drizzle')) return Icons.water_drop;
  if (c.contains('thunder') || c.contains('storm')) return Icons.thunderstorm;
  if (c.contains('cloud') || c.contains('overcast')) return Icons.cloud;
  if (c.contains('snow')) return Icons.ac_unit;
  if (c.contains('clear') || c.contains('sun')) return Icons.wb_sunny_rounded;
  return Icons.wb_cloudy_rounded;
}

// ============================================================================
// 4. ONBOARDING FLOW WITH DEDICATED PER-PERSONA SCREENS
// ============================================================================

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

// --- Dedicated Persona Question Screen (Sequential Step-by-Step) ---
class PersonaQuestionScreen extends StatefulWidget {
  final List<PersonaType> personaList;
  final int currentIndex;

  const PersonaQuestionScreen({
    super.key,
    required this.personaList,
    required this.currentIndex,
  });

  @override
  State<PersonaQuestionScreen> createState() => _PersonaQuestionScreenState();
}

class _PersonaQuestionScreenState extends State<PersonaQuestionScreen> {
  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);
    final persona = widget.personaList[widget.currentIndex];
    final total = widget.personaList.length;
    final stepNum = widget.currentIndex + 1;
    final isLast = widget.currentIndex == total - 1;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: MausamColors.primary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Step $stepNum of $total',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(fontSize: 13, color: MausamColors.primary),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Persona Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: persona.color.withValues(alpha: 0.18),
                    child: Icon(persona.icon, color: persona.color, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${persona.title} Probing',
                          style: Theme.of(context).textTheme.headlineLarge?.copyWith(fontSize: 22),
                        ),
                        Text(
                          'Detailed environmental criteria',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: MausamColors.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'STEP $stepNum/$total',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: MausamColors.primary),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 16),

            // Question List for this specific persona
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                children: _buildQuestionsForPersona(context, persona, state),
              ),
            ),

            // Bottom Action Button
            Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                child: PillButton(
                  label: isLast ? 'Continue to Priority Weights' : 'Next: ${widget.personaList[widget.currentIndex + 1].title}',
                  icon: isLast ? Icons.done : Icons.arrow_forward,
                  onPressed: () {
                    if (isLast) {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const RelevanceSlidersScreen()),
                      );
                    } else {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => PersonaQuestionScreen(
                            personaList: widget.personaList,
                            currentIndex: widget.currentIndex + 1,
                          ),
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

  List<Widget> _buildQuestionsForPersona(BuildContext context, PersonaType persona, AppState state) {
    switch (persona) {
      // 1. Fitness
      case PersonaType.fitness:
        final selectedActs = List<String>.from(state.probingAnswers['fitness_activities'] ?? ['Running']);
        final startTime = state.probingAnswers['fitness_start_time'] ?? '06:00 AM';
        final endTime = state.probingAnswers['fitness_end_time'] ?? '07:30 AM';
        final loc = state.probingAnswers['fitness_location'] ?? 'Park or trail';

        return [
          _buildQuestionTitle('Q1. What are you doing today?', isMulti: true),
          _buildMultiSelectWrap(
            options: ['Running', 'Cycling', 'Walking', 'Outdoor workout', 'Sport'],
            selectedList: selectedActs,
            color: persona.color,
            onToggle: (opt) => state.toggleMultiSelection('fitness_activities', opt),
          ),
          const SizedBox(height: 24),
          _buildQuestionTitle('Q2. When? (Start time — End time)'),
          _buildTimeRangeCard(
            personaColor: persona.color,
            startValue: startTime,
            endValue: endTime,
            onStartChanged: (v) => state.updateProbingAnswer('fitness_start_time', v),
            onEndChanged: (v) => state.updateProbingAnswer('fitness_end_time', v),
          ),
          const SizedBox(height: 24),
          _buildQuestionTitle('Q3. Where?'),
          _buildSingleSelectWrap(
            options: ['Current location', 'Park or trail', 'Road', 'Sports ground', 'Other'],
            selected: loc,
            color: persona.color,
            onSelect: (opt) => state.updateProbingAnswer('fitness_location', opt),
          ),
        ];

      // 2. Health
      case PersonaType.health:
        final selectedPlans = List<String>.from(state.probingAnswers['health_plans'] ?? ['Exercise', 'Spend time outdoors']);
        final startTime = state.probingAnswers['health_start_time'] ?? '07:00 AM';
        final endTime = state.probingAnswers['health_end_time'] ?? '09:00 AM';
        final loc = state.probingAnswers['health_location'] ?? 'Current location';

        return [
          _buildQuestionTitle('Q1. What are you planning to do?', isMulti: true),
          _buildMultiSelectWrap(
            options: ['Walk', 'Exercise', 'Spend time outdoors', 'Work outdoors', 'Commute'],
            selectedList: selectedPlans,
            color: persona.color,
            onToggle: (opt) => state.toggleMultiSelection('health_plans', opt),
          ),
          const SizedBox(height: 24),
          _buildQuestionTitle('Q2. When? (Start time — End time)'),
          _buildTimeRangeCard(
            personaColor: persona.color,
            startValue: startTime,
            endValue: endTime,
            onStartChanged: (v) => state.updateProbingAnswer('health_start_time', v),
            onEndChanged: (v) => state.updateProbingAnswer('health_end_time', v),
          ),
          const SizedBox(height: 24),
          _buildQuestionTitle('Q3. Where?'),
          _buildSingleSelectWrap(
            options: ['Current location', 'Other location'],
            selected: loc,
            color: persona.color,
            onSelect: (opt) => state.updateProbingAnswer('health_location', opt),
          ),
        ];

      // 3. Beach / Surf
      case PersonaType.beach:
        final selectedPlans = List<String>.from(state.probingAnswers['beach_plans'] ?? ['Surf', 'Swim']);
        final startTime = state.probingAnswers['beach_start_time'] ?? '02:00 PM';
        final endTime = state.probingAnswers['beach_end_time'] ?? '05:00 PM';
        final loc = state.probingAnswers['beach_location'] ?? 'Local coast';

        return [
          _buildQuestionTitle('Q1. What are you planning to do?', isMulti: true),
          _buildMultiSelectWrap(
            options: ['Surf', 'Swim', 'Water sports', 'Beach walk', 'Relax'],
            selectedList: selectedPlans,
            color: persona.color,
            onToggle: (opt) => state.toggleMultiSelection('beach_plans', opt),
          ),
          const SizedBox(height: 24),
          _buildQuestionTitle('Q2. When? (Start time — End time)'),
          _buildTimeRangeCard(
            personaColor: persona.color,
            startValue: startTime,
            endValue: endTime,
            onStartChanged: (v) => state.updateProbingAnswer('beach_start_time', v),
            onEndChanged: (v) => state.updateProbingAnswer('beach_end_time', v),
          ),
          const SizedBox(height: 24),
          _buildQuestionTitle('Q3. Which beach?'),
          _buildSingleSelectWrap(
            options: ['Local coast', 'Nearby surf zone', 'Public beach', 'Other beach'],
            selected: loc,
            color: persona.color,
            onSelect: (opt) => state.updateProbingAnswer('beach_location', opt),
          ),
        ];

      // 4. Travel
      case PersonaType.travel:
        final dest = state.probingAnswers['travel_destination'] ?? 'Mumbai, India';
        final dep = state.probingAnswers['travel_departure'] ?? '08:00 AM';
        final arr = state.probingAnswers['travel_arrival'] ?? '11:30 AM';
        final selectedModes = List<String>.from(state.probingAnswers['travel_modes'] ?? ['Flight', 'Car']);

        return [
          _buildQuestionTitle('Q1. Where are you going?'),
          _buildSingleSelectWrap(
            options: ['Local Region', 'Mumbai, India', 'Bengaluru, India', 'Goa Coast', 'Hill Station', 'Other'],
            selected: dest,
            color: persona.color,
            onSelect: (opt) => state.updateProbingAnswer('travel_destination', opt),
          ),
          const SizedBox(height: 24),
          _buildQuestionTitle('Q2. When is your journey? (Departure — Arrival)'),
          _buildTimeRangeCard(
            personaColor: persona.color,
            startLabel: 'Departure',
            endLabel: 'Arrival',
            startValue: dep,
            endValue: arr,
            onStartChanged: (v) => state.updateProbingAnswer('travel_departure', v),
            onEndChanged: (v) => state.updateProbingAnswer('travel_arrival', v),
          ),
          const SizedBox(height: 24),
          _buildQuestionTitle('Q3. How are you travelling?', isMulti: true),
          _buildMultiSelectWrap(
            options: ['Flight', 'Car', 'Train', 'Bus', 'Other'],
            selectedList: selectedModes,
            color: persona.color,
            onToggle: (opt) => state.toggleMultiSelection('travel_modes', opt),
          ),
        ];

      // 5. Family
      case PersonaType.family:
        final selectedPlans = List<String>.from(state.probingAnswers['family_plans'] ?? ['Outdoor play', 'Park visit']);
        final startTime = state.probingAnswers['family_start_time'] ?? '04:30 PM';
        final endTime = state.probingAnswers['family_end_time'] ?? '06:30 PM';
        final loc = state.probingAnswers['family_location'] ?? 'Park or playground';

        return [
          _buildQuestionTitle('Q1. What are you planning?', isMulti: true),
          _buildMultiSelectWrap(
            options: ['School commute', 'Outdoor play', 'Family outing', 'Park visit', 'Family travel'],
            selectedList: selectedPlans,
            color: persona.color,
            onToggle: (opt) => state.toggleMultiSelection('family_plans', opt),
          ),
          const SizedBox(height: 24),
          _buildQuestionTitle('Q2. When? (Start time — End time)'),
          _buildTimeRangeCard(
            personaColor: persona.color,
            startValue: startTime,
            endValue: endTime,
            onStartChanged: (v) => state.updateProbingAnswer('family_start_time', v),
            onEndChanged: (v) => state.updateProbingAnswer('family_end_time', v),
          ),
          const SizedBox(height: 24),
          _buildQuestionTitle('Q3. Where?'),
          _buildSingleSelectWrap(
            options: ['Current location', 'Park or playground', 'Other location'],
            selected: loc,
            color: persona.color,
            onSelect: (opt) => state.updateProbingAnswer('family_location', opt),
          ),
        ];

      // 6. Agriculture
      case PersonaType.agriculture:
        final selectedPlans = List<String>.from(state.probingAnswers['agri_plans'] ?? ['Irrigate', 'Spray', 'Inspect']);
        final crop = state.probingAnswers['agri_crop'] ?? 'Vegetables';
        final stage = state.probingAnswers['agri_stage'] ?? 'Growing';
        final loc = state.probingAnswers['agri_location'] ?? 'Local farm / field';

        return [
          _buildQuestionTitle('Q1. What are you planning to do?', isMulti: true),
          _buildMultiSelectWrap(
            options: ['Sow', 'Irrigate', 'Harvest', 'Spray', 'Inspect', 'Prepare field'],
            selectedList: selectedPlans,
            color: persona.color,
            onToggle: (opt) => state.toggleMultiSelection('agri_plans', opt),
          ),
          const SizedBox(height: 24),
          _buildQuestionTitle('Q2. What are you growing and what stage is it in?'),
          FrostedGlassCard(
            accentColor: persona.color,
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Select Crop:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  children: ['Wheat / Grain', 'Vegetables', 'Cotton / Cash', 'Fruit Orchards', 'Flowers', 'Other'].map((c) {
                    final isSel = crop == c;
                    return ChoiceChip(
                      label: Text(c, style: TextStyle(fontSize: 11, color: isSel ? Colors.white : MausamColors.tertiary)),
                      selected: isSel,
                      selectedColor: MausamColors.tertiary,
                      backgroundColor: MausamColors.surfaceContainerLowest,
                      onSelected: (val) {
                        if (val) state.updateProbingAnswer('agri_crop', c);
                      },
                    );
                  }).toList(),
                ),
                const Divider(height: 18),
                const Text('Growth Stage:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  children: ['Preparing', 'Planted', 'Growing', 'Flowering', 'Harvesting'].map((s) {
                    final isSel = stage == s;
                    return ChoiceChip(
                      label: Text(s, style: TextStyle(fontSize: 11, color: isSel ? Colors.white : MausamColors.primary)),
                      selected: isSel,
                      selectedColor: MausamColors.primary,
                      backgroundColor: MausamColors.surfaceContainerLowest,
                      onSelected: (val) {
                        if (val) state.updateProbingAnswer('agri_stage', s);
                      },
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _buildQuestionTitle('Q3. Where is your field/garden?'),
          _buildSingleSelectWrap(
            options: ['Current farm / field', 'Local agricultural zone', 'Home garden / Nursery', 'Other location'],
            selected: loc,
            color: persona.color,
            onSelect: (opt) => state.updateProbingAnswer('agri_location', opt),
          ),
        ];

      // 7. Commute
      case PersonaType.commute:
        final dest = state.probingAnswers['commute_destination'] ?? 'Office / Work';
        final startTime = state.probingAnswers['commute_start_time'] ?? '08:30 AM';
        final endTime = state.probingAnswers['commute_end_time'] ?? '09:30 AM';
        final selectedModes = List<String>.from(state.probingAnswers['commute_modes'] ?? ['Car', 'Bike']);

        return [
          _buildQuestionTitle('Q1. Where are you going?'),
          _buildSingleSelectWrap(
            options: ['Office / Work', 'College / School', 'Market / Errands', 'Other destination'],
            selected: dest,
            color: persona.color,
            onSelect: (opt) => state.updateProbingAnswer('commute_destination', opt),
          ),
          const SizedBox(height: 24),
          _buildQuestionTitle('Q2. When is your commute? (Start time — End time)'),
          _buildTimeRangeCard(
            personaColor: persona.color,
            startValue: startTime,
            endValue: endTime,
            onStartChanged: (v) => state.updateProbingAnswer('commute_start_time', v),
            onEndChanged: (v) => state.updateProbingAnswer('commute_end_time', v),
          ),
          const SizedBox(height: 24),
          _buildQuestionTitle('Q3. How are you travelling?', isMulti: true),
          _buildMultiSelectWrap(
            options: ['Car', 'Bike', 'Bus', 'Train', 'Walking'],
            selectedList: selectedModes,
            color: persona.color,
            onToggle: (opt) => state.toggleMultiSelection('commute_modes', opt),
          ),
        ];

      // 8. Event
      case PersonaType.event:
        final selectedPlans = List<String>.from(state.probingAnswers['event_plans'] ?? ['Outdoor gathering']);
        final startTime = state.probingAnswers['event_start_time'] ?? '06:00 PM';
        final endTime = state.probingAnswers['event_end_time'] ?? '10:00 PM';
        final loc = state.probingAnswers['event_location'] ?? 'Open lawn / Garden';

        return [
          _buildQuestionTitle('Q1. What are you planning?', isMulti: true),
          _buildMultiSelectWrap(
            options: ['Wedding', 'Party', 'Sports event', 'Concert', 'Outdoor gathering', 'Other'],
            selectedList: selectedPlans,
            color: persona.color,
            onToggle: (opt) => state.toggleMultiSelection('event_plans', opt),
          ),
          const SizedBox(height: 24),
          _buildQuestionTitle('Q2. When is your event? (Start — End)'),
          _buildTimeRangeCard(
            personaColor: persona.color,
            startValue: startTime,
            endValue: endTime,
            onStartChanged: (v) => state.updateProbingAnswer('event_start_time', v),
            onEndChanged: (v) => state.updateProbingAnswer('event_end_time', v),
          ),
          const SizedBox(height: 24),
          _buildQuestionTitle('Q3. Where is it happening?'),
          _buildSingleSelectWrap(
            options: ['Open lawn / Garden', 'Banquet / Resort', 'Stadium / Ground', 'Current location', 'Other'],
            selected: loc,
            color: persona.color,
            onSelect: (opt) => state.updateProbingAnswer('event_location', opt),
          ),
        ];
    }
  }

  Widget _buildQuestionTitle(String title, {bool isMulti = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: MausamColors.onSurfaceStrong),
            ),
          ),
          if (isMulti)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: MausamColors.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text('MULTI-SELECT', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: MausamColors.secondary)),
            )
        ],
      ),
    );
  }

  Widget _buildMultiSelectWrap({
    required List<String> options,
    required List<String> selectedList,
    required Color color,
    required Function(String) onToggle,
  }) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.map((opt) {
        final isSel = selectedList.contains(opt);
        return FilterChip(
          label: Text(opt, style: TextStyle(fontSize: 12, fontWeight: isSel ? FontWeight.bold : FontWeight.normal, color: isSel ? Colors.white : MausamColors.primary)),
          selected: isSel,
          selectedColor: color,
          backgroundColor: MausamColors.surfaceContainerLowest,
          checkmarkColor: Colors.white,
          shape: const StadiumBorder(),
          onSelected: (_) => onToggle(opt),
        );
      }).toList(),
    );
  }

  Widget _buildSingleSelectWrap({
    required List<String> options,
    required String selected,
    required Color color,
    required Function(String) onSelect,
  }) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.map((opt) {
        final isSel = selected == opt;
        return ChoiceChip(
          label: Text(opt, style: TextStyle(fontSize: 12, fontWeight: isSel ? FontWeight.bold : FontWeight.normal, color: isSel ? Colors.white : MausamColors.primary)),
          selected: isSel,
          selectedColor: color,
          backgroundColor: MausamColors.surfaceContainerLowest,
          shape: const StadiumBorder(),
          onSelected: (val) {
            if (val) onSelect(opt);
          },
        );
      }).toList(),
    );
  }

  Widget _buildTimeRangeCard({
    required Color personaColor,
    String startLabel = 'Start Time',
    String endLabel = 'End Time',
    required String startValue,
    required String endValue,
    required Function(String) onStartChanged,
    required Function(String) onEndChanged,
  }) {
    return FrostedGlassCard(
      accentColor: personaColor,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(startLabel, style: const TextStyle(fontSize: 11, color: MausamColors.secondary, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              DropdownButton<String>(
                value: startValue,
                underline: const SizedBox(),
                isDense: true,
                items: ['05:00 AM', '06:00 AM', '06:30 AM', '07:00 AM', '08:00 AM', '08:30 AM', '02:00 PM', '04:30 PM', '06:00 PM']
                    .map((t) => DropdownMenuItem(value: t, child: Text(t, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13))))
                    .toList(),
                onChanged: (v) {
                  if (v != null) onStartChanged(v);
                },
              ),
            ],
          ),
          const Icon(Icons.arrow_forward, size: 18, color: MausamColors.secondary),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(endLabel, style: const TextStyle(fontSize: 11, color: MausamColors.secondary, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              DropdownButton<String>(
                value: endValue,
                underline: const SizedBox(),
                isDense: true,
                items: ['06:30 AM', '07:30 AM', '08:30 AM', '09:00 AM', '09:30 AM', '11:30 AM', '05:00 PM', '06:30 PM', '10:00 PM']
                    .map((t) => DropdownMenuItem(value: t, child: Text(t, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13))))
                    .toList(),
                onChanged: (v) {
                  if (v != null) onEndChanged(v);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// --- Relevance Sliders Screen (Rated out of 10 instead of percentage) ---
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

// ============================================================================
// 5. MASTER SHELL & ROUTER
// ============================================================================

class MainShellScreen extends StatelessWidget {
  const MainShellScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);

    final screens = const [
      HomeScreen(),
      ExploreScreen(),
      MausamAIScreen(),
      AlertsScreen(),
      ProfileScreen(),
    ];

    return Scaffold(
      body: screens[state.currentBottomNavIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: MausamColors.surface.withValues(alpha: 0.95),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
            )
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _navItem(context, 0, Icons.home_rounded, 'Home', state.currentBottomNavIndex == 0),
                _navItem(context, 1, Icons.explore_rounded, 'Explore', state.currentBottomNavIndex == 1),
                _navItem(context, 2, Icons.smart_toy_rounded, 'Ask AI', state.currentBottomNavIndex == 2),
                _navItem(context, 3, Icons.notifications_rounded, 'Alerts', state.currentBottomNavIndex == 3),
                _navItem(context, 4, Icons.person_rounded, 'Me', state.currentBottomNavIndex == 4),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _navItem(BuildContext context, int index, IconData icon, String label, bool isSelected) {
    final state = AppStateScope.of(context);
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: () => state.setBottomNavIndex(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? MausamColors.primaryContainer.withValues(alpha: 0.18) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: isSelected ? MausamColors.primary : MausamColors.secondary, size: 22),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? MausamColors.primary : MausamColors.secondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// 6. LIVE HOME DASHBOARD WITH INTERACTIVE PERSONA CARDS & FILTERING
// ============================================================================

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);
    final w = state.weatherSummary;

    final baseTemp = w?.temperature ?? 28.0;
    final condition = w?.condition ?? 'Partly cloudy';
    final apparentTemp = w?.apparentTemperature ?? baseTemp;
    final humidity = w?.humidity ?? 76.0;
    final aqi = w?.aqi ?? 225.0;

    // Filter cards based on selected ribbon filter
    final allWidgets = [...state.primaryWidgets, ...state.secondaryWidgets];
    final filteredWidgets = state.selectedRibbonFilter == 'All Focus'
        ? state.primaryWidgets
        : allWidgets.where((c) {
            final filter = state.selectedRibbonFilter.toLowerCase();
            return c.category.toLowerCase().contains(filter) ||
                c.title.toLowerCase().contains(filter) ||
                c.widgetId.toLowerCase().contains(filter);
          }).toList();

    // Hourly forecast
    final hourlyList = List.generate(6, (i) {
      final hour = (DateTime.now().hour + i) % 24;
      final timeLabel = i == 0 ? 'Now' : '${hour % 12 == 0 ? 12 : hour % 12} ${hour >= 12 ? 'PM' : 'AM'}';
      final hourTemp = baseTemp + (i == 0 ? 0 : (i % 2 == 0 ? -1.5 : 1.0));
      return HourlyForecastItem(timeLabel, hourTemp, getWeatherIcon(condition));
    });

    // 5-day forecast
    final days = ['Today', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final dailyList = List.generate(5, (i) {
      final dayName = i == 0 ? 'Today' : days[(DateTime.now().weekday + i - 1) % 7];
      final low = baseTemp - 5.0 + (i * 0.5);
      final high = baseTemp + 4.0 - (i * 0.3);
      return DailyForecastItem(dayName, getWeatherIcon(condition), low, high);
    });

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          color: MausamColors.primary,
          onRefresh: () => state.fetchLiveFeed(),
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            children: [
              // Top Bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'New Delhi (Live Region)',
                          style: Theme.of(context).textTheme.headlineLarge?.copyWith(fontSize: 22),
                        ),
                        Text(
                          '$condition · Feels like ${state.formatTemp(apparentTemp)} · Humidity ${humidity.toInt()}%',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  InkWell(
                    onTap: () => state.fetchLiveFeed(),
                    child: CircleAvatar(
                      backgroundColor: MausamColors.surfaceContainerLowest,
                      child: state.isLoading
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.refresh, color: MausamColors.primary),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              if (state.errorMessage != null)
                Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: MausamColors.errorContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.warning_amber_rounded, color: MausamColors.errorRed, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          state.errorMessage!,
                          style: const TextStyle(color: MausamColors.errorRed, fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),

              // Live Hero Weather Card
              FrostedGlassCard(
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(builder: (_) => const WeatherDetailScreen()));
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          state.formatTemp(baseTemp),
                          style: Theme.of(context).textTheme.displayLarge,
                        ),
                        Text(
                          'Wind: ${state.formatSpeed(w?.windSpeed)} · AQI: ${aqi.toInt()}',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ],
                    ),
                    Icon(
                      getWeatherIcon(condition),
                      size: 68,
                      color: condition.toLowerCase().contains('rain')
                          ? MausamColors.fitnessBlue
                          : MausamColors.warningAmber,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Interactive Persona Filter Ribbon (Tappable & Filters Feed)
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _ribbonFilterChip(context, 'All Focus', state.selectedRibbonFilter == 'All Focus', () {
                      state.setRibbonFilter('All Focus');
                    }),
                    ...state.selectedPersonas.map((p) {
                      final isSelected = state.selectedRibbonFilter.toLowerCase() == p.title.toLowerCase();
                      return _ribbonFilterChip(
                        context,
                        p.title,
                        isSelected,
                        () {
                          state.setRibbonFilter(isSelected ? 'All Focus' : p.title);
                        },
                        icon: p.icon,
                        color: p.color,
                      );
                    }),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Dynamic Scored Hero Widgets from Backend
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    state.selectedRibbonFilter == 'All Focus'
                        ? 'TOP RANKED FOCUS (LIVE AI SCORING)'
                        : '${state.selectedRibbonFilter.toUpperCase()} INSIGHTS',
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                  if (state.selectedRibbonFilter != 'All Focus')
                    TextButton(
                      style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(50, 20)),
                      onPressed: () => state.setRibbonFilter('All Focus'),
                      child: const Text('Show All', style: TextStyle(fontSize: 11)),
                    ),
                ],
              ),
              const SizedBox(height: 12),

              if (filteredWidgets.isEmpty && state.isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24.0),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (filteredWidgets.isNotEmpty)
                ...filteredWidgets.map((card) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: FrostedGlassCard(
                      accentColor: card.color,
                      onTap: () {
                        _showPersonaDetailModal(context, card, state);
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 16,
                                backgroundColor: card.color.withValues(alpha: 0.15),
                                child: Icon(card.icon, color: card.color, size: 18),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  card.title,
                                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 15),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: card.color.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  card.badge.isNotEmpty ? card.badge : 'Rank #${card.rank}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: card.color,
                                  ),
                                ),
                              )
                            ],
                          ),
                          if (card.highlights.isNotEmpty) ...[
                            const SizedBox(height: 10),
                            Wrap(
                              spacing: 8,
                              runSpacing: 6,
                              children: card.highlights.entries.map((e) {
                                return Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: MausamColors.surfaceContainerHigh.withValues(alpha: 0.5),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    '${e.key}: ${e.value}',
                                    style: const TextStyle(fontSize: 11, color: MausamColors.onSurfaceStrong),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text('Tap for telemetry details', style: TextStyle(fontSize: 11, color: card.color, fontWeight: FontWeight.w600)),
                              const SizedBox(width: 4),
                              Icon(Icons.arrow_forward_ios, size: 10, color: card.color),
                            ],
                          )
                        ],
                      ),
                    ),
                  );
                })
              else
                FrostedGlassCard(
                  accentColor: MausamColors.healthTeal,
                  child: Row(
                    children: [
                      const Icon(Icons.sync, color: MausamColors.healthTeal),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'No cards for "${state.selectedRibbonFilter}". Tap "Show All" to view all active scoring cards.',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 16),

              // Hourly Forecast Carousel
              Text('HOURLY OUTLOOK (LIVE FORECAST)', style: Theme.of(context).textTheme.labelSmall),
              const SizedBox(height: 12),
              SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: hourlyList.length,
                  itemBuilder: (context, idx) {
                    final h = hourlyList[idx];
                    return Container(
                      width: 76,
                      margin: const EdgeInsets.only(right: 10),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: MausamColors.surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: MausamColors.surfaceVariant),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Text(h.time, style: Theme.of(context).textTheme.labelSmall),
                          Icon(h.icon, size: 20, color: MausamColors.primary),
                          Text(state.formatTemp(h.tempC), style: Theme.of(context).textTheme.labelLarge),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),

              // Multi-Day Outlook
              Text('MULTI-DAY OUTLOOK', style: Theme.of(context).textTheme.labelSmall),
              const SizedBox(height: 12),
              FrostedGlassCard(
                child: Column(
                  children: dailyList.map((d) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: [
                          SizedBox(width: 55, child: Text(d.day, style: Theme.of(context).textTheme.labelLarge)),
                          Icon(d.icon, size: 20, color: MausamColors.primary),
                          const Spacer(),
                          Text(state.formatTemp(d.lowC), style: Theme.of(context).textTheme.bodyMedium),
                          const SizedBox(width: 12),
                          Container(
                            width: 70,
                            height: 4,
                            decoration: BoxDecoration(
                              color: MausamColors.surfaceContainerHigh,
                              borderRadius: BorderRadius.circular(2),
                            ),
                            child: FractionallySizedBox(
                              alignment: Alignment.centerLeft,
                              widthFactor: 0.75,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: MausamColors.primary,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(state.formatTemp(d.highC), style: Theme.of(context).textTheme.labelLarge),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _ribbonFilterChip(BuildContext context, String title, bool isSelected, VoidCallback onTap, {IconData? icon, Color? color}) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: FilterChip(
        avatar: icon != null ? Icon(icon, size: 16, color: isSelected ? Colors.white : (color ?? MausamColors.primary)) : null,
        label: Text(title, style: TextStyle(fontSize: 12, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, color: isSelected ? Colors.white : MausamColors.primary)),
        selected: isSelected,
        selectedColor: MausamColors.primary,
        backgroundColor: MausamColors.surfaceContainerLowest,
        showCheckmark: false,
        shape: const StadiumBorder(),
        onSelected: (_) => onTap(),
      ),
    );
  }

  void _showPersonaDetailModal(BuildContext context, WidgetCardModel card, AppState state) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.7,
          decoration: const BoxDecoration(
            color: MausamColors.surface,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: MausamColors.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: card.color.withValues(alpha: 0.18),
                          child: Icon(card.icon, color: card.color, size: 22),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(card.title, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 18)),
                              Text('Scored Priority Rank #${card.rank}', style: const TextStyle(fontSize: 12, color: MausamColors.secondary)),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: card.color.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(card.badge, style: TextStyle(color: card.color, fontWeight: FontWeight.bold, fontSize: 12)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    Text('LIVE SCORING METRICS', style: Theme.of(context).textTheme.labelSmall),
                    const SizedBox(height: 12),

                    ...card.highlights.entries.map((e) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: FrostedGlassCard(
                          accentColor: card.color,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(e.key, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                              Flexible(
                                child: Text(
                                  '${e.value}',
                                  textAlign: TextAlign.end,
                                  style: TextStyle(color: card.color, fontWeight: FontWeight.bold, fontSize: 13),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),

                    const SizedBox(height: 16),
                    Text('CATEGORY INSIGHT', style: Theme.of(context).textTheme.labelSmall),
                    const SizedBox(height: 10),

                    FrostedGlassCard(
                      child: Text(
                        _getCategoryRecommendation(card.category, state),
                        style: const TextStyle(fontSize: 13, height: 1.4),
                      ),
                    ),

                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: PillButton(
                        label: 'Close Details',
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _getCategoryRecommendation(String category, AppState state) {
    final cat = category.toLowerCase();
    final temp = state.formatTemp(state.weatherSummary?.temperature);
    final aqi = state.weatherSummary?.aqi.toInt() ?? 225;
    final wind = state.formatSpeed(state.weatherSummary?.windSpeed);

    if (cat.contains('agri') || cat.contains('garden')) {
      return 'Farming Telemetry: Wind conditions ($wind) are within safe drift limits for spraying. Soil temperature is optimal around $temp. Ensure regular watering in non-rain windows.';
    }
    if (cat.contains('health')) {
      return 'Health Advisory: Current AQI is $aqi. Particulates (PM2.5 & PM10) are active in the region. Sensitive individuals should wear protective masks outdoors and monitor respiratory comfort.';
    }
    if (cat.contains('fitness') || cat.contains('run')) {
      return 'Fitness Window: Ambient temperature is $temp. Cardio is favorable before peak heat. If AQI exceeds your threshold ($aqi), consider indoor cross-training.';
    }
    if (cat.contains('beach') || cat.contains('surf')) {
      return 'Coastal Context: Coastal temperature is $temp with gentle breezes ($wind). Swell and tide conditions remain favorable for watersports.';
    }
    if (cat.contains('commut')) {
      return 'Transit Alert: Clear road visibility with zero rain probability currently. Smooth driving and transit conditions across main arterials.';
    }
    if (cat.contains('family')) {
      return 'Family Routine: Playground weather is comfortable at $temp with low UV index. Safe for strollers and park visits.';
    }
    return 'Conditions are actively calibrated by your scoring weights and Open-Meteo telemetry.';
  }
}

// ============================================================================
// 7. IN-DEPTH DETAIL VIEWS (Weather Detail & AQI)
// ============================================================================

class WeatherDetailScreen extends StatelessWidget {
  const WeatherDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);
    final w = state.weatherSummary;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: MausamColors.primary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Live Atmospheric Metrics', style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: MausamColors.primary)),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text('Open-Meteo & IMD Telemetry', style: Theme.of(context).textTheme.headlineLarge),
            Text('Real-time ambient context from backend', style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 20),

            // Bento Grid for Metrics
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              childAspectRatio: 1.2,
              children: [
                _MetricCard(
                  title: 'WIND SPEED',
                  value: state.formatSpeed(w?.windSpeed),
                  subtitle: 'Live Open-Meteo Speed',
                  icon: Icons.air,
                ),
                _MetricCard(
                  title: 'HUMIDITY',
                  value: '${(w?.humidity ?? 0).toInt()}%',
                  subtitle: (w?.humidity ?? 0) > 70 ? 'High Moisture' : 'Comfortable',
                  icon: Icons.water_drop,
                ),
                _MetricCard(
                  title: 'UV INDEX',
                  value: '${w?.uvIndex.toStringAsFixed(1) ?? 0.0}',
                  subtitle: (w?.uvIndex ?? 0) > 5 ? 'Sunscreen Advised' : 'Low Exposure',
                  icon: Icons.wb_sunny,
                ),
                _MetricCard(
                  title: 'RAIN CHANCE',
                  value: '${(w?.rainProbability ?? 0).toInt()}%',
                  subtitle: (w?.rainProbability ?? 0) > 40 ? 'Carry Umbrella' : 'Minimal Precipitation',
                  icon: Icons.umbrella,
                ),
                _MetricCard(
                  title: 'FEELS LIKE',
                  value: state.formatTemp(w?.apparentTemperature),
                  subtitle: 'Apparent Temperature',
                  icon: Icons.thermostat,
                ),
                _MetricCard(
                  title: 'AIR QUALITY',
                  value: 'AQI ${(w?.aqi ?? 0).toInt()}',
                  subtitle: (w?.aqi ?? 0) > 150 ? 'Unhealthy' : 'Moderate/Good',
                  icon: Icons.speed,
                ),
              ],
            ),
            const SizedBox(height: 24),

            FrostedGlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('LIVE CLIMATE ZONE & RADAR CONTEXT', style: Theme.of(context).textTheme.labelSmall),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          const Icon(Icons.public, color: MausamColors.primary),
                          const SizedBox(height: 4),
                          Text('Zone: ${w?.climateZone.toUpperCase() ?? 'TROPICAL'}', style: Theme.of(context).textTheme.bodyMedium),
                        ],
                      ),
                      Column(
                        children: [
                          const Icon(Icons.tsunami, color: MausamColors.beachAqua),
                          const SizedBox(height: 4),
                          Text('Wave: ${w?.waveHeight ?? 1.2} m', style: Theme.of(context).textTheme.bodyMedium),
                        ],
                      ),
                    ],
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;

  const _MetricCard({required this.title, required this.value, required this.subtitle, required this.icon});

  @override
  Widget build(BuildContext context) {
    return FrostedGlassCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: Theme.of(context).textTheme.labelSmall),
              Icon(icon, size: 18, color: MausamColors.primary),
            ],
          ),
          Text(value, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 20)),
          Text(subtitle, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 11)),
        ],
      ),
    );
  }
}

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

// ============================================================================
// 8. EXPLORE, AI CHAT, ALERTS & PROFILE
// ============================================================================

class ExploreScreen extends StatelessWidget {
  const ExploreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text('Explore & Radar', style: Theme.of(context).textTheme.headlineLarge),
            Text('Interactive atmospheric maps and secondary persona feeds.', style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 18),

            // Radar Map Box
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: MausamColors.primaryContainer,
                borderRadius: BorderRadius.circular(20),
                image: const DecorationImage(
                  image: NetworkImage('https://images.unsplash.com/photo-1524661135-423995f22d0b?auto=format&fit=crop&w=800&q=80'),
                  fit: BoxFit.cover,
                  opacity: 0.6,
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.radar, color: Colors.greenAccent, size: 14),
                          SizedBox(width: 6),
                          Text('LIVE DOPPLER RADAR ACTIVE', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text('MORE PERSONALIZED FOCUSES (FROM API)', style: Theme.of(context).textTheme.labelSmall),
            const SizedBox(height: 12),

            if (state.secondaryWidgets.isNotEmpty)
              ...state.secondaryWidgets.map((c) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: FrostedGlassCard(
                    accentColor: c.color,
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(
                        backgroundColor: c.color.withValues(alpha: 0.15),
                        child: Icon(c.icon, color: c.color, size: 18),
                      ),
                      title: Text(c.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      subtitle: Text(c.badge, style: const TextStyle(fontSize: 12)),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                      onTap: () {},
                    ),
                  ),
                );
              })
            else
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Text('Secondary scored feeds sync from FastAPI server.'),
                ),
              )
          ],
        ),
      ),
    );
  }
}

class MausamAIScreen extends StatefulWidget {
  const MausamAIScreen({super.key});

  @override
  State<MausamAIScreen> createState() => _MausamAIScreenState();
}

class _MausamAIScreenState extends State<MausamAIScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<ChatMessageModel> _messages = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_messages.isEmpty) {
      final state = AppStateScope.of(context);
      final temp = state.formatTemp(state.weatherSummary?.temperature);
      final cond = state.weatherSummary?.condition ?? 'Partly cloudy';
      final aqi = (state.weatherSummary?.aqi ?? 225).toInt();

      _messages.addAll([
        ChatMessageModel(
          sender: 'ai',
          text: 'Hello! I\'m Mausam AI, powered by your live backend telemetry. Current live conditions: $temp, $cond, AQI $aqi. How can I assist your outdoor planning?',
        ),
        ChatMessageModel(
          sender: 'user',
          text: 'Can I go for my workout now?',
        ),
        ChatMessageModel(
          sender: 'ai',
          text: 'Currently, the temperature is $temp and $cond with an AQI of $aqi. For outdoor cardio, check if air quality requires indoor training.',
          cardTitle: aqi > 150 ? 'Run Index: Indoor Recommended' : 'Run Index: Optimal',
          cardSubtitle: 'Based on live Open-Meteo & IMD models',
        ),
      ]);
    }
  }

  void _sendMessage(String query) {
    if (query.trim().isEmpty) return;
    final state = AppStateScope.of(context);
    final temp = state.formatTemp(state.weatherSummary?.temperature);
    final cond = state.weatherSummary?.condition ?? 'Partly cloudy';

    setState(() {
      _messages.add(ChatMessageModel(sender: 'user', text: query));
      _controller.clear();
      _messages.add(ChatMessageModel(
        sender: 'ai',
        text: 'Analyzing live atmospheric context for "$query"... Live temperature is $temp with $cond skies and ${state.weatherSummary?.humidity.toInt() ?? 76}% humidity.',
      ));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Ask Mausam AI', style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: MausamColors.primary)),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final msg = _messages[index];
                  final isUser = msg.sender == 'user';

                  return Align(
                    alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isUser ? MausamColors.primary : MausamColors.surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(16),
                        border: isUser ? null : Border.all(color: MausamColors.surfaceVariant),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            msg.text,
                            style: TextStyle(
                              color: isUser ? Colors.white : MausamColors.onSurfaceStrong,
                              fontSize: 14,
                            ),
                          ),
                          if (msg.cardTitle != null) ...[
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: MausamColors.surfaceContainerHigh,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.check_circle, size: 16, color: MausamColors.fitnessBlue),
                                  const SizedBox(width: 8),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(msg.cardTitle!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                      Text(msg.cardSubtitle!, style: const TextStyle(fontSize: 10, color: MausamColors.secondary)),
                                    ],
                                  )
                                ],
                              ),
                            )
                          ]
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // Prompt Suggestions
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                children: [
                  _suggestionChip('Should I carry an umbrella?'),
                  _suggestionChip('Is today good for running?'),
                  _suggestionChip('What are current PM2.5 levels?'),
                ],
              ),
            ),

            // Input Bar
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: 'Ask Mausam...',
                        filled: true,
                        fillColor: MausamColors.surfaceContainerLowest,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onSubmitted: _sendMessage,
                    ),
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    backgroundColor: MausamColors.primary,
                    child: IconButton(
                      icon: const Icon(Icons.send, color: Colors.white, size: 18),
                      onPressed: () => _sendMessage(_controller.text),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _suggestionChip(String text) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ActionChip(
        label: Text(text, style: const TextStyle(fontSize: 11, color: MausamColors.primary)),
        backgroundColor: MausamColors.surfaceContainerLowest,
        shape: const StadiumBorder(),
        onPressed: () => _sendMessage(text),
      ),
    );
  }
}

class AlertsScreen extends StatelessWidget {
  const AlertsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);
    final aqi = state.weatherSummary?.aqi ?? 225.0;
    final rainProb = state.weatherSummary?.rainProbability ?? 0.0;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text('Active Weather Alerts', style: Theme.of(context).textTheme.headlineLarge),
            Text('Automated warnings generated from live telemetry.', style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 20),

            if (aqi > 150)
              FrostedGlassCard(
                accentColor: MausamColors.errorRed,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: MausamColors.errorRed.withValues(alpha: 0.15),
                          child: const Icon(Icons.air, color: MausamColors.errorRed, size: 18),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text('Elevated AQI Advisory (${aqi.toInt()})', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 15)),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: MausamColors.errorRed.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text('POOR AIR', style: TextStyle(color: MausamColors.errorRed, fontSize: 10, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Text('Particulate levels (PM2.5 & PM10) are elevated. Sensitive individuals should limit prolonged outdoor exertion.', style: TextStyle(fontSize: 13)),
                    const SizedBox(height: 8),
                    const Text('Active live notice from Open-Meteo', style: TextStyle(fontSize: 11, color: MausamColors.secondary)),
                  ],
                ),
              ),

            const SizedBox(height: 14),

            FrostedGlassCard(
              accentColor: rainProb > 30 ? MausamColors.fitnessBlue : MausamColors.tertiary,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: (rainProb > 30 ? MausamColors.fitnessBlue : MausamColors.tertiary).withValues(alpha: 0.15),
                        child: Icon(rainProb > 30 ? Icons.umbrella : Icons.check_circle_outline, color: rainProb > 30 ? MausamColors.fitnessBlue : MausamColors.tertiary, size: 18),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          rainProb > 30 ? 'Rain Probability: ${rainProb.toInt()}%' : 'Precipitation Clear (0% Rain)',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 15),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: (rainProb > 30 ? MausamColors.fitnessBlue : MausamColors.tertiary).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(rainProb > 30 ? 'RAIN WATCH' : 'OPTIMAL', style: TextStyle(color: rainProb > 30 ? MausamColors.fitnessBlue : MausamColors.tertiary, fontSize: 10, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    rainProb > 30
                        ? 'Scattered showers possible during commuting windows.'
                        : 'No precipitation forecasted for current outdoor windows.',
                    style: const TextStyle(fontSize: 13),
                  ),
                  const SizedBox(height: 8),
                  const Text('Live Sensor Context Active', style: TextStyle(fontSize: 11, color: MausamColors.secondary)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

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

// ============================================================================
// 9. APP ROOT
// ============================================================================

class MausamApp extends StatefulWidget {
  const MausamApp({super.key});

  @override
  State<MausamApp> createState() => _MausamAppState();
}

class _MausamAppState extends State<MausamApp> {
  final AppState _appState = AppState();

  @override
  Widget build(BuildContext context) {
    return AppStateScope(
      notifier: _appState,
      child: MaterialApp(
        title: 'Mausam - Personalized Weather',
        debugShowCheckedModeBanner: false,
        theme: MausamTheme.lightTheme,
        home: const SplashScreen(),
      ),
    );
  }
}
