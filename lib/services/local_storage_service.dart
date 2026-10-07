import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service responsible for persisting city locations and user preferences
/// directly on the local Android / iOS device using SharedPreferences.
class LocalStorageService {
  static const String _keySavedCities = 'user_saved_cities';
  static const String _keyLastCity = 'user_last_selected_city';
  static const String _keySearchHistory = 'user_city_search_history';

  // Default fallback cities if storage is clean
  static const List<String> _defaultCities = [
    'Mumbai',
    'Delhi',
    'Bengaluru',
    'Pune',
    'Thane',
    'London',
    'Tokyo',
    'New York',
  ];

  /// Retrieve all cities saved locally on the device
  static Future<List<String>> getSavedCities() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String>? cities = prefs.getStringList(_keySavedCities);
      if (cities != null && cities.isNotEmpty) {
        return List<String>.from(cities);
      }
    } catch (e) {
      debugPrint('[LocalStorage] Error reading saved cities: $e');
    }
    return List<String>.from(_defaultCities);
  }

  /// Save a new city to the on-device persistent list
  static Future<bool> saveCity(String cityName) async {
    final cleanCity = cityName.trim();
    if (cleanCity.isEmpty) return false;

    try {
      final prefs = await SharedPreferences.getInstance();
      List<String> current = await getSavedCities();

      // Case-insensitive check
      if (!current.any((c) => c.toLowerCase() == cleanCity.toLowerCase())) {
        current.insert(0, cleanCity);
        await prefs.setStringList(_keySavedCities, current);
        debugPrint('[LocalStorage] Successfully saved city on device: $cleanCity');
        return true;
      }
    } catch (e) {
      debugPrint('[LocalStorage] Error saving city on device: $e');
    }
    return false;
  }

  /// Remove a city from the on-device list
  static Future<bool> removeCity(String cityName) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      List<String> current = await getSavedCities();

      current.removeWhere((c) => c.toLowerCase() == cityName.trim().toLowerCase());
      await prefs.setStringList(_keySavedCities, current);
      debugPrint('[LocalStorage] Removed city from device: $cityName');
      return true;
    } catch (e) {
      debugPrint('[LocalStorage] Error removing city from device: $e');
      return false;
    }
  }

  /// Check if a city is already stored on device
  static Future<bool> isCitySaved(String cityName) async {
    try {
      final current = await getSavedCities();
      return current.any((c) => c.toLowerCase() == cityName.trim().toLowerCase());
    } catch (_) {
      return false;
    }
  }

  /// Retrieve the last opened/selected city from device storage
  static Future<String> getLastSelectedCity() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final last = prefs.getString(_keyLastCity);
      if (last != null && last.isNotEmpty) {
        return last;
      }
    } catch (e) {
      debugPrint('[LocalStorage] Error reading last city: $e');
    }
    return 'Mumbai';
  }

  /// Persist the last opened city on the device
  static Future<void> setLastSelectedCity(String cityName) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyLastCity, cityName.trim());
      debugPrint('[LocalStorage] Stored last selected city: $cityName');
    } catch (e) {
      debugPrint('[LocalStorage] Error setting last city: $e');
    }
  }

  /// Retrieve recent search history on device
  static Future<List<String>> getSearchHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getStringList(_keySearchHistory) ?? [];
    } catch (_) {
      return [];
    }
  }

  /// Add a query to on-device search history
  static Future<void> addToSearchHistory(String query) async {
    final clean = query.trim();
    if (clean.isEmpty) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      List<String> history = prefs.getStringList(_keySearchHistory) ?? [];
      history.removeWhere((item) => item.toLowerCase() == clean.toLowerCase());
      history.insert(0, clean);
      if (history.length > 10) history = history.sublist(0, 10);
      await prefs.setStringList(_keySearchHistory, history);
    } catch (e) {
      debugPrint('[LocalStorage] Error saving search history: $e');
    }
  }
}
