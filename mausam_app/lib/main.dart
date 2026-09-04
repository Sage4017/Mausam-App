import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'services/api_client.dart';
import 'models/app_models.dart';
import 'core/app_theme.dart';
import 'services/app_state.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'widgets/frosted_glass_card.dart';
import 'widgets/pill_button.dart';
import 'screens/splash_screen.dart';


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







// --- Dedicated Persona Question Screen (Sequential Step-by-Step) ---




// --- Relevance Sliders Screen (Rated out of 10 instead of percentage) ---


// ============================================================================
// 5. MASTER SHELL & ROUTER
// ============================================================================



// ============================================================================
// 6. LIVE HOME DASHBOARD WITH INTERACTIVE PERSONA CARDS & FILTERING
// ============================================================================



// ============================================================================
// 7. IN-DEPTH DETAIL VIEWS (Weather Detail & AQI)
// ============================================================================







// ============================================================================
// 8. EXPLORE, AI CHAT, ALERTS & PROFILE
// ============================================================================











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
