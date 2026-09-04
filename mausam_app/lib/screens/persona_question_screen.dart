import 'package:flutter/material.dart';
import '../models/app_models.dart';
import '../core/app_theme.dart';
import '../services/app_state.dart';
import '../widgets/frosted_glass_card.dart';
import '../widgets/pill_button.dart';


import 'relevance_sliders_screen.dart';

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