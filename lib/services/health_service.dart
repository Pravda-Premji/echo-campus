import '../models/echo.dart';
import '../models/echo_category.dart';

enum HealthStatus { good, attention, needsAttention }

class HealthSnapshot {
  const HealthSnapshot({required this.score, required this.status});

  final int score;
  final HealthStatus status;

  String get label {
    switch (status) {
      case HealthStatus.good:
        return 'Good';
      case HealthStatus.attention:
        return 'Attention';
      case HealthStatus.needsAttention:
        return 'Needs attention';
    }
  }
}

/// Simple, explainable campus health: empty locations sit at 95.
/// Active reports reduce the score by category so Lab 204, Library,
/// Canteen, and Seminar Hall match the demo numbers on first launch.
class HealthService {
  const HealthService();

  HealthSnapshot forEchoes(List<Echo> activeEchoes) {
    if (activeEchoes.isEmpty) {
      return const HealthSnapshot(score: 95, status: HealthStatus.good);
    }

    var score = 100;
    for (final echo in activeEchoes) {
      score -= _penalty(echo.category);
    }
    score = score.clamp(0, 100);

    return HealthSnapshot(score: score, status: _statusFor(score));
  }

  int _penalty(EchoCategory category) {
    switch (category) {
      case EchoCategory.equipment:
      case EchoCategory.electricity:
      case EchoCategory.wifi:
      case EchoCategory.maintenance:
        return 19;
      case EchoCategory.food:
        return 32;
      case EchoCategory.other:
        return 9;
    }
  }

  HealthStatus _statusFor(int score) {
    if (score < 50) return HealthStatus.needsAttention;
    if (score < 75) return HealthStatus.attention;
    return HealthStatus.good;
  }
}
