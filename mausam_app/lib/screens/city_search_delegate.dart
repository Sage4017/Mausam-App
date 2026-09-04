import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../core/app_theme.dart';
import '../services/app_state.dart';

class CitySearchDelegate extends SearchDelegate<void> {
  Timer? _debounce;
  List<Map<String, dynamic>> _results = [];
  bool _isSearching = false;

  @override
  String get searchFieldLabel => "Search for a city...";

  @override
  ThemeData appBarTheme(BuildContext context) {
    final theme = Theme.of(context);
    return theme.copyWith(
      appBarTheme: AppBarTheme(
        backgroundColor: MausamColors.surface,
        iconTheme: const IconThemeData(color: MausamColors.primary),
        elevation: 0,
      ),
      inputDecorationTheme: const InputDecorationTheme(
        border: InputBorder.none,
      ),
    );
  }

  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) {
      _results = [];
      return;
    }
    
    _isSearching = true;
    try {
      final url = Uri.parse('https://geocoding-api.open-meteo.com/v1/search?name=${Uri.encodeComponent(query)}&count=10&language=en&format=json');
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final results = data['results'] as List<dynamic>?;
        if (results != null) {
          _results = results.cast<Map<String, dynamic>>();
        } else {
          _results = [];
        }
      }
    } catch (e) {
      debugPrint("Search error: $e");
    } finally {
      _isSearching = false;
    }
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            query = '';
            _results = [];
            showSuggestions(context);
          },
        )
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildList(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      await _performSearch(query);
      if (context.mounted) {
        showSuggestions(context);
      }
    });

    return _buildList(context);
  }

  Widget _buildList(BuildContext context) {
    if (_isSearching) {
      return const Center(child: CircularProgressIndicator());
    }

    if (query.isNotEmpty && _results.isEmpty && !_isSearching) {
      return Center(
        child: Text(
          "No cities found for '$query'",
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      );
    }

    return ListView.builder(
      itemCount: _results.length,
      itemBuilder: (context, index) {
        final r = _results[index];
        final name = r['name'] ?? 'Unknown';
        final admin1 = r['admin1'] ?? '';
        final country = r['country'] ?? '';
        final lat = (r['latitude'] as num?)?.toDouble() ?? 0.0;
        final lon = (r['longitude'] as num?)?.toDouble() ?? 0.0;
        
        final subtitle = [admin1, country].where((e) => e.isNotEmpty).join(', ');

        return ListTile(
          leading: const Icon(Icons.location_city, color: MausamColors.primary),
          title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text(subtitle),
          onTap: () {
            final state = AppStateScope.of(context);
            state.setOverrideLocation(lat, lon, '$name, $country');
            close(context, null);
          },
        );
      },
    );
  }
}
