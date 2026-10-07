import 'package:flutter/cupertino.dart';

class WeatherReportModel {
  final String id;
  final String city;
  final double temperature;
  final String condition;
  final String notes;
  final String imageUrl;
  final String author;
  final DateTime createdAt;

  WeatherReportModel({
    required this.id,
    required this.city,
    required this.temperature,
    required this.condition,
    required this.notes,
    required this.imageUrl,
    required this.author,
    required this.createdAt,
  });

  factory WeatherReportModel.fromJson(Map<String, dynamic> json) {
    return WeatherReportModel(
      id: json['id']?.toString() ?? UniqueKey().toString(),
      city: json['city'] ?? '',
      temperature: (json['temperature'] as num?)?.toDouble() ?? 0.0,
      condition: json['condition'] ?? 'Clear',
      notes: json['notes'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      author: json['author'] ?? 'Anonymous Observer',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'city': city,
      'temperature': temperature,
      'condition': condition,
      'notes': notes,
      'imageUrl': imageUrl,
      'author': author,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  WeatherReportModel copyWith({
    String? id,
    String? city,
    double? temperature,
    String? condition,
    String? notes,
    String? imageUrl,
    String? author,
    DateTime? createdAt,
  }) {
    return WeatherReportModel(
      id: id ?? this.id,
      city: city ?? this.city,
      temperature: temperature ?? this.temperature,
      condition: condition ?? this.condition,
      notes: notes ?? this.notes,
      imageUrl: imageUrl ?? this.imageUrl,
      author: author ?? this.author,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
