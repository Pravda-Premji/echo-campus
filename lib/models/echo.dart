import 'campus_location.dart';
import 'echo_category.dart';
import 'freshness.dart';

class Echo {
  const Echo({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.location,
    required this.confidence,
    required this.confirmations,
    required this.createdAt,
    this.resolved = false,
  });

  final String id;
  final String title;
  final String description;
  final EchoCategory category;
  final CampusLocation location;
  final int confidence;
  final int confirmations;
  final DateTime createdAt;
  final bool resolved;

  EchoFreshness freshness({DateTime? now}) =>
      freshnessFor(createdAt, now: now);

  Echo copyWith({
    String? id,
    String? title,
    String? description,
    EchoCategory? category,
    CampusLocation? location,
    int? confidence,
    int? confirmations,
    DateTime? createdAt,
    bool? resolved,
  }) {
    return Echo(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      location: location ?? this.location,
      confidence: confidence ?? this.confidence,
      confirmations: confirmations ?? this.confirmations,
      createdAt: createdAt ?? this.createdAt,
      resolved: resolved ?? this.resolved,
    );
  }
}
