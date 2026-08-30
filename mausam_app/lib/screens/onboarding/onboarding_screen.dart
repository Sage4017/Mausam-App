import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/api_client.dart';
import '../../core/token_storage.dart';
import '../../core/main_navigation.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  // The exact categories your backend expects
  final List<String> _categories = [
    "Health",
    "Outdoor Fitness",
    "Beach & Surf",
    "Travel",
    "Family",
    "Agriculture",
    "Commuter",
    "Events"
  ];

  // Keep track of what the user taps
  final Set<String> _selectedCategories = {};
  bool _isLoading = false;

  Future<void> _submitPreferences() async {
    if (_selectedCategories.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select at least one interest!")),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // 1. Format the JSON payload exactly how the Python backend expects it
      // 1.0 means High Priority, 0.0 means Ignore
      final Map<String, dynamic> answers = {};
      for (var category in _categories) {
        answers[category] = _selectedCategories.contains(category) ? 1.0 : 0.0;
      }

      // 2. Send the POST request to the Python backend
      final response = await apiClient.submitOnboarding({"answers": answers});

      // 3. Save the returned user_id to local storage to keep them logged in
      final userId = response.data['user_id'] ?? 'dummy_user';
      await TokenStorage.saveToken(userId);

      // 4. Navigate into the main app (Homepage)
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const MainNavigation()),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error communicating with backend: $e")),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Personalize Your Weather"),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              "What do you care about?",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              "Select your interests so our AI can rank the weather widgets for you.",
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 32),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: _categories.map((category) {
                final isSelected = _selectedCategories.contains(category);
                return FilterChip(
                  label: Text(category),
                  selected: isSelected,
                  selectedColor: Colors.blueAccent.withOpacity(0.2),
                  checkmarkColor: Colors.blueAccent,
                  onSelected: (bool selected) {
                    setState(() {
                      if (selected) {
                        _selectedCategories.add(category);
                      } else {
                        _selectedCategories.remove(category);
                      }
                    });
                  },
                );
              }).toList(),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: _isLoading ? null : _submitPreferences,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                      "Continue",
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
