import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/weather_model.dart';
import '../models/weather_report_model.dart';
import '../services/weather_api_service.dart';
import '../services/firebase_service.dart';
import '../services/local_storage_service.dart';

class WeatherProvider with ChangeNotifier {
  final WeatherApiService _apiService = WeatherApiService();

  WeatherModel? _currentWeather;
  bool _isLoading = false;
  bool _isUploading = false;
  String? _errorMessage;
  String _currentCity = 'Mumbai';

  List<String> _savedCities = [];
  List<String> _searchHistory = [];
  List<WeatherReportModel> _communityReports = [];

  // Getters
  WeatherModel? get currentWeather => _currentWeather;
  bool get isLoading => _isLoading;
  bool get isUploading => _isUploading;
  String? get errorMessage => _errorMessage;
  String get currentCity => _currentCity;
  List<String> get savedCities => _savedCities;
  List<String> get searchHistory => _searchHistory;
  List<WeatherReportModel> get communityReports => _communityReports;

  WeatherProvider() {
    init();
  }

  /// Initialize state and load persisted data from on-device storage
  Future<void> init() async {
    // 1. Read last selected city and saved cities from device local storage
    _currentCity = await LocalStorageService.getLastSelectedCity();
    _savedCities = await LocalStorageService.getSavedCities();
    _searchHistory = await LocalStorageService.getSearchHistory();
    notifyListeners();

    // 2. Fetch live weather for the persisted city
    await fetchWeatherData(_currentCity);

    // 3. Load reports
    await fetchCommunityReports();
  }

  /// Fetch live weather from REST API and persist active city to device
  Future<void> fetchWeatherData(String city) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final weather = await _apiService.fetchWeather(city);
      _currentWeather = weather;
      _currentCity = city;

      // Persist to local device storage
      await LocalStorageService.setLastSelectedCity(city);
      await LocalStorageService.addToSearchHistory(city);
      _searchHistory = await LocalStorageService.getSearchHistory();
    } catch (e) {
      _errorMessage = 'Failed to load weather: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Refresh weather for the current city
  Future<void> refreshWeather() async {
    await fetchWeatherData(_currentCity);
  }

  /// Add city to on-device persistent favorites
  Future<void> addSavedCity(String city) async {
    final cleanCity = city.trim();
    if (cleanCity.isEmpty) return;

    if (!_savedCities.any((c) => c.toLowerCase() == cleanCity.toLowerCase())) {
      _savedCities.insert(0, cleanCity);
      notifyListeners();
      await LocalStorageService.saveCity(cleanCity);
    }
  }

  /// Remove city from on-device persistent storage
  Future<void> removeSavedCity(String city) async {
    _savedCities.removeWhere((c) => c.toLowerCase() == city.trim().toLowerCase());
    notifyListeners();
    await LocalStorageService.removeCity(city);
  }

  /// Check if a city is currently saved on device
  bool isCitySaved(String city) {
    return _savedCities.any((c) => c.toLowerCase() == city.trim().toLowerCase());
  }

  // ==========================================
  // COMMUNITY WEATHER REPORTS (REST CRUD + FIREBASE)
  // ==========================================

  Future<void> fetchCommunityReports() async {
    try {
      final reports = await _apiService.fetchReports();
      _communityReports = reports;
      notifyListeners();
    } catch (e) {
      debugPrint('[WeatherProvider] Error fetching reports: $e');
    }
  }

  Future<bool> submitWeatherReport({
    required String city,
    required double temperature,
    required String condition,
    required String notes,
    required String author,
    XFile? pickedImage,
  }) async {
    _isUploading = true;
    notifyListeners();

    try {
      String imageUrl = 'https://images.unsplash.com/photo-1534088568595-a066f410bcda?w=800';

      if (pickedImage != null) {
        imageUrl = await FirebaseService.uploadWeatherImage(pickedImage);
      }

      final newReport = WeatherReportModel(
        id: 'rep_${DateTime.now().millisecondsSinceEpoch}',
        city: city,
        temperature: temperature,
        condition: condition,
        notes: notes,
        imageUrl: imageUrl,
        author: author.isEmpty ? 'Observer' : author,
        createdAt: DateTime.now(),
      );

      final created = await _apiService.createReport(newReport);
      _communityReports.insert(0, created);
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('[WeatherProvider] Submit error: $e');
      return false;
    } finally {
      _isUploading = false;
      notifyListeners();
    }
  }

  Future<bool> updateWeatherReport(WeatherReportModel report) async {
    try {
      final success = await _apiService.updateReport(report);
      if (success) {
        final index = _communityReports.indexWhere((r) => r.id == report.id);
        if (index != -1) {
          _communityReports[index] = report;
          notifyListeners();
        }
      }
      return success;
    } catch (e) {
      debugPrint('[WeatherProvider] Update error: $e');
      return false;
    }
  }

  Future<bool> deleteWeatherReport(String id) async {
    try {
      final success = await _apiService.deleteReport(id);
      if (success) {
        _communityReports.removeWhere((r) => r.id == id);
        notifyListeners();
      }
      return success;
    } catch (e) {
      debugPrint('[WeatherProvider] Delete error: $e');
      return false;
    }
  }
}
