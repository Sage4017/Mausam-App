import 'package:flutter/material.dart';
import '../models/app_models.dart';
import '../core/app_theme.dart';
import '../services/app_state.dart';
import '../widgets/frosted_glass_card.dart';
import '../widgets/pill_button.dart';


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