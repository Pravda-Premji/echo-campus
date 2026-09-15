import '../models/echo.dart';
import '../models/freshness.dart';

enum AlertKind { lowReliability, highlyConfirmed, newUrgent, recentlyResolved }

class CampusAlert {
  const CampusAlert({
    required this.kind,
    required this.echo,
    required this.message,
  });

  final AlertKind kind;
  final Echo echo;
  final String message;
}

/// Surfaces a short, locally-computed list of things worth a student's
/// attention right now. Every alert is derived directly from Echo fields —
/// no push notifications, no external service.
class AlertsService {
  const AlertsService();

  static const _lowReliabilityThreshold = 20;
  static const _highlyConfirmedThreshold = 8;

  List<CampusAlert> alertsFor({
    required List<Echo> activeEchoes,
    required List<Echo> resolvedEchoes,
  }) {
    final alerts = <CampusAlert>[];

    for (final echo in activeEchoes) {
      if (echo.reliability() <= _lowReliabilityThreshold) {
        alerts.add(CampusAlert(
          kind: AlertKind.lowReliability,
          echo: echo,
          message: '"${echo.title}" at ${echo.location.label} is down to '
              '${echo.reliability()}% reliability — confirm it if it\'s still true, or let it fade.',
        ));
      }

      if (echo.confirmations >= _highlyConfirmedThreshold) {
        alerts.add(CampusAlert(
          kind: AlertKind.highlyConfirmed,
          echo: echo,
          message: '"${echo.title}" at ${echo.location.label} has been confirmed '
              '${echo.confirmations} times — this is a widely-seen issue.',
        ));
      }

      final isNew = DateTime.now().difference(echo.createdAt).inHours < 1;
      if (isNew && echo.freshness() == EchoFreshness.fresh) {
        alerts.add(CampusAlert(
          kind: AlertKind.newUrgent,
          echo: echo,
          message: '"${echo.title}" was just reported at ${echo.location.label}.',
        ));
      }
    }

    for (final echo in resolvedEchoes) {
      final resolvedAt = echo.resolvedAt;
      if (resolvedAt != null && DateTime.now().difference(resolvedAt).inHours < 6) {
        alerts.add(CampusAlert(
          kind: AlertKind.recentlyResolved,
          echo: echo,
          message: '"${echo.title}" at ${echo.location.label} was just marked resolved.',
        ));
      }
    }

    return alerts;
  }
}
