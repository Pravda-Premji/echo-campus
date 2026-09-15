import 'package:flutter/material.dart';

import 'location_category.dart';

/// A place on campus students can post Echoes about. Users can add their own
/// locations at runtime (e.g. "CSE Lab 305") alongside the four built-in
/// demo locations — this is a plain, persisted value object rather than an
/// enum so the list can grow.
///
/// Two [CampusLocation]s are equal when their [id] matches, so existing code
/// that compares locations with `==` (filtering Echoes by location, matching
/// a dropdown's selected value) keeps working whether the location came from
/// the built-in list or was added by a user.
class CampusLocation {
  const CampusLocation({
    required this.id,
    required this.name,
    required this.building,
    required this.category,
    this.floor,
    this.isBuiltIn = false,
  });

  final String id;
  final String name;
  final String building;
  final LocationCategory category;
  final String? floor;
  final bool isBuiltIn;

  String get label => name;

  String get labelUpper => name.toUpperCase();

  IconData get icon => category.icon;

  String get shortHint {
    final parts = [building, if (floor != null && floor!.isNotEmpty) 'Floor $floor'];
    return parts.join(' · ');
  }

  CampusLocation copyWith({
    String? id,
    String? name,
    String? building,
    LocationCategory? category,
    String? floor,
    bool? isBuiltIn,
  }) {
    return CampusLocation(
      id: id ?? this.id,
      name: name ?? this.name,
      building: building ?? this.building,
      category: category ?? this.category,
      floor: floor ?? this.floor,
      isBuiltIn: isBuiltIn ?? this.isBuiltIn,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'building': building,
        'category': category.name,
        'floor': floor,
        'isBuiltIn': isBuiltIn,
      };

  factory CampusLocation.fromJson(Map<String, dynamic> json) => CampusLocation(
        id: json['id'] as String,
        name: json['name'] as String,
        building: json['building'] as String,
        category: LocationCategory.values.byName(json['category'] as String),
        floor: json['floor'] as String?,
        isBuiltIn: json['isBuiltIn'] as bool? ?? false,
      );

  @override
  bool operator ==(Object other) => other is CampusLocation && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
