import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/weather_provider.dart';
import '../models/weather_model.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_container.dart';
import 'city_search_screen.dart';
import 'weather_detail_screen.dart';
import 'add_report_screen.dart';
import 'reports_list_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  LinearGradient _getWeatherGradient(String? condition) {
    if (condition == null) return AppTheme.clearSkyDayGradient;
    final c = condition.toLowerCase();
    if (c.contains('rain') || c.contains('drizzle')) return AppTheme.rainyGradient;
    if (c.contains('thunder') || c.contains('storm')) return AppTheme.stormyGradient;
    if (c.contains('snow')) return AppTheme.snowyGradient;
    if (c.contains('cloud') || c.contains('fog')) return AppTheme.cloudyGradient;
    return AppTheme.clearSkyDayGradient;
  }

  IconData _getWeatherIcon(String? condition) {
    if (condition == null) return Icons.wb_sunny_rounded;
    final c = condition.toLowerCase();
    if (c.contains('rain')) return Icons.grain_rounded;
    if (c.contains('thunder')) return Icons.flash_on_rounded;
    if (c.contains('snow')) return Icons.ac_unit_rounded;
    if (c.contains('cloud')) return Icons.cloud_rounded;
    return Icons.wb_sunny_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final weatherProv = context.watch<WeatherProvider>();
    final weather = weatherProv.currentWeather;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Column(
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.location_on, size: 18, color: Colors.white),
                const SizedBox(width: 4),
                Text(
                  weather?.city ?? weatherProv.currentCity,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
              ],
            ),
            Text(
              'LIVE WEATHER API (GET)',
              style: TextStyle(
                fontSize: 10,
                color: Colors.white.withOpacity(0.7),
                letterSpacing: 1.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.search_rounded),
          tooltip: 'Search City',
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CitySearchScreen()),
            );
          },
        ),
        actions: [
          // Save / Bookmark city to device storage
          IconButton(
            icon: Icon(
              weatherProv.isCitySaved(weather?.city ?? weatherProv.currentCity)
                  ? Icons.bookmark_rounded
                  : Icons.bookmark_border_rounded,
              color: weatherProv.isCitySaved(weather?.city ?? weatherProv.currentCity)
                  ? const Color(0xFF00D2FF)
                  : Colors.white,
            ),
            tooltip: 'Store location on device',
            onPressed: () {
              final activeCity = weather?.city ?? weatherProv.currentCity;
              if (weatherProv.isCitySaved(activeCity)) {
                weatherProv.removeSavedCity(activeCity);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Removed "$activeCity" from device storage'),
                    duration: const Duration(seconds: 1),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              } else {
                weatherProv.addSavedCity(activeCity);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Saved "$activeCity" to device storage!'),
                    backgroundColor: const Color(0xFF152238),
                    duration: const Duration(seconds: 1),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
          ),
          // Community Reports (REST CRUD & Firebase Storage)
          IconButton(
            icon: const Icon(Icons.photo_library_outlined),
            tooltip: 'Observation Feed (Firebase Storage)',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ReportsListScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.analytics_outlined),
            tooltip: 'Atmospheric Details',
            onPressed: () {
              if (weather != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => WeatherDetailScreen(weather: weather)),
                );
              }
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF00D2FF),
        foregroundColor: const Color(0xFF0F2027),
        icon: const Icon(Icons.add_a_photo_rounded),
        label: const Text('Add Report', style: TextStyle(fontWeight: FontWeight.bold)),
        tooltip: 'Upload Sky Observation to Firebase Storage',
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddReportScreen(currentCity: weather?.city ?? weatherProv.currentCity),
            ),
          );
        },
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: _getWeatherGradient(weather?.condition),
        ),
        child: SafeArea(
          child: weatherProv.isLoading && weather == null
              ? const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                )
              : RefreshIndicator(
                  color: Colors.white,
                  backgroundColor: const Color(0xFF1E3C72),
                  onRefresh: () => weatherProv.refreshWeather(),
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 8.0),
                    children: [
                      if (weatherProv.errorMessage != null)
                        Container(
                          padding: const EdgeInsets.all(12),
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Colors.redAccent.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            weatherProv.errorMessage!,
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),

                      // Hero Weather Card
                      _buildHeroWeather(context, weather),
                      const SizedBox(height: 18),

                      // Quick Metrics Glass Grid
                      _buildQuickMetrics(weather),
                      const SizedBox(height: 22),

                      // 24h Hourly Forecast Row
                      _buildHourlyForecast(weather),
                      const SizedBox(height: 22),

                      // 7-Day Forecast Card
                      _buildDailyForecast(weather),
                      const SizedBox(height: 80), // bottom padding for FAB
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildHeroWeather(BuildContext context, WeatherModel? weather) {
    if (weather == null) return const SizedBox.shrink();

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => WeatherDetailScreen(weather: weather)),
        );
      },
      child: GlassContainer(
        padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 20.0),
        child: Column(
          children: [
            Icon(
              _getWeatherIcon(weather.condition),
              size: 76,
              color: Colors.amberAccent,
            ),
            const SizedBox(height: 8),
            Text(
              '${weather.temperature.round()}°',
              style: const TextStyle(
                fontSize: 78,
                fontWeight: FontWeight.w200,
                color: Colors.white,
                letterSpacing: -4,
              ),
            ),
            Text(
              weather.condition.toUpperCase(),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              weather.description,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withOpacity(0.85),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Feels like ${weather.feelsLike.round()}°C  •  AQI ${weather.aqi} (Good)',
                style: const TextStyle(fontSize: 13, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickMetrics(WeatherModel? weather) {
    if (weather == null) return const SizedBox.shrink();

    return Row(
      children: [
        Expanded(
          child: _miniMetric(
            icon: Icons.water_drop_outlined,
            title: 'Humidity',
            value: '${weather.humidity}%',
            color: const Color(0xFF00D2FF),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _miniMetric(
            icon: Icons.air_rounded,
            title: 'Wind Speed',
            value: '${weather.windSpeed} km/h',
            color: Colors.tealAccent,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _miniMetric(
            icon: Icons.wb_sunny_outlined,
            title: 'UV Index',
            value: weather.uvIndex.toStringAsFixed(1),
            color: Colors.amberAccent,
          ),
        ),
      ],
    );
  }

  Widget _miniMetric({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return GlassContainer(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 6),
          Text(
            title,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: Colors.white.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHourlyForecast(WeatherModel? weather) {
    if (weather == null || weather.hourlyForecast.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4.0, bottom: 8.0),
          child: Text(
            'HOURLY FORECAST',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
              color: Colors.white70,
            ),
          ),
        ),
        SizedBox(
          height: 125,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: weather.hourlyForecast.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final item = weather.hourlyForecast[index];
              return GlassContainer(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      item.time,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white.withOpacity(0.8),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Icon(
                      _getWeatherIcon(item.condition),
                      color: Colors.amberAccent,
                      size: 26,
                    ),
                    Text(
                      '${item.temp.round()}°',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDailyForecast(WeatherModel? weather) {
    if (weather == null || weather.dailyForecast.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4.0, bottom: 8.0),
          child: Text(
            '7-DAY CLIMATE OUTLOOK',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
              color: Colors.white70,
            ),
          ),
        ),
        GlassContainer(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Column(
            children: weather.dailyForecast.map((day) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  children: [
                    SizedBox(
                      width: 70,
                      child: Text(
                        day.dayName,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Icon(
                      _getWeatherIcon(day.condition),
                      color: Colors.amberAccent,
                      size: 22,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        day.condition,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white.withOpacity(0.7),
                        ),
                      ),
                    ),
                    Text(
                      '${day.minTemp.round()}°',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.6),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Visual temperature bar
                    Container(
                      width: 50,
                      height: 5,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF00D2FF), Colors.orangeAccent],
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${day.maxTemp.round()}°',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
