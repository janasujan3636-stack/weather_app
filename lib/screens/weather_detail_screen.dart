import 'package:flutter/material.dart';
import '../models/weather_model.dart';
import '../widgets/glass_container.dart';
import '../widgets/weather_info_tile.dart';

class WeatherDetailScreen extends StatelessWidget {
  final WeatherModel weather;

  const WeatherDetailScreen({super.key, required this.weather});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          '${weather.city} Atmospheric Insights',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
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
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 12.0),
            children: [
              // Summary Banner
              GlassContainer(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'CURRENT AIR QUALITY',
                            style: TextStyle(
                              fontSize: 12,
                              letterSpacing: 1.2,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF00D2FF),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'AQI ${weather.aqi} - Satisfactory',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Air quality is acceptable for most individuals. Ideal for outdoor activities.',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.white.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.teal.withOpacity(0.25),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.tealAccent, width: 2),
                      ),
                      child: const Icon(Icons.eco_rounded, color: Colors.tealAccent, size: 36),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // Sun Times
              GlassContainer(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.wb_twilight_rounded, color: Colors.amberAccent, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'SOLAR CYCLE',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                            color: Colors.white.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: [
                            const Text('Sunrise', style: TextStyle(color: Colors.white70)),
                            const SizedBox(height: 4),
                            Text(
                              weather.sunrise,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        Container(height: 35, width: 1, color: Colors.white24),
                        Column(
                          children: [
                            const Text('Sunset', style: TextStyle(color: Colors.white70)),
                            const SizedBox(height: 4),
                            Text(
                              weather.sunset,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // 2x2 Atmospheric Grid
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 14,
                crossAxisSpacing: 14,
                childAspectRatio: 1.25,
                children: [
                  WeatherInfoTile(
                    icon: Icons.wb_sunny_rounded,
                    iconColor: Colors.amberAccent,
                    label: 'UV Index',
                    value: '${weather.uvIndex.toStringAsFixed(1)} High',
                    subtext: 'Protection required during midday',
                  ),
                  WeatherInfoTile(
                    icon: Icons.water_drop_rounded,
                    iconColor: const Color(0xFF00D2FF),
                    label: 'Humidity',
                    value: '${weather.humidity}%',
                    subtext: 'Dew point is 21°C',
                  ),
                  WeatherInfoTile(
                    icon: Icons.compress_rounded,
                    iconColor: Colors.purpleAccent,
                    label: 'Pressure',
                    value: '${weather.pressure} hPa',
                    subtext: 'Standard barometric level',
                  ),
                  WeatherInfoTile(
                    icon: Icons.visibility_rounded,
                    iconColor: Colors.lightGreenAccent,
                    label: 'Visibility',
                    value: '10 km',
                    subtext: 'Completely clear horizon',
                  ),
                ],
              ),

              const SizedBox(height: 18),

              // Wind Radar Info
              GlassContainer(
                padding: const EdgeInsets.all(18),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.navigation_rounded, color: Color(0xFF00D2FF), size: 30),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'WIND & GUSTS',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                              color: Colors.white70,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${weather.windSpeed} km/h • South-West',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            'Gusts up to ${(weather.windSpeed * 1.3).toStringAsFixed(1)} km/h',
                            style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.6)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
