import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/campus_location.dart';
import '../models/echo.dart';
import '../models/echo_category.dart';
import '../models/echo_severity.dart';
import '../models/location_category.dart';
import '../services/health_service.dart';
import '../services/summary_service.dart';
import 'built_in_locations.dart';
import 'sample_data.dart';

/// In-memory Echo + location store, backed by shared_preferences for local
/// persistence. Swap the persistence calls for a real backend later without
/// changing screens — they only ever talk to this repository's public API.
class EchoRepository extends ChangeNotifier {
  EchoRepository({
    HealthService healthService = const HealthService(),
    SummaryService summaryService = const SummaryService(),
    List<Echo>? seed,
    List<CampusLocation>? locationSeed,
  })  : _healthService = healthService,
        _summaryService = summaryService,
        _echoes = List<Echo>.from(seed ?? createSampleEchoes()),
        _locations = List<CampusLocation>.from(locationSeed ?? BuiltInLocations.all()) {
    _pendingHydrate = _hydrate();
  }

  /// shared_preferences keys. Bumping a version suffix lets a future format
  /// change ignore old data cleanly instead of crashing on it.
  static const _echoesKey = 'echo_campus.echoes.v1';
  static const _locationsKey = 'echo_campus.locations.v1';
  static const _favoritesKey = 'echo_campus.favorite_locations.v1';

  final HealthService _healthService;
  final SummaryService _summaryService;
  final List<Echo> _echoes;
  final List<CampusLocation> _locations;
  final Set<String> _favoriteLocationIds = {};

  Future<void>? _pendingHydrate;
  Future<void>? _pendingWrite;

  /// Resolves once the initial load from local storage (if any) has been
  /// applied. Screens don't need this — the sample data is already showing
  /// by the first frame — but tests use it to wait for hydration to settle.
  @visibleForTesting
  Future<void>? get pendingHydrate => _pendingHydrate;

  /// Resolves once the most recent save to local storage has completed.
  /// Exposed for tests that need to assert persisted state deterministically.
  @visibleForTesting
  Future<void>? get pendingWrite => _pendingWrite;

  bool largeText = false;

  List<Echo> get echoes => List.unmodifiable(_echoes);

  List<Echo> get activeEchoes =>
      _echoes.where((echo) => !echo.resolved).toList();

  List<Echo> get resolvedEchoes =>
      _echoes.where((echo) => echo.resolved).toList();

  List<Echo> activeFor(CampusLocation location) => activeEchoes
      .where((echo) => echo.location == location)
      .toList();

  List<Echo> resolvedFor(CampusLocation location) => resolvedEchoes
      .where((echo) => echo.location == location)
      .toList();

  /// All echoes (active + resolved) for a location, newest first — the full
  /// history shown on the location detail screen.
  List<Echo> historyFor(CampusLocation location) {
    final matches = _echoes.where((echo) => echo.location == location).toList();
    matches.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return matches;
  }

  HealthSnapshot healthFor(CampusLocation location) =>
      _healthService.forEchoes(activeFor(location));

  String briefingFor(CampusLocation location) => _summaryService.summarize(
        location: location,
        activeEchoes: activeFor(location),
        resolvedEchoes: resolvedFor(location),
      );

  String get campusInsight {
    CampusLocation? hottest;
    var lowest = 101;
    for (final location in _locations) {
      final score = healthFor(location).score;
      if (score < lowest) {
        lowest = score;
        hottest = location;
      }
    }
    return _summaryService.campusInsight(
      activeEchoes: activeEchoes,
      hottestLocation: lowest < 75 ? hottest : null,
    );
  }

  // ---- Locations -----------------------------------------------------

  List<CampusLocation> get locations => List.unmodifiable(_locations);

  CampusLocation? locationById(String id) {
    for (final location in _locations) {
      if (location.id == id) return location;
    }
    return null;
  }

  /// Adds a new, user-created campus location (e.g. "CSE Lab 305").
  CampusLocation addLocation({
    required String name,
    required String building,
    required LocationCategory category,
    String? floor,
  }) {
    final location = CampusLocation(
      id: 'loc-${DateTime.now().microsecondsSinceEpoch}',
      name: name.trim(),
      building: building.trim(),
      floor: (floor == null || floor.trim().isEmpty) ? null : floor.trim(),
      category: category,
    );
    _locations.add(location);
    notifyListeners();
    _pendingWrite = _persistLocations();
    return location;
  }

  // ---- Favourites -------------------------------------------------------

  bool isFavorite(CampusLocation location) => _favoriteLocationIds.contains(location.id);

  List<CampusLocation> get favoriteLocations =>
      _locations.where((location) => _favoriteLocationIds.contains(location.id)).toList();

  void toggleFavorite(CampusLocation location) {
    if (!_favoriteLocationIds.add(location.id)) {
      _favoriteLocationIds.remove(location.id);
    }
    notifyListeners();
    _pendingWrite = _persistFavorites();
  }

  // ---- Echo mutations -----------------------------------------------------

  /// Confirms an Echo is "still true": bumps its base confidence and, just
  /// as importantly, resets its decay clock (lastConfirmedAt = now) so its
  /// reliability jumps back up and it reads as Fresh again.
  Echo confirmStillTrue(String id) {
    final index = _indexOf(id);
    final current = _echoes[index];
    final updated = current.copyWith(
      confidence: (current.confidence + 5).clamp(0, 100),
      confirmations: current.confirmations + 1,
      lastConfirmedAt: DateTime.now(),
    );
    _echoes[index] = updated;
    notifyListeners();
    _pendingWrite = _persistEchoes();
    return updated;
  }

  Echo markResolved(String id) {
    final index = _indexOf(id);
    final updated = _echoes[index].copyWith(resolved: true, resolvedAt: DateTime.now());
    _echoes[index] = updated;
    notifyListeners();
    _pendingWrite = _persistEchoes();
    return updated;
  }

  Echo addEcho({
    required String title,
    required String description,
    required EchoCategory category,
    required CampusLocation location,
    EchoSeverity? severity,
  }) {
    final now = DateTime.now();
    final echo = Echo(
      id: 'echo-${now.microsecondsSinceEpoch}',
      title: title.trim(),
      description: description.trim(),
      category: category,
      location: location,
      confidence: 62,
      confirmations: 1,
      createdAt: now,
      lastConfirmedAt: now,
      severity: severity,
    );
    _echoes.insert(0, echo);
    notifyListeners();
    _pendingWrite = _persistEchoes();
    return echo;
  }

  void toggleLargeText() {
    largeText = !largeText;
    notifyListeners();
  }

  int _indexOf(String id) => _echoes.indexWhere((echo) => echo.id == id);

  // ---- Persistence -----------------------------------------------------

  /// Loads any previously-saved Echoes/locations/favorites from disk,
  /// replacing the sample data this repository was constructed with. On
  /// first launch (nothing saved yet) the sample data stays and is
  /// persisted as the new baseline.
  Future<void> _hydrate() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final rawLocations = prefs.getString(_locationsKey);
      if (rawLocations != null) {
        final decoded = jsonDecode(rawLocations) as List<dynamic>;
        final loaded = decoded
            .map((item) => CampusLocation.fromJson(item as Map<String, dynamic>))
            .toList();
        _locations
          ..clear()
          ..addAll(loaded);
      }

      final rawEchoes = prefs.getString(_echoesKey);
      if (rawEchoes != null) {
        final decoded = jsonDecode(rawEchoes) as List<dynamic>;
        final loaded = decoded
            .map((item) => Echo.fromJson(item as Map<String, dynamic>))
            .toList();
        _echoes
          ..clear()
          ..addAll(loaded);
      }

      final rawFavorites = prefs.getStringList(_favoritesKey);
      if (rawFavorites != null) {
        _favoriteLocationIds
          ..clear()
          ..addAll(rawFavorites);
      }

      notifyListeners();
    } catch (_) {
      // Corrupt or unreadable local data: keep the sample data already
      // loaded in memory rather than crashing the app.
    }
    _pendingWrite = Future.wait([_persistEchoes(), _persistLocations(), _persistFavorites()]);
  }

  Future<void> _persistEchoes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encoded = jsonEncode(_echoes.map((echo) => echo.toJson()).toList());
      await prefs.setString(_echoesKey, encoded);
    } catch (_) {
      // Best-effort persistence: a save failure should never crash the UI.
    }
  }

  Future<void> _persistLocations() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encoded = jsonEncode(_locations.map((location) => location.toJson()).toList());
      await prefs.setString(_locationsKey, encoded);
    } catch (_) {
      // Best-effort persistence: a save failure should never crash the UI.
    }
  }

  Future<void> _persistFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_favoritesKey, _favoriteLocationIds.toList());
    } catch (_) {
      // Best-effort persistence: a save failure should never crash the UI.
    }
  }
}
