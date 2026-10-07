class WeatherModel {
  final String city;
  final String country;
  final double temperature;
  final double feelsLike;
  final String condition;
  final String description;
  final String iconCode;
  final int humidity;
  final double windSpeed;
  final int pressure;
  final double uvIndex;
  final String sunrise;
  final String sunset;
  final int aqi; // Air Quality Index
  final List<HourlyForecast> hourlyForecast;
  final List<DailyForecast> dailyForecast;

  WeatherModel({
    required this.city,
    required this.country,
    required this.temperature,
    required this.feelsLike,
    required this.condition,
    required this.description,
    required this.iconCode,
    required this.humidity,
    required this.windSpeed,
    required this.pressure,
    required this.uvIndex,
    required this.sunrise,
    required this.sunset,
    this.aqi = 42,
    required this.hourlyForecast,
    required this.dailyForecast,
  });

  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    return WeatherModel(
      city: json['city'] ?? 'Unknown City',
      country: json['country'] ?? '',
      temperature: (json['temperature'] as num?)?.toDouble() ?? 0.0,
      feelsLike: (json['feelsLike'] as num?)?.toDouble() ?? 0.0,
      condition: json['condition'] ?? 'Clear',
      description: json['description'] ?? 'Clear sky',
      iconCode: json['iconCode'] ?? '01d',
      humidity: json['humidity'] ?? 50,
      windSpeed: (json['windSpeed'] as num?)?.toDouble() ?? 0.0,
      pressure: json['pressure'] ?? 1013,
      uvIndex: (json['uvIndex'] as num?)?.toDouble() ?? 5.0,
      sunrise: json['sunrise'] ?? '06:15 AM',
      sunset: json['sunset'] ?? '06:45 PM',
      aqi: json['aqi'] ?? 42,
      hourlyForecast: (json['hourlyForecast'] as List<dynamic>?)
              ?.map((item) => HourlyForecast.fromJson(item))
              .toList() ??
          [],
      dailyForecast: (json['dailyForecast'] as List<dynamic>?)
              ?.map((item) => DailyForecast.fromJson(item))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'city': city,
      'country': country,
      'temperature': temperature,
      'feelsLike': feelsLike,
      'condition': condition,
      'description': description,
      'iconCode': iconCode,
      'humidity': humidity,
      'windSpeed': windSpeed,
      'pressure': pressure,
      'uvIndex': uvIndex,
      'sunrise': sunrise,
      'sunset': sunset,
      'aqi': aqi,
      'hourlyForecast': hourlyForecast.map((e) => e.toJson()).toList(),
      'dailyForecast': dailyForecast.map((e) => e.toJson()).toList(),
    };
  }

  // Factory constructor for fallback / default presentation
  factory WeatherModel.sample({String cityName = 'Mumbai'}) {
    return WeatherModel(
      city: cityName,
      country: 'IN',
      temperature: 29.5,
      feelsLike: 32.0,
      condition: 'Sunny',
      description: 'Partly sunny with gentle breeze',
      iconCode: '01d',
      humidity: 68,
      windSpeed: 14.2,
      pressure: 1012,
      uvIndex: 7.4,
      sunrise: '06:22 AM',
      sunset: '06:48 PM',
      aqi: 58,
      hourlyForecast: [
        HourlyForecast(time: '12 PM', temp: 30.0, condition: 'Sunny', iconCode: '01d'),
        HourlyForecast(time: '1 PM', temp: 31.5, condition: 'Sunny', iconCode: '01d'),
        HourlyForecast(time: '2 PM', temp: 32.0, condition: 'Clear', iconCode: '01d'),
        HourlyForecast(time: '3 PM', temp: 31.0, condition: 'Cloudy', iconCode: '03d'),
        HourlyForecast(time: '4 PM', temp: 29.8, condition: 'Rainy', iconCode: '10d'),
        HourlyForecast(time: '5 PM', temp: 28.5, condition: 'Rainy', iconCode: '10d'),
        HourlyForecast(time: '6 PM', temp: 27.2, condition: 'Cloudy', iconCode: '03d'),
        HourlyForecast(time: '7 PM', temp: 26.5, condition: 'Clear', iconCode: '01n'),
      ],
      dailyForecast: [
        DailyForecast(dayName: 'Today', date: 'Oct 7', maxTemp: 32, minTemp: 25, condition: 'Sunny', iconCode: '01d'),
        DailyForecast(dayName: 'Thu', date: 'Oct 8', maxTemp: 31, minTemp: 24, condition: 'Rainy', iconCode: '10d'),
        DailyForecast(dayName: 'Fri', date: 'Oct 9', maxTemp: 30, minTemp: 24, condition: 'Thunderstorm', iconCode: '11d'),
        DailyForecast(dayName: 'Sat', date: 'Oct 10', maxTemp: 29, minTemp: 23, condition: 'Cloudy', iconCode: '03d'),
        DailyForecast(dayName: 'Sun', date: 'Oct 11', maxTemp: 33, minTemp: 25, condition: 'Sunny', iconCode: '01d'),
        DailyForecast(dayName: 'Mon', date: 'Oct 12', maxTemp: 32, minTemp: 25, condition: 'Sunny', iconCode: '01d'),
        DailyForecast(dayName: 'Tue', date: 'Oct 13', maxTemp: 30, minTemp: 24, condition: 'Rainy', iconCode: '10d'),
      ],
    );
  }
}

class HourlyForecast {
  final String time;
  final double temp;
  final String condition;
  final String iconCode;

  HourlyForecast({
    required this.time,
    required this.temp,
    required this.condition,
    required this.iconCode,
  });

  factory HourlyForecast.fromJson(Map<String, dynamic> json) {
    return HourlyForecast(
      time: json['time'] ?? '',
      temp: (json['temp'] as num?)?.toDouble() ?? 0.0,
      condition: json['condition'] ?? 'Clear',
      iconCode: json['iconCode'] ?? '01d',
    );
  }

  Map<String, dynamic> toJson() => {
    'time': time,
    'temp': temp,
    'condition': condition,
    'iconCode': iconCode,
  };
}

class DailyForecast {
  final String dayName;
  final String date;
  final double maxTemp;
  final double minTemp;
  final String condition;
  final String iconCode;

  DailyForecast({
    required this.dayName,
    required this.date,
    required this.maxTemp,
    required this.minTemp,
    required this.condition,
    required this.iconCode,
  });

  factory DailyForecast.fromJson(Map<String, dynamic> json) {
    return DailyForecast(
      dayName: json['dayName'] ?? '',
      date: json['date'] ?? '',
      maxTemp: (json['maxTemp'] as num?)?.toDouble() ?? 0.0,
      minTemp: (json['minTemp'] as num?)?.toDouble() ?? 0.0,
      condition: json['condition'] ?? 'Clear',
      iconCode: json['iconCode'] ?? '01d',
    );
  }

  Map<String, dynamic> toJson() => {
    'dayName': dayName,
    'date': date,
    'maxTemp': maxTemp,
    'minTemp': minTemp,
    'condition': condition,
    'iconCode': iconCode,
  };
}
