import 'package:flutter/material.dart';
import '../models/app_models.dart';
import '../core/app_theme.dart';
import '../services/app_state.dart';
import '../widgets/frosted_glass_card.dart';
import '../widgets/pill_button.dart';


import 'home_screen.dart';
import 'explore_screen.dart';
import 'alerts_screen.dart';
import 'profile_screen.dart';

class MainShellScreen extends StatelessWidget {
  const MainShellScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);

    final screens = const [
      HomeScreen(),
      ExploreScreen(),
      AlertsScreen(),
      ProfileScreen(),
    ];

    return Scaffold(
      body: screens[state.currentBottomNavIndex.clamp(0, 3)], // clamped to avoid out of bounds
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
                _navItem(context, 2, Icons.notifications_rounded, 'Alerts', state.currentBottomNavIndex == 2),
                _navItem(context, 3, Icons.person_rounded, 'Me', state.currentBottomNavIndex == 3),
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