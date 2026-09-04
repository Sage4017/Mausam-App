import 'package:flutter/material.dart';
import '../models/app_models.dart';
import '../core/app_theme.dart';
import 'api_client.dart';

class AppState extends ChangeNotifier {
  // Navigation
  int currentBottomNavIndex = 0;

  // Selected Personas & Weights (Rated out of 10)
  final Set<PersonaType> selectedPersonas = {
    PersonaType.fitness,
    PersonaType.health,
    PersonaType.agriculture,
  };
  final Map<PersonaType, double> personaWeights = {
    PersonaType.fitness: 8.0,
    PersonaType.health: 9.0,
    PersonaType.agriculture: 10.0,
  };

  // Structured Probing Questionnaire Responses for each Persona
  final Map<String, dynamic> probingAnswers = {
    // 1. Fitness
    'fitness_activities': ['Running', 'Outdoor workout'],
    'fitness_start_time': '06:00 AM',
    'fitness_end_time': '07:30 AM',
    'fitness_location': 'Park or trail',

    // 2. Health
    'health_plans': ['Exercise', 'Spend time outdoors'],
    'health_start_time': '07:00 AM',
    'health_end_time': '09:00 AM',
    'health_location': 'Current location',

    // 3. Beach / Surf
    'beach_plans': ['Surf', 'Swim'],
    'beach_start_time': '02:00 PM',
    'beach_end_time': '05:00 PM',
    'beach_location': 'Local coast',

    // 4. Travel
    'travel_destination': 'Mumbai, India',
    'travel_departure': '08:00 AM',
    'travel_arrival': '11:30 AM',
    'travel_modes': ['Flight', 'Car'],

    // 5. Family
    'family_plans': ['Outdoor play', 'Park visit'],
    'family_start_time': '04:30 PM',
    'family_end_time': '06:30 PM',
    'family_location': 'Park or playground',

    // 6. Agriculture
    'agri_plans': ['Irrigate', 'Spray', 'Inspect'],
    'agri_crop': 'Vegetables',
    'agri_stage': 'Growing',
    'agri_location': 'Local farm / field',

    // 7. Commute
    'commute_destination': 'Office / Work',
    'commute_start_time': '08:30 AM',
    'commute_end_time': '09:30 AM',
    'commute_modes': ['Car', 'Bike'],

    // 8. Event
    'event_plans': ['Outdoor gathering'],
    'event_start_time': '06:00 PM',
    'event_end_time': '10:00 PM',
    'event_location': 'Open lawn / Garden',
  };

  // Active Ribbon Filter on Home Screen
  String selectedRibbonFilter = 'All Focus';

  bool isCelsius = true;

  // Live Backend Data
  bool isLoading = false;
  String? errorMessage;
  WeatherSummaryModel? weatherSummary;
  List<WidgetCardModel> primaryWidgets = [];
  List<WidgetCardModel> secondaryWidgets = [];

  AppState() {
    fetchLiveFeed();
  }

  void setBottomNavIndex(int index) {
    currentBottomNavIndex = index;
    notifyListeners();
  }

  void setRibbonFilter(String filter) {
    selectedRibbonFilter = filter;
    notifyListeners();
  }

  void togglePersona(PersonaType persona) {
    if (selectedPersonas.contains(persona)) {
      if (selectedPersonas.length > 1) {
        selectedPersonas.remove(persona);
        personaWeights.remove(persona);
      }
    } else {
      if (selectedPersonas.length < 4) {
        selectedPersonas.add(persona);
        personaWeights[persona] = 8.0;
      }
    }
    notifyListeners();
  }

  void updateWeight(PersonaType persona, double scoreOutOf10) {
    personaWeights[persona] = scoreOutOf10;
    notifyListeners();
  }

  void updateProbingAnswer(String key, dynamic value) {
    probingAnswers[key] = value;
    notifyListeners();
  }

  void toggleMultiSelection(String key, String option) {
    final list = List<String>.from(probingAnswers[key] ?? <String>[]);
    if (list.contains(option)) {
      if (list.length > 1) list.remove(option);
    } else {
      list.add(option);
    }
    probingAnswers[key] = list;
    notifyListeners();
  }

  void toggleUnits() {
    isCelsius = !isCelsius;
    notifyListeners();
  }

  String formatTemp(double? tempC) {
    if (tempC == null) return '--';
    if (isCelsius) {
      return '${tempC.round()}°C';
    } else {
      final f = (tempC * 9.0 / 5.0) + 32.0;
      return '${f.round()}°F';
    }
  }

  String formatSpeed(double? kmh) {
    if (kmh == null) return '--';
    if (isCelsius) {
      return '$kmh km/h';
    } else {
      final mph = (kmh * 0.621371).round();
      return '$mph mph';
    }
  }

  Map<String, dynamic> buildBackendPreferencesMap() {
    final prefs = <String, dynamic>{};
    for (final p in PersonaType.values) {
      if (selectedPersonas.contains(p)) {
        final score = personaWeights[p] ?? 8.0;
        prefs[p.backendCategory] = (score / 10.0).clamp(0.1, 1.0);
      } else {
        prefs[p.backendCategory] = 0.0;
      }
    }
    return prefs;
  }

  Future<void> fetchLiveFeed() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final prefs = buildBackendPreferencesMap();
      final heroCount = selectedPersonas.length.clamp(1, 4);

      final homeResponse = await apiClient.getCustomFeed(
        userPreferences: prefs,
        heroCount: heroCount,
      );

      Map<String, dynamic>? rawCtx;
      try {
        final weatherResponse = await apiClient.getCurrentWeather();
        if (weatherResponse.data is Map && weatherResponse.data['context'] is Map) {
          rawCtx = Map<String, dynamic>.from(weatherResponse.data['context']);
        }
      } catch (e) {
        debugPrint('Context fetch fallback: $e');
      }

      if (homeResponse.data is Map) {
        final data = Map<String, dynamic>.from(homeResponse.data);
        final weatherJson = data['weather_summary'] is Map ? Map<String, dynamic>.from(data['weather_summary']) : <String, dynamic>{};
        weatherSummary = WeatherSummaryModel.fromJson(weatherJson, rawCtx);

        if (data['primary_widgets'] is List) {
          primaryWidgets = (data['primary_widgets'] as List)
              .map((w) => WidgetCardModel.fromJson(Map<String, dynamic>.from(w)))
              .toList();
        }

        if (data['secondary_widgets'] is List) {
          secondaryWidgets = (data['secondary_widgets'] as List)
              .map((w) => WidgetCardModel.fromJson(Map<String, dynamic>.from(w)))
              .toList();
        }
      }
    } catch (err) {
      debugPrint('Error fetching live backend feed: $err');
      errorMessage = 'Could not sync with FastAPI server. Tap refresh to retry.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> submitSurveyAnswers() async {
    final answers = Map<String, dynamic>.from(probingAnswers);
    for (final p in selectedPersonas) {
      final score = personaWeights[p] ?? 8.0;
      answers[p.backendCategory] = (score / 10.0).clamp(0.1, 1.0);
    }

    try {
      await apiClient.submitOnboarding(answers);
      await fetchLiveFeed();
    } catch (e) {
      debugPrint('Onboarding submit error: $e');
      await fetchLiveFeed();
    }
  }
}

class AppStateScope extends InheritedNotifier<AppState> {
  const AppStateScope({super.key, required AppState notifier, required super.child})
      : super(notifier: notifier);

  static AppState of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<AppStateScope>()!.notifier!;
  }
}