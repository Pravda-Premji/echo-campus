import 'package:flutter/foundation.dart';

import '../models/campus_location.dart';
import '../models/echo.dart';
import '../models/echo_category.dart';
import '../services/health_service.dart';
import '../services/summary_service.dart';
import 'sample_data.dart';

/// In-memory Echo store. Swap this later for Firebase without changing screens.
class EchoRepository extends ChangeNotifier {
  EchoRepository({
    HealthService healthService = const HealthService(),
    SummaryService summaryService = const SummaryService(),
    List<Echo>? seed,
  })  : _healthService = healthService,
        _summaryService = summaryService,
        _echoes = List<Echo>.from(seed ?? createSampleEchoes());

  final HealthService _healthService;
  final SummaryService _summaryService;
  final List<Echo> _echoes;

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

  Echo confirmStillTrue(String id) {
    final index = _indexOf(id);
    final current = _echoes[index];
    final updated = current.copyWith(
      confidence: (current.confidence + 5).clamp(0, 100),
      confirmations: current.confirmations + 1,
    );
    _echoes[index] = updated;
    notifyListeners();
    return updated;
  }

  Echo markResolved(String id) {
    final index = _indexOf(id);
    final updated = _echoes[index].copyWith(resolved: true);
    _echoes[index] = updated;
    notifyListeners();
    return updated;
  }

  Echo addEcho({
    required String title,
    required String description,
    required EchoCategory category,
    required CampusLocation location,
  }) {
    final echo = Echo(
      id: 'echo-${DateTime.now().microsecondsSinceEpoch}',
      title: title.trim(),
      description: description.trim(),
      category: category,
      location: location,
      confidence: 62,
      confirmations: 1,
      createdAt: DateTime.now(),
    );
    _echoes.insert(0, echo);
    notifyListeners();
    return echo;
  }

  void toggleLargeText() {
    largeText = !largeText;
    notifyListeners();
  }

  int _indexOf(String id) => _echoes.indexWhere((echo) => echo.id == id);
}
