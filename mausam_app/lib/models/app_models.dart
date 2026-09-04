import 'package:flutter/material.dart';
import '../core/app_theme.dart';

enum PersonaType {
  fitness('Fitness', Icons.fitness_center, MausamColors.fitnessBlue, 'Run & workout conditions', 'Outdoor Fitness'),
  health('Health', Icons.monitor_heart, MausamColors.healthTeal, 'Air quality, UV, pollen tracking', 'Health'),
  beach('Beach / Surf', Icons.surfing, MausamColors.beachAqua, 'Tides, wind, water temperature', 'Beach & Surf'),
  travel('Travel', Icons.flight, MausamColors.primary, 'Flight delays, destination weather', 'Travel'),
  family('Family', Icons.family_restroom, MausamColors.warningAmber, 'Park play, stroller friendliness', 'Family'),
  agriculture('Agriculture', Icons.agriculture, MausamColors.tertiary, 'Soil moisture, frost alerts', 'Agriculture'),
  commute('Commute', Icons.directions_car, MausamColors.primaryContainer, 'Road conditions, transit rain alerts', 'Commuter'),
  event('Event', Icons.event, MausamColors.fitnessBlue, 'Outdoor wedding & sports forecast', 'Events');

  final String title;
  final IconData icon;
  final Color color;
  final String description;
  final String backendCategory;

  const PersonaType(this.title, this.icon, this.color, this.description, this.backendCategory);
}

class WeatherSummaryModel {
  final double temperature;
  final double apparentTemperature;
  final double humidity;
  final double rainProbability;
  final double windSpeed;
  final double uvIndex;
  final double aqi;
  final double pm25;
  final double pm10;
  final double dust;
  final String condition;
  final String climateZone;
  final double latitude;
  final double longitude;
  final double waveHeight;
  final double waterTemp;

  WeatherSummaryModel({
    required this.temperature,
    required this.apparentTemperature,
    required this.humidity,
    required this.rainProbability,
    required this.windSpeed,
    required this.uvIndex,
    required this.aqi,
    this.pm25 = 0.0,
    this.pm10 = 0.0,
    this.dust = 0.0,
    required this.condition,
    required this.climateZone,
    required this.latitude,
    required this.longitude,
    this.waveHeight = 0.0,
    this.waterTemp = 0.0,
  });

  factory WeatherSummaryModel.fromJson(Map<String, dynamic> json, [Map<String, dynamic>? rawCtx]) {
    return WeatherSummaryModel(
      temperature: (json['temperature'] ?? rawCtx?['temperature'] ?? 25.0).toDouble(),
      apparentTemperature: (json['apparent_temperature'] ?? rawCtx?['apparent_temperature'] ?? 25.0).toDouble(),
      humidity: (json['humidity'] ?? rawCtx?['humidity'] ?? 60.0).toDouble(),
      rainProbability: (json['rain_probability'] ?? rawCtx?['rain_probability'] ?? 0.0).toDouble(),
      windSpeed: (json['wind_speed'] ?? rawCtx?['wind_speed'] ?? 5.0).toDouble(),
      uvIndex: (json['uv_index'] ?? rawCtx?['uv_index'] ?? 0.0).toDouble(),
      aqi: (json['air_quality_index'] ?? rawCtx?['air_quality_index'] ?? 50.0).toDouble(),
      pm25: (rawCtx?['pm2_5'] ?? 0.0).toDouble(),
      pm10: (rawCtx?['pm10'] ?? 0.0).toDouble(),
      dust: (rawCtx?['dust'] ?? 0.0).toDouble(),
      condition: (json['condition'] ?? rawCtx?['condition'] ?? 'Clear').toString(),
      climateZone: (json['climate_zone'] ?? rawCtx?['climate_zone'] ?? 'tropical').toString(),
      latitude: (json['latitude'] ?? 28.6139).toDouble(),
      longitude: (json['longitude'] ?? 77.2090).toDouble(),
      waveHeight: (rawCtx?['wave_height'] ?? 1.0).toDouble(),
      waterTemp: (rawCtx?['water_temp'] ?? 24.0).toDouble(),
    );
  }
}

class WidgetCardModel {
  final int rank;
  final String widgetId;
  final String category;
  final String title;
  final String badge;
  final Map<String, dynamic> highlights;

  WidgetCardModel({
    required this.rank,
    required this.widgetId,
    required this.category,
    required this.title,
    required this.badge,
    required this.highlights,
  });

  factory WidgetCardModel.fromJson(Map<String, dynamic> json) {
    return WidgetCardModel(
      rank: json['rank'] ?? 1,
      widgetId: json['widget_id'] ?? '',
      category: json['category'] ?? '',
      title: json['title'] ?? '',
      badge: json['badge'] ?? '',
      highlights: json['highlights'] != null ? Map<String, dynamic>.from(json['highlights']) : {},
    );
  }

  IconData get icon {
    final cat = category.toLowerCase();
    final wid = widgetId.toLowerCase();
    if (cat.contains('fitness') || wid.contains('fitness') || wid.contains('run')) return Icons.directions_run;
    if (cat.contains('health') || wid.contains('health') || wid.contains('aqi')) return Icons.monitor_heart;
    if (cat.contains('beach') || cat.contains('surf') || wid.contains('beach') || wid.contains('surf')) return Icons.surfing;
    if (cat.contains('commut') || wid.contains('commut')) return Icons.directions_car;
    if (cat.contains('family') || cat.contains('kid') || wid.contains('family')) return Icons.family_restroom;
    if (cat.contains('agri') || cat.contains('garden') || wid.contains('agri')) return Icons.agriculture;
    if (cat.contains('travel') || cat.contains('trip') || wid.contains('travel')) return Icons.flight;
    if (cat.contains('event') || wid.contains('event')) return Icons.event;
    return Icons.wb_sunny_rounded;
  }

  Color get color {
    final cat = category.toLowerCase();
    final wid = widgetId.toLowerCase();
    if (cat.contains('fitness') || wid.contains('fitness') || wid.contains('run')) return MausamColors.fitnessBlue;
    if (cat.contains('health') || wid.contains('health') || wid.contains('aqi')) return MausamColors.healthTeal;
    if (cat.contains('beach') || cat.contains('surf') || wid.contains('beach') || wid.contains('surf')) return MausamColors.beachAqua;
    if (cat.contains('commut') || wid.contains('commut')) return MausamColors.primaryContainer;
    if (cat.contains('family') || cat.contains('kid') || wid.contains('family')) return MausamColors.warningAmber;
    if (cat.contains('agri') || cat.contains('garden') || wid.contains('agri')) return MausamColors.tertiary;
    if (cat.contains('travel') || cat.contains('trip') || wid.contains('travel')) return MausamColors.primary;
    if (cat.contains('event') || wid.contains('event')) return MausamColors.fitnessBlue;
    return MausamColors.primary;
  }
}

class HourlyForecastItem {
  final String time;
  final double tempC;
  final IconData icon;
  HourlyForecastItem(this.time, this.tempC, this.icon);
}

class DailyForecastItem {
  final String day;
  final IconData icon;
  final double lowC;
  final double highC;
  DailyForecastItem(this.day, this.icon, this.lowC, this.highC);
}

class PollutantDetail {
  final String name;
  final String value;
  final String unit;
  final String status;
  final double progress;
  final Color color;
  PollutantDetail(this.name, this.value, this.unit, this.status, this.progress, this.color);
}

class ChatMessageModel {
  final String sender;
  final String text;
  final String? cardTitle;
  final String? cardSubtitle;
  ChatMessageModel({required this.sender, required this.text, this.cardTitle, this.cardSubtitle});
}