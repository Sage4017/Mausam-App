import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'screens/onboarding/onboarding_screen.dart';

void main() {
  // Wrapping the app in ProviderScope so Riverpod state management works everywhere
  runApp(const ProviderScope(child: MausamApp()));
}

class MausamApp extends StatelessWidget {
  const MausamApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mausam App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.grey.shade50,
      ),
      home: const OnboardingScreen(),
    );
  }
}
