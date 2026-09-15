import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/campus_location.dart';
import '../models/echo.dart';
import '../models/echo_category.dart';
import '../services/health_service.dart';
import '../services/summary_service.dart';
import 'sample_data.dart';

/// In-memory Echo store, backed by shared_preferences for local persistence.
/// Swap the persistence calls for Firebase later without changing screens —
/// they only ever talk to this repository's public API.
class EchoRepository extends ChangeNotifier {
  EchoRepository({
    HealthService healthService = const HealthService(),
    SummaryService summaryService = const SummaryService(),
    List<Echo>? seed,
  })  : _healthService = healthService,
        _summaryService = summaryService,
        _echoes = List<Echo>.from(seed ?? createSampleEchoes()) {
    _pendingHydrate = _hydrate();
  }

  /// shared_preferences key holding the JSON-encoded Echo list. Bumping the
  /// version suffix lets a future format change ignore old data cleanly.
  static const _storageKey = 'echo_campus.echoes.v1';

  final HealthService _healthService;
  final SummaryService _summaryService;
  final List<Echo> _echoes;

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

  HealthSnapshot healthFor(CampusLocation location) =>
      _healthService.forEchoes(activeFor(location));

  String briefingFor(CampusLocation location) => _summaryService.summarize(
        location: location,
        activeEchoes: activeFor(location),
      );

  String get campusInsight {
    CampusLocation? hottest;
    var lowest = 101;
    for (final location in CampusLocation.values) {
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
    _pendingWrite = _persist();
    return updated;
  }

  Echo markResolved(String id) {
    final index = _indexOf(id);
    final updated = _echoes[index].copyWith(resolved: true);
    _echoes[index] = updated;
    notifyListeners();
    _pendingWrite = _persist();
    return updated;
  }

  Echo addEcho({
    required String title,
    required String description,
    required EchoCategory category,
    required CampusLocation location,
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
    );
    _echoes.insert(0, echo);
    notifyListeners();
    _pendingWrite = _persist();
    return echo;
  }

  void toggleLargeText() {
    largeText = !largeText;
    notifyListeners();
  }

  int _indexOf(String id) => _echoes.indexWhere((echo) => echo.id == id);

  /// Loads any previously-saved Echoes from disk, replacing the sample data
  /// this repository was constructed with. On first launch (nothing saved
  /// yet) the sample data stays and is persisted as the new baseline.
  Future<void> _hydrate() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_storageKey);
      if (raw != null) {
        final decoded = jsonDecode(raw) as List<dynamic>;
        final loaded = decoded
            .map((item) => Echo.fromJson(item as Map<String, dynamic>))
            .toList();
        _echoes
          ..clear()
          ..addAll(loaded);
        notifyListeners();
      }
    } catch (_) {
      // Corrupt or unreadable local data: keep the sample data already
      // loaded in memory rather than crashing the app.
    }
    _pendingWrite = _persist();
  }

  Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encoded = jsonEncode(_echoes.map((echo) => echo.toJson()).toList());
      await prefs.setString(_storageKey, encoded);
    } catch (_) {
      // Best-effort persistence: a save failure should never crash the UI.
    }
  }
}
