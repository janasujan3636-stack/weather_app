import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../providers/weather_provider.dart';
import '../widgets/glass_container.dart';

class CitySearchScreen extends StatefulWidget {
  const CitySearchScreen({super.key});

  @override
  State<CitySearchScreen> createState() => _CitySearchScreenState();
}

class _CitySearchScreenState extends State<CitySearchScreen> {
  final _searchController = TextEditingController();
  List<Map<String, String>> _searchResults = [];
  bool _isSearching = false;

  final List<String> _quickExploreCities = [
    'Mumbai',
    'Delhi',
    'Bengaluru',
    'Pune',
    'Thane',
    'London',
    'New York',
    'Tokyo',
    'Dubai',
    'Paris',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Live Search across any city globally using Open-Meteo Geocoding REST API
  Future<void> _searchCities(String query) async {
    final clean = query.trim();
    if (clean.length < 2) {
      setState(() => _searchResults = []);
      return;
    }

    setState(() => _isSearching = true);

    try {
      final url = Uri.parse(
        'https://geocoding-api.open-meteo.com/v1/search?name=${Uri.encodeComponent(clean)}&count=6&language=en&format=json',
      );
      final res = await http.get(url).timeout(const Duration(seconds: 4));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data['results'] != null) {
          final List list = data['results'];
          final results = list.map<Map<String, String>>((item) {
            return {
              'name': item['name']?.toString() ?? clean,
              'country': item['country']?.toString() ?? '',
              'admin': item['admin1']?.toString() ?? '',
            };
          }).toList();
          setState(() => _searchResults = results);
        } else {
          setState(() => _searchResults = []);
        }
      }
    } catch (_) {
      // If offline, provide current query as direct result
      setState(() {
        _searchResults = [
          {'name': clean, 'country': '', 'admin': 'Search match'}
        ];
      });
    } finally {
      setState(() => _isSearching = false);
    }
  }

  void _selectAndSaveCity(String cityName) {
    final prov = Provider.of<WeatherProvider>(context, listen: false);
    prov.fetchWeatherData(cityName);
    prov.addSavedCity(cityName);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.sd_storage_rounded, color: Colors.tealAccent, size: 20),
            const SizedBox(width: 8),
            Text('Saved "$cityName" to local device storage!'),
          ],
        ),
        backgroundColor: const Color(0xFF152238),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(milliseconds: 1800),
      ),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<WeatherProvider>();

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Search & Stored Cities', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 14),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.save_alt_rounded, size: 14, color: Color(0xFF00D2FF)),
                const SizedBox(width: 4),
                Text(
                  '${prov.savedCities.length} Saved',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0F2027),
              Color(0xFF203A43),
              Color(0xFF2C5364),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Live Search Input Box
                GlassContainer(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                  child: Row(
                    children: [
                      const Icon(Icons.search, color: Colors.white70),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                            hintText: 'Search any city (e.g. Pune, London)...',
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            filled: false,
                          ),
                          onChanged: (val) => _searchCities(val),
                          onSubmitted: (val) {
                            if (val.trim().isNotEmpty) _selectAndSaveCity(val.trim());
                          },
                        ),
                      ),
                      if (_isSearching)
                        const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF00D2FF)),
                        )
                      else if (_searchController.text.isNotEmpty)
                        IconButton(
                          icon: const Icon(Icons.clear, color: Colors.white60, size: 20),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchResults = []);
                          },
                        ),
                    ],
                  ),
                ),

                // Live Search Dropdown Suggestions (if searching)
                if (_searchResults.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  GlassContainer(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Column(
                      children: _searchResults.map((item) {
                        final city = item['name'] ?? '';
                        final sub = [item['admin'], item['country']]
                            .where((s) => s != null && s.isNotEmpty)
                            .join(', ');
                        return ListTile(
                          dense: true,
                          leading: const Icon(Icons.location_searching, color: Color(0xFF00D2FF), size: 20),
                          title: Text(city, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          subtitle: sub.isNotEmpty
                              ? Text(sub, style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12))
                              : null,
                          trailing: const Icon(Icons.add_circle_outline, color: Colors.tealAccent, size: 20),
                          onTap: () => _selectAndSaveCity(city),
                        );
                      }).toList(),
                    ),
                  ),
                ],

                const SizedBox(height: 18),

                // Quick Suggestion Chips
                const Text(
                  'QUICK LOCATIONS',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _quickExploreCities.map((city) {
                      final isSaved = prov.isCitySaved(city);
                      final isCurrent = prov.currentCity.toLowerCase() == city.toLowerCase();

                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: ActionChip(
                          avatar: Icon(
                            isCurrent
                                ? Icons.my_location
                                : (isSaved ? Icons.bookmark : Icons.add_location_alt_outlined),
                            size: 16,
                            color: isCurrent ? Colors.black : Colors.white70,
                          ),
                          label: Text(city),
                          backgroundColor: isCurrent
                              ? const Color(0xFF00D2FF)
                              : Colors.white.withOpacity(0.12),
                          labelStyle: TextStyle(
                            color: isCurrent ? Colors.black : Colors.white,
                            fontWeight: isCurrent ? FontWeight.bold : FontWeight.w500,
                            fontSize: 13,
                          ),
                          side: BorderSide(
                            color: isCurrent ? const Color(0xFF00D2FF) : Colors.white.withOpacity(0.2),
                          ),
                          onPressed: () => _selectAndSaveCity(city),
                        ),
                      );
                    }).toList(),
                  ),
                ),

                const SizedBox(height: 20),

                // Saved Locations on Device Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.storage_rounded, size: 16, color: Color(0xFF00D2FF)),
                        const SizedBox(width: 6),
                        const Text(
                          'STORED ON DEVICE (SHARRED PREFERENCES)',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.1,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      'Auto-Persisted',
                      style: TextStyle(fontSize: 11, color: Colors.tealAccent.withOpacity(0.8)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Saved Cities List (Stored on Device)
                Expanded(
                  child: prov.savedCities.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.save_outlined, size: 48, color: Colors.white.withOpacity(0.3)),
                              const SizedBox(height: 10),
                              Text(
                                'No cities saved on device yet.',
                                style: TextStyle(color: Colors.white.withOpacity(0.7)),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Search any city above to store it permanently.',
                                style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12),
                              ),
                            ],
                          ),
                        )
                      : ListView.separated(
                          itemCount: prov.savedCities.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final city = prov.savedCities[index];
                            final isCurrent = prov.currentCity.toLowerCase() == city.toLowerCase();

                            return GlassContainer(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                              child: ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: isCurrent
                                        ? const Color(0xFF00D2FF).withOpacity(0.25)
                                        : Colors.white.withOpacity(0.08),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    isCurrent ? Icons.my_location : Icons.location_on_outlined,
                                    color: isCurrent ? const Color(0xFF00D2FF) : Colors.white70,
                                    size: 20,
                                  ),
                                ),
                                title: Row(
                                  children: [
                                    Text(
                                      city,
                                      style: TextStyle(
                                        fontWeight: isCurrent ? FontWeight.bold : FontWeight.w600,
                                        color: Colors.white,
                                        fontSize: 16,
                                      ),
                                    ),
                                    if (isCurrent) ...[
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF00D2FF).withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: const Text(
                                          'ACTIVE',
                                          style: TextStyle(
                                            color: Color(0xFF00D2FF),
                                            fontSize: 9,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                subtitle: Text(
                                  'Stored in Device Storage',
                                  style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 11),
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                                      tooltip: 'Remove from Device',
                                      onPressed: () {
                                        prov.removeSavedCity(city);
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text('Removed "$city" from device storage'),
                                            duration: const Duration(seconds: 1),
                                            behavior: SnackBarBehavior.floating,
                                          ),
                                        );
                                      },
                                    ),
                                    const Icon(Icons.chevron_right, color: Colors.white38),
                                  ],
                                ),
                                onTap: () => _selectAndSaveCity(city),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
