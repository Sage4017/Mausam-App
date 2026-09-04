import 'package:flutter/material.dart';
import '../models/app_models.dart';
import '../core/app_theme.dart';
import '../services/app_state.dart';
import '../widgets/frosted_glass_card.dart';
import '../widgets/pill_button.dart';


class MausamAIScreen extends StatefulWidget {
  const MausamAIScreen({super.key});

  @override
  State<MausamAIScreen> createState() => _MausamAIScreenState();
}

class _MausamAIScreenState extends State<MausamAIScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<ChatMessageModel> _messages = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_messages.isEmpty) {
      final state = AppStateScope.of(context);
      final temp = state.formatTemp(state.weatherSummary?.temperature);
      final cond = state.weatherSummary?.condition ?? 'Partly cloudy';
      final aqi = (state.weatherSummary?.aqi ?? 225).toInt();

      _messages.addAll([
        ChatMessageModel(
          sender: 'ai',
          text: 'Hello! I\'m Mausam AI, powered by your live backend telemetry. Current live conditions: $temp, $cond, AQI $aqi. How can I assist your outdoor planning?',
        ),
        ChatMessageModel(
          sender: 'user',
          text: 'Can I go for my workout now?',
        ),
        ChatMessageModel(
          sender: 'ai',
          text: 'Currently, the temperature is $temp and $cond with an AQI of $aqi. For outdoor cardio, check if air quality requires indoor training.',
          cardTitle: aqi > 150 ? 'Run Index: Indoor Recommended' : 'Run Index: Optimal',
          cardSubtitle: 'Based on live Open-Meteo & IMD models',
        ),
      ]);
    }
  }

  void _sendMessage(String query) {
    if (query.trim().isEmpty) return;
    final state = AppStateScope.of(context);
    final temp = state.formatTemp(state.weatherSummary?.temperature);
    final cond = state.weatherSummary?.condition ?? 'Partly cloudy';

    setState(() {
      _messages.add(ChatMessageModel(sender: 'user', text: query));
      _controller.clear();
      _messages.add(ChatMessageModel(
        sender: 'ai',
        text: 'Analyzing live atmospheric context for "$query"... Live temperature is $temp with $cond skies and ${state.weatherSummary?.humidity.toInt() ?? 76}% humidity.',
      ));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Ask Mausam AI', style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: MausamColors.primary)),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final msg = _messages[index];
                  final isUser = msg.sender == 'user';

                  return Align(
                    alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isUser ? MausamColors.primary : MausamColors.surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(16),
                        border: isUser ? null : Border.all(color: MausamColors.surfaceVariant),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            msg.text,
                            style: TextStyle(
                              color: isUser ? Colors.white : MausamColors.onSurfaceStrong,
                              fontSize: 14,
                            ),
                          ),
                          if (msg.cardTitle != null) ...[
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: MausamColors.surfaceContainerHigh,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.check_circle, size: 16, color: MausamColors.fitnessBlue),
                                  const SizedBox(width: 8),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(msg.cardTitle!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                      Text(msg.cardSubtitle!, style: const TextStyle(fontSize: 10, color: MausamColors.secondary)),
                                    ],
                                  )
                                ],
                              ),
                            )
                          ]
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // Prompt Suggestions
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                children: [
                  _suggestionChip('Should I carry an umbrella?'),
                  _suggestionChip('Is today good for running?'),
                  _suggestionChip('What are current PM2.5 levels?'),
                ],
              ),
            ),

            // Input Bar
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: 'Ask Mausam...',
                        filled: true,
                        fillColor: MausamColors.surfaceContainerLowest,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onSubmitted: _sendMessage,
                    ),
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    backgroundColor: MausamColors.primary,
                    child: IconButton(
                      icon: const Icon(Icons.send, color: Colors.white, size: 18),
                      onPressed: () => _sendMessage(_controller.text),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _suggestionChip(String text) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ActionChip(
        label: Text(text, style: const TextStyle(fontSize: 11, color: MausamColors.primary)),
        backgroundColor: MausamColors.surfaceContainerLowest,
        shape: const StadiumBorder(),
        onPressed: () => _sendMessage(text),
      ),
    );
  }
}