import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/homepage_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // This watches the provider. Whenever the backend data updates, 
    // the UI will automatically rebuild!
    final personalizedWidgets = ref.watch(homepageProvider);

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: personalizedWidgets.length,
        itemBuilder: (context, index) {
          final widgetItem = personalizedWidgets[index];
          
          // A simple card to display the mock data
          return Card(
            margin: const EdgeInsets.only(bottom: 16.0),
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        widgetItem.type.toUpperCase(),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          // Make alerts red, everything else blue
                          color: widgetItem.type == 'severe_alert' 
                              ? Colors.red 
                              : Colors.blue.shade800,
                        ),
                      ),
                      Text(
                        'AI Score: ${widgetItem.score}',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const Divider(),
                  const SizedBox(height: 8),
                  // Displaying the fake JSON data dynamically
                  Text(
                    widgetItem.data.toString(),
                    style: const TextStyle(fontSize: 16, height: 1.5),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
