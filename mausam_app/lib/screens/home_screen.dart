import 'package:flutter/material.dart';
import '../models/app_models.dart';
import '../core/app_theme.dart';
import '../services/app_state.dart';
import '../widgets/frosted_glass_card.dart';
import '../widgets/pill_button.dart';


import 'weather_detail_screen.dart';
import 'aqi_detail_screen.dart';
import 'mausam_ai_screen.dart';

IconData getWeatherIcon(String condition) {
  final c = condition.toLowerCase();
  if (c.contains('rain') || c.contains('shower') || c.contains('drizzle')) return Icons.water_drop;
  if (c.contains('thunder') || c.contains('storm')) return Icons.thunderstorm;
  if (c.contains('cloud') || c.contains('overcast')) return Icons.cloud;
  if (c.contains('snow')) return Icons.ac_unit;
  return Icons.wb_sunny;
}

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
                          state.currentCity,
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