import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/weather_model.dart';
import '../models/weather_report_model.dart';

class WeatherApiService {
  // Base URL for the companion Node.js REST API backend
  // When testing on Android Emulator, 10.0.2.2 points to host machine localhost:5000.
  // For physical device, change to your machine's LAN IP (e.g., http://192.168.1.100:5000)
  static const String backendBaseUrl = 'http://10.0.2.2:5000/api';

  // In-memory fallback reports for instant demo when backend is offline
  static final List<WeatherReportModel> _localReports = [
    WeatherReportModel(
      id: 'rep-1',
      city: 'Mumbai',
      temperature: 30.5,
      condition: 'Sunny',
      notes: 'Clear blue skies near Marine Drive with sea breeze.',
      imageUrl: 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=800',
      author: 'Aarav Sharma',
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    WeatherReportModel(
      id: 'rep-2',
      city: 'London',
      temperature: 14.2,
      condition: 'Rainy',
      notes: 'Light drizzle and overcast conditions across Westminster.',
      imageUrl: 'https://images.unsplash.com/photo-1515694346937-94d85e41e6f0?w=800',
      author: 'Elena Vance',
      createdAt: DateTime.now().subtract(const Duration(hours: 5)),
    ),
  ];

  // Map weather codes from WMO (World Meteorological Organization)
  static Map<String, dynamic> _parseWmoCode(int code, int isDay) {
    if (code == 0) {
      return {
        'condition': isDay == 1 ? 'Sunny' : 'Clear',
        'desc': isDay == 1 ? 'Clear Sunny Sky' : 'Clear Night Sky',
        'icon': isDay == 1 ? '01d' : '01n',
      };
    } else if (code <= 3) {
      return {
        'condition': 'Cloudy',
        'desc': 'Partly cloudy with scattered sunshine',
        'icon': isDay == 1 ? '02d' : '02n',
      };
    } else if (code <= 48) {
      return {
        'condition': 'Foggy',
        'desc': 'Dense atmospheric fog and mist',
        'icon': '50d',
      };
    } else if (code <= 67) {
      return {
        'condition': 'Rainy',
        'desc': 'Showers with precipitation',
        'icon': '10d',
      };
    } else if (code <= 77) {
      return {
        'condition': 'Snowy',
        'desc': 'Light snow flurries',
        'icon': '13d',
      };
    } else if (code <= 99) {
      return {
        'condition': 'Thunderstorm',
        'desc': 'Severe storm with lightning & heavy rain',
        'icon': '11d',
      };
    }
    return {'condition': 'Clear', 'desc': 'Pleasant conditions', 'icon': '01d'};
  }

  // City Coordinates database for instant, key-free lookup
  static const Map<String, Map<String, double>> _cityCoords = {
    'mumbai': {'lat': 19.0760, 'lon': 72.8777},
    'delhi': {'lat': 28.6139, 'lon': 77.2090},
    'bengaluru': {'lat': 12.9716, 'lon': 77.5946},
    'london': {'lat': 51.5074, 'lon': -0.1278},
    'new york': {'lat': 40.7128, 'lon': -74.0060},
    'tokyo': {'lat': 35.6762, 'lon': 139.6503},
    'paris': {'lat': 48.8566, 'lon': 2.3522},
    'dubai': {'lat': 25.2048, 'lon': 55.2708},
    'sydney': {'lat': -33.8688, 'lon': 151.2093},
    'singapore': {'lat': 1.3521, 'lon': 103.8198},
  };

  static String _formatTime(String? iso, String fallback) {
    if (iso == null || !iso.contains('T')) return fallback;
    try {
      final parts = iso.split('T').last.split(':');
      int hour = int.parse(parts[0]);
      final minute = parts[1];
      final period = hour >= 12 ? 'PM' : 'AM';
      if (hour > 12) hour -= 12;
      if (hour == 0) hour = 12;
      return '${hour.toString().padLeft(2, '0')}:$minute $period';
    } catch (_) {
      return fallback;
    }
  }

  /// REST GET: Fetch Live Weather by City
  Future<WeatherModel> fetchWeather(String cityName) async {
    final query = cityName.trim().toLowerCase();
    double lat = 19.0760;
    double lon = 72.8777;
    String countryCode = 'IN';

    if (_cityCoords.containsKey(query)) {
      lat = _cityCoords[query]!['lat']!;
      lon = _cityCoords[query]!['lon']!;
    } else {
      // Dynamic geocoding via Open-Meteo Geocoding REST API
      try {
        final geoUrl = Uri.parse(
          'https://geocoding-api.open-meteo.com/v1/search?name=${Uri.encodeComponent(cityName)}&count=1&language=en&format=json',
        );
        final geoRes = await http.get(geoUrl).timeout(const Duration(seconds: 4));
        if (geoRes.statusCode == 200) {
          final geoData = jsonDecode(geoRes.body);
          if (geoData['results'] != null && (geoData['results'] as List).isNotEmpty) {
            final first = geoData['results'][0];
            lat = (first['latitude'] as num).toDouble();
            lon = (first['longitude'] as num).toDouble();
            countryCode = first['country_code']?.toString().toUpperCase() ?? 'IN';
          }
        }
      } catch (_) {
        // Fallback to default coordinates
      }
    }

    try {
      final weatherUrl = Uri.parse(
        'https://api.open-meteo.com/v1/forecast?latitude=$lat&longitude=$lon'
        '&current_weather=true&hourly=temperature_2m,relativehumidity_2m,weathercode'
        '&daily=weathercode,temperature_2m_max,temperature_2m_min,sunrise,sunset,uv_index_max'
        '&timezone=auto',
      );

      final response = await http.get(weatherUrl).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final current = data['current_weather'];
        final daily = data['daily'];
        final hourly = data['hourly'];

        final code = (current['weathercode'] as num).toInt();
        final isDay = (current['is_day'] as num?)?.toInt() ?? 1;
        final wmo = _parseWmoCode(code, isDay);

        // Parse hourly forecast (first 12 hours)
        List<HourlyForecast> hourlyList = [];
        int liveHumidity = 65;
        if (hourly != null && hourly['time'] != null) {
          final times = hourly['time'] as List;
          final temps = hourly['temperature_2m'] as List;
          final codes = hourly['weathercode'] as List;
          final hums = hourly['relativehumidity_2m'] as List?;

          if (hums != null && hums.isNotEmpty) {
            liveHumidity = (hums[0] as num).toInt();
          }

          for (int i = 0; i < 12 && i < times.length; i++) {
            final tStr = times[i].toString().split('T').last;
            final tCode = (codes[i] as num).toInt();
            final tWmo = _parseWmoCode(tCode, 1);
            hourlyList.add(HourlyForecast(
              time: tStr,
              temp: (temps[i] as num).toDouble(),
              condition: tWmo['condition'],
              iconCode: tWmo['icon'],
            ));
          }
        }

        // Parse 7-day forecast
        List<DailyForecast> dailyList = [];
        String liveSunrise = '06:15 AM';
        String liveSunset = '06:45 PM';
        double liveUv = 6.0;

        if (daily != null && daily['time'] != null) {
          final dTimes = daily['time'] as List;
          final maxTemps = daily['temperature_2m_max'] as List;
          final minTemps = daily['temperature_2m_min'] as List;
          final dCodes = daily['weathercode'] as List;
          final sunrises = daily['sunrise'] as List?;
          final sunsets = daily['sunset'] as List?;
          final uvs = daily['uv_index_max'] as List?;

          if (sunrises != null && sunrises.isNotEmpty) {
            liveSunrise = _formatTime(sunrises[0]?.toString(), '06:15 AM');
          }
          if (sunsets != null && sunsets.isNotEmpty) {
            liveSunset = _formatTime(sunsets[0]?.toString(), '06:45 PM');
          }
          if (uvs != null && uvs.isNotEmpty) {
            liveUv = (uvs[0] as num).toDouble();
          }

          final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

          for (int i = 0; i < dTimes.length && i < 7; i++) {
            final dateObj = DateTime.tryParse(dTimes[i].toString()) ?? DateTime.now();
            final dayName = i == 0 ? 'Today' : days[dateObj.weekday - 1];
            final dCode = (dCodes[i] as num).toInt();
            final dWmo = _parseWmoCode(dCode, 1);

            dailyList.add(DailyForecast(
              dayName: dayName,
              date: '${dateObj.day}/${dateObj.month}',
              maxTemp: (maxTemps[i] as num).toDouble(),
              minTemp: (minTemps[i] as num).toDouble(),
              condition: dWmo['condition'],
              iconCode: dWmo['icon'],
            ));
          }
        }

        final double currentTemp = (current['temperature'] as num).toDouble();
        final double wind = (current['windspeed'] as num).toDouble();

        return WeatherModel(
          city: cityName.toUpperCase(),
          country: countryCode,
          temperature: currentTemp,
          feelsLike: (currentTemp + (liveHumidity > 70 ? 2.5 : 1.0)).clamp(currentTemp - 2, currentTemp + 5),
          condition: wmo['condition'],
          description: wmo['desc'],
          iconCode: wmo['icon'],
          humidity: liveHumidity,
          windSpeed: wind,
          pressure: 1012,
          uvIndex: liveUv,
          sunrise: liveSunrise,
          sunset: liveSunset,
          aqi: 48,
          hourlyForecast: hourlyList,
          dailyForecast: dailyList,
        );
      }
    } catch (_) {
      // Return sample weather if offline or timed out
    }
    return WeatherModel.sample(cityName: cityName);
  }

  // ==========================================
  // BACKEND REST API CRUD OPERATIONS (PRACTICAL 12)
  // ==========================================

  /// REST GET: Retrieve all weather reports (/api/reports)
  Future<List<WeatherReportModel>> fetchReports() async {
    try {
      final res = await http.get(Uri.parse('$backendBaseUrl/reports')).timeout(const Duration(seconds: 3));
      if (res.statusCode == 200) {
        final List<dynamic> data = jsonDecode(res.body);
        return data.map((json) => WeatherReportModel.fromJson(json)).toList();
      }
    } catch (_) {
      // Fallback to local demo storage
    }
    return List.from(_localReports);
  }

  /// REST POST: Submit a new weather report with Firebase Storage Image URL
  Future<WeatherReportModel> createReport(WeatherReportModel report) async {
    try {
      final res = await http.post(
        Uri.parse('$backendBaseUrl/reports'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(report.toJson()),
      ).timeout(const Duration(seconds: 3));

      if (res.statusCode == 201 || res.statusCode == 200) {
        return WeatherReportModel.fromJson(jsonDecode(res.body));
      }
    } catch (_) {
      // Local fallback
    }
    _localReports.insert(0, report);
    return report;
  }

  /// REST PUT: Update an existing weather report (/api/reports/:id)
  Future<bool> updateReport(WeatherReportModel report) async {
    try {
      final res = await http.put(
        Uri.parse('$backendBaseUrl/reports/${report.id}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(report.toJson()),
      ).timeout(const Duration(seconds: 3));

      if (res.statusCode == 200) return true;
    } catch (_) {
      // Local fallback
    }
    final index = _localReports.indexWhere((r) => r.id == report.id);
    if (index != -1) {
      _localReports[index] = report;
      return true;
    }
    return false;
  }

  /// REST DELETE: Remove a weather report (/api/reports/:id)
  Future<bool> deleteReport(String id) async {
    try {
      final res = await http.delete(
        Uri.parse('$backendBaseUrl/reports/$id'),
      ).timeout(const Duration(seconds: 3));

      if (res.statusCode == 200) return true;
    } catch (_) {
      // Local fallback
    }
    _localReports.removeWhere((r) => r.id == id);
    return true;
  }
}
