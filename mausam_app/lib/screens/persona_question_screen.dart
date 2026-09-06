import '../models/app_models.dart';
import '../widgets/frosted_glass_card.dart';
import 'package:flutter/material.dart';
import '../core/app_theme.dart';
import '../services/app_state.dart';
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
          'Focus $stepNum of $total',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(fontSize: 13, color: MausamColors.primary),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Persona Header Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: FrostedGlassCard(
                accentColor: persona.color,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: persona.color.withValues(alpha: 0.18),
                      child: Icon(persona.icon, color: persona.color, size: 24),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${persona.title} Calibration',
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 18),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            persona.description,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: persona.color.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'STEP $stepNum/$total',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: persona.color),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Question List for this specific persona - Spacious & Expansive
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
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
        final selectedActs = List<String>.from(state.probingAnswers['fitness_activities'] ?? <String>[]);
        final startTime = state.probingAnswers['fitness_start_time'] ?? '06:00 AM';
        final endTime = state.probingAnswers['fitness_end_time'] ?? '07:30 AM';
        final loc = state.probingAnswers['fitness_location'] ?? 'Park or trail';

        return [
          _buildQuestionCard(
            title: 'Q1. What fitness activities do you do?',
            isMulti: true,
            personaColor: persona.color,
            child: _buildVisualOptionGrid(
              options: [
                _OptionItem('Running', Icons.directions_run, 'Cardio & pace tracking'),
                _OptionItem('Cycling', Icons.directions_bike, 'Road & trail rides'),
                _OptionItem('Walking', Icons.nordic_walking, 'Brisk walks & daily steps'),
                _OptionItem('Outdoor Workout', Icons.fitness_center, 'Calisthenics & bootcamps'),
                _OptionItem('Field Sports', Icons.sports_soccer, 'Football, cricket, tennis'),
              ],
              selectedList: selectedActs,
              color: persona.color,
              onToggle: (opt) => state.toggleMultiSelection('fitness_activities', opt),
            ),
          ),
          const SizedBox(height: 16),
          _buildQuestionCard(
            title: 'Q2. Outdoor Workout Time Window',
            personaColor: persona.color,
            child: _buildTimeHorizonCard(
              personaColor: persona.color,
              startValue: startTime,
              endValue: endTime,
              onStartChanged: (v) => state.updateProbingAnswer('fitness_start_time', v),
              onEndChanged: (v) => state.updateProbingAnswer('fitness_end_time', v),
            ),
          ),
          const SizedBox(height: 16),
          _buildQuestionCard(
            title: 'Q3. Preferred Training Location',
            personaColor: persona.color,
            child: _buildSingleSelectTiles(
              options: [
                _OptionItem('Current Location', Icons.my_location, 'Local neighborhood route'),
                _OptionItem('Park or Trail', Icons.park, 'Clean air & shade trees'),
                _OptionItem('Road / Pavement', Icons.add_road, 'Paved running track'),
                _OptionItem('Sports Complex', Icons.stadium, 'Open ground or arena'),
              ],
              selected: loc,
              color: persona.color,
              onSelect: (opt) => state.updateProbingAnswer('fitness_location', opt),
            ),
          ),
          const SizedBox(height: 16),
        ];

      // 2. Health
      case PersonaType.health:
        final selectedPlans = List<String>.from(state.probingAnswers['health_plans'] ?? <String>[]);
        final startTime = state.probingAnswers['health_start_time'] ?? '07:00 AM';
        final endTime = state.probingAnswers['health_end_time'] ?? '09:00 AM';
        final loc = state.probingAnswers['health_location'] ?? 'Current location';

        return [
          _buildQuestionCard(
            title: 'Q1. What health factors matter most?',
            isMulti: true,
            personaColor: persona.color,
            child: _buildVisualOptionGrid(
              options: [
                _OptionItem('Air Quality (AQI)', Icons.air, 'PM2.5 & particulate alerts'),
                _OptionItem('Pollen & Allergens', Icons.grass, 'Seasonal allergy monitoring'),
                _OptionItem('UV Protection', Icons.wb_sunny, 'Sunburn & peak UV alerts'),
                _OptionItem('Heat & Humidity', Icons.thermostat, 'Heat exhaustion prevention'),
                _OptionItem('Cardio Readiness', Icons.favorite, 'Safe respiration windows'),
              ],
              selectedList: selectedPlans,
              color: persona.color,
              onToggle: (opt) => state.toggleMultiSelection('health_plans', opt),
            ),
          ),
          const SizedBox(height: 16),
          _buildQuestionCard(
            title: 'Q2. Outdoor Exposure Window',
            personaColor: persona.color,
            child: _buildTimeHorizonCard(
              personaColor: persona.color,
              startValue: startTime,
              endValue: endTime,
              onStartChanged: (v) => state.updateProbingAnswer('health_start_time', v),
              onEndChanged: (v) => state.updateProbingAnswer('health_end_time', v),
            ),
          ),
          const SizedBox(height: 16),
          _buildQuestionCard(
            title: 'Q3. Primary Environmental Setting',
            personaColor: persona.color,
            child: _buildSingleSelectTiles(
              options: [
                _OptionItem('Current Location', Icons.home, 'Home / local area'),
                _OptionItem('Urban / City Center', Icons.location_city, 'Traffic & smog density'),
                _OptionItem('Green Zone / Forest', Icons.forest, 'Natural pollen buffer'),
              ],
              selected: loc,
              color: persona.color,
              onSelect: (opt) => state.updateProbingAnswer('health_location', opt),
            ),
          ),
          const SizedBox(height: 16),
        ];

      // 3. Beach / Surf
      case PersonaType.beach:
        final selectedPlans = List<String>.from(state.probingAnswers['beach_plans'] ?? <String>[]);
        final startTime = state.probingAnswers['beach_start_time'] ?? '02:00 PM';
        final endTime = state.probingAnswers['beach_end_time'] ?? '05:00 PM';
        final loc = state.probingAnswers['beach_location'] ?? 'Local coast';

        return [
          _buildQuestionCard(
            title: 'Q1. Beach & Coastal Activities',
            isMulti: true,
            personaColor: persona.color,
            child: _buildVisualOptionGrid(
              options: [
                _OptionItem('Surfing', Icons.surfing, 'Wave swell & tide heights'),
                _OptionItem('Swimming', Icons.pool, 'Water temperature & rip currents'),
                _OptionItem('Sailing / Boating', Icons.sailing, 'Wind speed & maritime safety'),
                _OptionItem('Beach Relaxing', Icons.beach_access, 'UV index & breeze comfort'),
              ],
              selectedList: selectedPlans,
              color: persona.color,
              onToggle: (opt) => state.toggleMultiSelection('beach_plans', opt),
            ),
          ),
          const SizedBox(height: 16),
          _buildQuestionCard(
            title: 'Q2. Coastal Activity Window',
            personaColor: persona.color,
            child: _buildTimeHorizonCard(
              personaColor: persona.color,
              startValue: startTime,
              endValue: endTime,
              onStartChanged: (v) => state.updateProbingAnswer('beach_start_time', v),
              onEndChanged: (v) => state.updateProbingAnswer('beach_end_time', v),
            ),
          ),
          const SizedBox(height: 16),
          _buildQuestionCard(
            title: 'Q3. Target Coastal Region',
            personaColor: persona.color,
            child: _buildSingleSelectTiles(
              options: [
                _OptionItem('Local Coast', Icons.waves, 'Nearby beach & shoreline'),
                _OptionItem('Goa Coastline', Icons.explore, 'Western swell & tidal zone'),
                _OptionItem('Bay of Bengal Coast', Icons.anchor, 'Eastern marine basin'),
              ],
              selected: loc,
              color: persona.color,
              onSelect: (opt) => state.updateProbingAnswer('beach_location', opt),
            ),
          ),
          const SizedBox(height: 16),
        ];

      // 4. Travel
      case PersonaType.travel:
        final dest = state.probingAnswers['travel_destination'] ?? 'Mumbai, India';
        final dep = state.probingAnswers['travel_departure'] ?? '08:00 AM';
        final arr = state.probingAnswers['travel_arrival'] ?? '11:30 AM';
        final selectedModes = List<String>.from(state.probingAnswers['travel_modes'] ?? <String>[]);

        return [
          _buildQuestionCard(
            title: 'Q1. Travel Destination',
            personaColor: persona.color,
            child: _buildSingleSelectTiles(
              options: [
                _OptionItem('Mumbai, India', Icons.flight_land, 'Coastal commercial hub'),
                _OptionItem('Bengaluru, India', Icons.location_city, 'Southern plateau zone'),
                _OptionItem('Hill Station', Icons.landscape, 'Cool climate / mountain weather'),
                _OptionItem('Local Intercity', Icons.near_me, 'Regional short travel'),
              ],
              selected: dest,
              color: persona.color,
              onSelect: (opt) => state.updateProbingAnswer('travel_destination', opt),
            ),
          ),
          const SizedBox(height: 16),
          _buildQuestionCard(
            title: 'Q2. Travel Schedule Window',
            personaColor: persona.color,
            child: _buildTimeHorizonCard(
              personaColor: persona.color,
              startLabel: 'Departure',
              endLabel: 'Arrival',
              startValue: dep,
              endValue: arr,
              onStartChanged: (v) => state.updateProbingAnswer('travel_departure', v),
              onEndChanged: (v) => state.updateProbingAnswer('travel_arrival', v),
            ),
          ),
          const SizedBox(height: 16),
          _buildQuestionCard(
            title: 'Q3. Transportation Mode',
            isMulti: true,
            personaColor: persona.color,
            child: _buildVisualOptionGrid(
              options: [
                _OptionItem('Flight', Icons.flight, 'Turbulence & gate delays'),
                _OptionItem('Road / Car', Icons.directions_car, 'Highway visibility & rain spray'),
                _OptionItem('Train', Icons.train, 'Rail network & fog alerts'),
              ],
              selectedList: selectedModes,
              color: persona.color,
              onToggle: (opt) => state.toggleMultiSelection('travel_modes', opt),
            ),
          ),
          const SizedBox(height: 16),
        ];

      // 5. Family
      case PersonaType.family:
        final selectedPlans = List<String>.from(state.probingAnswers['family_plans'] ?? <String>[]);
        final startTime = state.probingAnswers['family_start_time'] ?? '04:30 PM';
        final endTime = state.probingAnswers['family_end_time'] ?? '06:30 PM';
        final loc = state.probingAnswers['family_location'] ?? 'Park or playground';

        return [
          _buildQuestionCard(
            title: 'Q1. Family Outing Activities',
            isMulti: true,
            personaColor: persona.color,
            child: _buildVisualOptionGrid(
              options: [
                _OptionItem('Outdoor Play', Icons.sports_baseball, 'Playground & park comfort'),
                _OptionItem('Stroller Walk', Icons.stroller, 'Shade & smooth sidewalk conditions'),
                _OptionItem('Family Picnic', Icons.deck, 'Dry lawn & mild winds'),
                _OptionItem('School Transit', Icons.school, 'Rainproof morning commute'),
              ],
              selectedList: selectedPlans,
              color: persona.color,
              onToggle: (opt) => state.toggleMultiSelection('family_plans', opt),
            ),
          ),
          const SizedBox(height: 16),
          _buildQuestionCard(
            title: 'Q2. Outing Time Window',
            personaColor: persona.color,
            child: _buildTimeHorizonCard(
              personaColor: persona.color,
              startValue: startTime,
              endValue: endTime,
              onStartChanged: (v) => state.updateProbingAnswer('family_start_time', v),
              onEndChanged: (v) => state.updateProbingAnswer('family_end_time', v),
            ),
          ),
          const SizedBox(height: 16),
          _buildQuestionCard(
            title: 'Q3. Location Setting',
            personaColor: persona.color,
            child: _buildSingleSelectTiles(
              options: [
                _OptionItem('Park or Playground', Icons.park, 'Public green spaces'),
                _OptionItem('Neighborhood Area', Icons.holiday_village, 'Walking distance from home'),
                _OptionItem('Amusement / Theme Park', Icons.attractions, 'Full day outdoor setting'),
              ],
              selected: loc,
              color: persona.color,
              onSelect: (opt) => state.updateProbingAnswer('family_location', opt),
            ),
          ),
          const SizedBox(height: 16),
        ];

      // 6. Agriculture
      case PersonaType.agriculture:
        final selectedPlans = List<String>.from(state.probingAnswers['agri_plans'] ?? <String>[]);
        final crop = state.probingAnswers['agri_crop'] ?? 'Vegetables';
        final stage = state.probingAnswers['agri_stage'] ?? 'Growing';
        final loc = state.probingAnswers['agri_location'] ?? 'Local farm / field';

        return [
          _buildQuestionCard(
            title: 'Q1. Farm / Gardening Operations',
            isMulti: true,
            personaColor: persona.color,
            child: _buildVisualOptionGrid(
              options: [
                _OptionItem('Irrigation', Icons.water, 'Soil moisture & rain windows'),
                _OptionItem('Pesticide Spray', Icons.sanitizer, 'Wind drift & humidity control'),
                _OptionItem('Harvesting', Icons.agriculture, 'Dry crop pickup window'),
                _OptionItem('Sowing / Planting', Icons.eco, 'Soil temperature & frost check'),
              ],
              selectedList: selectedPlans,
              color: persona.color,
              onToggle: (opt) => state.toggleMultiSelection('agri_plans', opt),
            ),
          ),
          const SizedBox(height: 16),
          _buildQuestionCard(
            title: 'Q2. Crop Type & Growth Stage',
            personaColor: persona.color,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Target Crop:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: ['Vegetables', 'Wheat / Grains', 'Cotton / Cash', 'Fruit Orchards', 'Home Garden'].map((c) {
                    final isSel = crop == c;
                    return ChoiceChip(
                      label: Text(c, style: TextStyle(fontSize: 12, fontWeight: isSel ? FontWeight.bold : FontWeight.normal, color: isSel ? Colors.white : MausamColors.tertiary)),
                      selected: isSel,
                      selectedColor: MausamColors.tertiary,
                      backgroundColor: MausamColors.surfaceContainerLowest,
                      onSelected: (val) {
                        if (val) state.updateProbingAnswer('agri_crop', c);
                      },
                    );
                  }).toList(),
                ),
                const Divider(height: 24),
                const Text('Current Growth Stage:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: ['Preparing Field', 'Germination', 'Growing Vegetative', 'Flowering', 'Harvesting'].map((s) {
                    final isSel = stage == s;
                    return ChoiceChip(
                      label: Text(s, style: TextStyle(fontSize: 12, fontWeight: isSel ? FontWeight.bold : FontWeight.normal, color: isSel ? Colors.white : MausamColors.primary)),
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
          const SizedBox(height: 16),
          _buildQuestionCard(
            title: 'Q3. Farming Location',
            personaColor: persona.color,
            child: _buildSingleSelectTiles(
              options: [
                _OptionItem('Local Farm / Field', Icons.landscape, 'Open rural agricultural zone'),
                _OptionItem('Greenhouse / Polyhouse', Icons.fence, 'Protected microclimate setup'),
                _OptionItem('Home Garden / Terrace', Icons.yard, 'Rooftop or backyard patch'),
              ],
              selected: loc,
              color: persona.color,
              onSelect: (opt) => state.updateProbingAnswer('agri_location', opt),
            ),
          ),
          const SizedBox(height: 16),
        ];

      // 7. Commute
      case PersonaType.commute:
        final dest = state.probingAnswers['commute_destination'] ?? 'Office / Work';
        final startTime = state.probingAnswers['commute_start_time'] ?? '08:30 AM';
        final endTime = state.probingAnswers['commute_end_time'] ?? '09:30 AM';
        final selectedModes = List<String>.from(state.probingAnswers['commute_modes'] ?? <String>[]);

        return [
          _buildQuestionCard(
            title: 'Q1. Commute Destination',
            personaColor: persona.color,
            child: _buildSingleSelectTiles(
              options: [
                _OptionItem('Office / Workplace', Icons.business, 'Daily work rush route'),
                _OptionItem('College / University', Icons.school, 'Campus transit timing'),
                _OptionItem('Field / Client Visits', Icons.travel_explore, 'City-wide mobile travel'),
              ],
              selected: dest,
              color: persona.color,
              onSelect: (opt) => state.updateProbingAnswer('commute_destination', opt),
            ),
          ),
          const SizedBox(height: 16),
          _buildQuestionCard(
            title: 'Q2. Peak Transit Hours',
            personaColor: persona.color,
            child: _buildTimeHorizonCard(
              personaColor: persona.color,
              startValue: startTime,
              endValue: endTime,
              onStartChanged: (v) => state.updateProbingAnswer('commute_start_time', v),
              onEndChanged: (v) => state.updateProbingAnswer('commute_end_time', v),
            ),
          ),
          const SizedBox(height: 16),
          _buildQuestionCard(
            title: 'Q3. Transportation Mode',
            isMulti: true,
            personaColor: persona.color,
            child: _buildVisualOptionGrid(
              options: [
                _OptionItem('Motorbike / Scooter', Icons.two_wheeler, 'Rain gear & road grip alerts'),
                _OptionItem('Car / Taxi', Icons.directions_car, 'Traffic & visibility conditions'),
                _OptionItem('Metro / Train', Icons.subway, 'Station walking & platform rain'),
                _OptionItem('Bicycle / Walking', Icons.directions_walk, 'Direct weather exposure'),
              ],
              selectedList: selectedModes,
              color: persona.color,
              onToggle: (opt) => state.toggleMultiSelection('commute_modes', opt),
            ),
          ),
          const SizedBox(height: 16),
        ];

      // 8. Event
      case PersonaType.event:
        final selectedPlans = List<String>.from(state.probingAnswers['event_plans'] ?? <String>[]);
        final startTime = state.probingAnswers['event_start_time'] ?? '06:00 PM';
        final endTime = state.probingAnswers['event_end_time'] ?? '10:00 PM';
        final loc = state.probingAnswers['event_location'] ?? 'Open lawn / Garden';

        return [
          _buildQuestionCard(
            title: 'Q1. Event Type & Gatherings',
            isMulti: true,
            personaColor: persona.color,
            child: _buildVisualOptionGrid(
              options: [
                _OptionItem('Wedding / Reception', Icons.celebration, 'Evening breeze & rain certainty'),
                _OptionItem('Garden Party / BBQ', Icons.outdoor_grill, 'Comfortable outdoor dining index'),
                _OptionItem('Concert / Festival', Icons.music_note, 'Open-air crowd conditions'),
                _OptionItem('Sports Tournament', Icons.emoji_events, 'Field playability & heat check'),
              ],
              selectedList: selectedPlans,
              color: persona.color,
              onToggle: (opt) => state.toggleMultiSelection('event_plans', opt),
            ),
          ),
          const SizedBox(height: 16),
          _buildQuestionCard(
            title: 'Q2. Event Time Horizon',
            personaColor: persona.color,
            child: _buildTimeHorizonCard(
              personaColor: persona.color,
              startValue: startTime,
              endValue: endTime,
              onStartChanged: (v) => state.updateProbingAnswer('event_start_time', v),
              onEndChanged: (v) => state.updateProbingAnswer('event_end_time', v),
            ),
          ),
          const SizedBox(height: 16),
          _buildQuestionCard(
            title: 'Q3. Event Venue Type',
            personaColor: persona.color,
            child: _buildSingleSelectTiles(
              options: [
                _OptionItem('Open Lawn / Garden', Icons.grass, 'Fully exposed to sky'),
                _OptionItem('Canopy / Marquee', Icons.roofing, 'Semi-covered outdoor space'),
                _OptionItem('Resort / Poolside', Icons.pool, 'Waterfront gathering'),
              ],
              selected: loc,
              color: persona.color,
              onSelect: (opt) => state.updateProbingAnswer('event_location', opt),
            ),
          ),
          const SizedBox(height: 16),
        ];
    }
  }

  Widget _buildQuestionCard({
    required String title,
    bool isMulti = false,
    required Color personaColor,
    required Widget child,
  }) {
    return FrostedGlassCard(
      accentColor: personaColor,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: MausamColors.onSurfaceStrong),
                ),
              ),
              if (isMulti)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: personaColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'MULTI-SELECT',
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: personaColor),
                  ),
                )
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

  Widget _buildVisualOptionGrid({
    required List<_OptionItem> options,
    required List<String> selectedList,
    required Color color,
    required Function(String) onToggle,
  }) {
    return Column(
      children: options.map((opt) {
        final isSel = selectedList.contains(opt.title);
        return Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => onToggle(opt.title),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: isSel ? color.withValues(alpha: 0.15) : MausamColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSel ? color : MausamColors.outlineVariant.withValues(alpha: 0.5),
                  width: isSel ? 2 : 1,
                ),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: isSel ? color : MausamColors.surfaceContainerHigh,
                    child: Icon(opt.icon, size: 18, color: isSel ? Colors.white : MausamColors.primary),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          opt.title,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: isSel ? FontWeight.bold : FontWeight.w600,
                            color: isSel ? color : MausamColors.onSurfaceStrong,
                          ),
                        ),
                        if (opt.subtitle.isNotEmpty)
                          Text(
                            opt.subtitle,
                            style: const TextStyle(fontSize: 11, color: MausamColors.secondary),
                          ),
                      ],
                    ),
                  ),
                  Icon(
                    isSel ? Icons.check_circle : Icons.radio_button_unchecked,
                    color: isSel ? color : MausamColors.outlineVariant,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSingleSelectTiles({
    required List<_OptionItem> options,
    required String selected,
    required Color color,
    required Function(String) onSelect,
  }) {
    return Column(
      children: options.map((opt) {
        final isSel = selected == opt.title;
        return Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => onSelect(opt.title),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: isSel ? color.withValues(alpha: 0.15) : MausamColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSel ? color : MausamColors.outlineVariant.withValues(alpha: 0.5),
                  width: isSel ? 2 : 1,
                ),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: isSel ? color : MausamColors.surfaceContainerHigh,
                    child: Icon(opt.icon, size: 18, color: isSel ? Colors.white : MausamColors.primary),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          opt.title,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: isSel ? FontWeight.bold : FontWeight.w600,
                            color: isSel ? color : MausamColors.onSurfaceStrong,
                          ),
                        ),
                        if (opt.subtitle.isNotEmpty)
                          Text(
                            opt.subtitle,
                            style: const TextStyle(fontSize: 11, color: MausamColors.secondary),
                          ),
                      ],
                    ),
                  ),
                  Icon(
                    isSel ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                    color: isSel ? color : MausamColors.outlineVariant,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTimeHorizonCard({
    required Color personaColor,
    String startLabel = 'Start Time',
    String endLabel = 'End Time',
    required String startValue,
    required String endValue,
    required Function(String) onStartChanged,
    required Function(String) onEndChanged,
  }) {
    final times = [
      '05:00 AM', '06:00 AM', '06:30 AM', '07:00 AM', '07:30 AM', '08:00 AM', '08:30 AM',
      '09:00 AM', '10:00 AM', '11:30 AM', '01:00 PM', '02:00 PM', '04:30 PM', '06:00 PM', '08:00 PM', '10:00 PM'
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Quick Presets
        const Text('Quick Time Horizon Presets:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: MausamColors.secondary)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _timePresetChip('Morning (6ΓÇô9 AM)', '06:00 AM', '09:00 AM', startValue, endValue, onStartChanged, onEndChanged, personaColor),
            _timePresetChip('Midday (11 AMΓÇô2 PM)', '11:30 AM', '02:00 PM', startValue, endValue, onStartChanged, onEndChanged, personaColor),
            _timePresetChip('Evening (5ΓÇô8 PM)', '04:30 PM', '08:00 PM', startValue, endValue, onStartChanged, onEndChanged, personaColor),
            _timePresetChip('Night (8ΓÇô11 PM)', '08:00 PM', '10:00 PM', startValue, endValue, onStartChanged, onEndChanged, personaColor),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: MausamColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: MausamColors.surfaceVariant),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(startLabel, style: const TextStyle(fontSize: 11, color: MausamColors.secondary, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  DropdownButton<String>(
                    value: times.contains(startValue) ? startValue : times.first,
                    underline: const SizedBox(),
                    isDense: true,
                    items: times.map((t) => DropdownMenuItem(value: t, child: Text(t, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)))).toList(),
                    onChanged: (v) {
                      if (v != null) onStartChanged(v);
                    },
                  ),
                ],
              ),
              const Icon(Icons.arrow_forward_rounded, size: 20, color: MausamColors.secondary),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(endLabel, style: const TextStyle(fontSize: 11, color: MausamColors.secondary, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  DropdownButton<String>(
                    value: times.contains(endValue) ? endValue : times[1],
                    underline: const SizedBox(),
                    isDense: true,
                    items: times.map((t) => DropdownMenuItem(value: t, child: Text(t, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)))).toList(),
                    onChanged: (v) {
                      if (v != null) onEndChanged(v);
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _timePresetChip(
    String label,
    String start,
    String end,
    String currentStart,
    String currentEnd,
    Function(String) onStart,
    Function(String) onEnd,
    Color color,
  ) {
    final isSel = currentStart == start && currentEnd == end;
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        onStart(start);
        onEnd(end);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSel ? color : MausamColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isSel ? color : MausamColors.outlineVariant),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
            color: isSel ? Colors.white : MausamColors.primary,
          ),
        ),
      ),
    );
  }
}

class _OptionItem {
  final String title;
  final IconData icon;
  final String subtitle;
  _OptionItem(this.title, this.icon, this.subtitle);
}

// --- Relevance Sliders Screen (Smooth, Continuous Fluid Controls) ---