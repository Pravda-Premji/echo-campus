import 'campus_location.dart';
import 'echo_category.dart';
import 'freshness.dart';

class Echo {
  Echo({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.location,
    required this.confidence,
    required this.confirmations,
    required this.createdAt,
    DateTime? lastConfirmedAt,
    this.resolved = false,
  }) : lastConfirmedAt = lastConfirmedAt ?? createdAt;

  final String id;
  final String title;
  final String description;
  final EchoCategory category;
  final CampusLocation location;

  /// The confidence recorded the last time this Echo was posted or
  /// confirmed. This is the starting point for [reliability] — it does not
  /// change with time on its own.
  final int confidence;
  final int confirmations;
  final DateTime createdAt;

  /// When this Echo was last confirmed as "still true". Starts equal to
  /// [createdAt] and resets every time someone taps "STILL TRUE". Decay is
  /// measured from this timestamp, not [createdAt], so a re-confirmed Echo
  /// is treated as freshly observed again.
  final DateTime lastConfirmedAt;
  final bool resolved;

  /// Fresh / Aging / Outdated, based on time since [lastConfirmedAt].
  EchoFreshness freshness({DateTime? now}) =>
      freshnessFor(lastConfirmedAt, now: now);

  /// The Echo's current trustworthiness: [confidence] decayed by time since
  /// [lastConfirmedAt]. See lib/models/freshness.dart for the formula.
  int reliability({DateTime? now}) =>
      reliabilityFor(confidence, lastConfirmedAt, now: now);

  Echo copyWith({
    String? id,
    String? title,
    String? description,
    EchoCategory? category,
    CampusLocation? location,
    int? confidence,
    int? confirmations,
    DateTime? createdAt,
    DateTime? lastConfirmedAt,
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
      lastConfirmedAt: lastConfirmedAt ?? this.lastConfirmedAt,
      resolved: resolved ?? this.resolved,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'category': category.name,
        'location': location.name,
        'confidence': confidence,
        'confirmations': confirmations,
        'createdAt': createdAt.toIso8601String(),
        'lastConfirmedAt': lastConfirmedAt.toIso8601String(),
        'resolved': resolved,
      };

  factory Echo.fromJson(Map<String, dynamic> json) {
    final createdAt = DateTime.parse(json['createdAt'] as String);
    final rawLastConfirmedAt = json['lastConfirmedAt'] as String?;
    return Echo(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      category: EchoCategory.values.byName(json['category'] as String),
      location: CampusLocation.values.byName(json['location'] as String),
      confidence: json['confidence'] as int,
      confirmations: json['confirmations'] as int,
      createdAt: createdAt,
      lastConfirmedAt:
          rawLastConfirmedAt != null ? DateTime.parse(rawLastConfirmedAt) : createdAt,
      resolved: json['resolved'] as bool? ?? false,
    );
  }
}
