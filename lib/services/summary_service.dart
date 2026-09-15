import '../models/campus_location.dart';
import '../models/echo.dart';
import '../models/echo_severity.dart';

/// Builds a short local briefing straight from the Echo data ECHO already
/// has on this device — no network call, no external model. Every sentence
/// here is generated from concrete fields (severity, confirmations,
/// reliability, freshness) so it stays honest about being a summary of
/// crowd reports, not a prediction.
class SummaryService {
  const SummaryService();

  String summarize({
    required CampusLocation location,
    required List<Echo> activeEchoes,
    List<Echo> resolvedEchoes = const [],
  }) {
    if (activeEchoes.isEmpty) {
      final resolved = _mostRecentlyResolved(resolvedEchoes);
      if (resolved != null) {
        return '${location.label} currently has no active observations. '
            '"${resolved.title}" was recently marked resolved here — '
            'conditions look calm right now.';
      }
      return '${location.label} currently has no active observations. '
          'Campus conditions here look calm — check back if something changes.';
    }

    final ranked = _byImportance(activeEchoes);
    final top = ranked.first;
    final rest = ranked.skip(1).toList();

    final buffer = StringBuffer()
      ..write('Most important right now: "${top.title}" — ${_lowerFirst(top.description)} ')
      ..write(
        '(${top.reliability()}% reliable, ${_confirmationsPhrase(top.confirmations)}, ${top.freshness().label.toLowerCase()}).',
      );

    if (rest.isNotEmpty) {
      final otherPhrase = rest.length == 1 ? '1 other active report' : '${rest.length} other active reports';
      buffer.write(' Also here: $otherPhrase — ');
      buffer.write(rest.map((echo) => '"${echo.title}" (${echo.reliability()}%)').join(', '));
      buffer.write('.');
    }

    final resolved = _mostRecentlyResolved(resolvedEchoes);
    if (resolved != null) {
      buffer.write(' "${resolved.title}" was recently marked resolved.');
    }

    return buffer.toString();
  }

  String campusInsight({
    required List<Echo> activeEchoes,
    required CampusLocation? hottestLocation,
  }) {
    if (activeEchoes.isEmpty) {
      return 'Campus is quiet right now. No active observations need attention.';
    }

    final counts = <String, int>{};
    for (final echo in activeEchoes) {
      counts[echo.category.label] = (counts[echo.category.label] ?? 0) + 1;
    }
    var topCategory = counts.entries.first;
    for (final entry in counts.entries) {
      if (entry.value > topCategory.value) topCategory = entry;
    }

    final locationBit = hottestLocation == null
        ? ''
        : ' ${hottestLocation.label} requires attention.';

    return '${topCategory.key}-related observations are currently the most '
        'reported category.$locationBit';
  }

  /// Orders active Echoes by what's most worth telling a student about
  /// first: higher student-assigned severity wins, ties broken by more
  /// confirmations (more people have seen and agreed with it), then by
  /// higher current reliability (a trustworthy report beats a decayed one).
  List<Echo> _byImportance(List<Echo> echoes) {
    final sorted = [...echoes];
    sorted.sort((a, b) {
      final severity = _severityRank(b.severity).compareTo(_severityRank(a.severity));
      if (severity != 0) return severity;
      final confirmations = b.confirmations.compareTo(a.confirmations);
      if (confirmations != 0) return confirmations;
      return b.reliability().compareTo(a.reliability());
    });
    return sorted;
  }

  int _severityRank(EchoSeverity? severity) {
    switch (severity) {
      case EchoSeverity.high:
        return 3;
      case EchoSeverity.medium:
        return 2;
      case EchoSeverity.low:
        return 1;
      case null:
        return 0;
    }
  }

  /// The most recently resolved Echo, if any were resolved in the last 24h
  /// — old resolutions aren't news anymore, so they're left out.
  Echo? _mostRecentlyResolved(List<Echo> resolvedEchoes) {
    final recent = resolvedEchoes.where((echo) {
      final resolvedAt = echo.resolvedAt;
      if (resolvedAt == null) return false;
      return DateTime.now().difference(resolvedAt).inHours < 24;
    }).toList();
    if (recent.isEmpty) return null;
    recent.sort((a, b) => b.resolvedAt!.compareTo(a.resolvedAt!));
    return recent.first;
  }

  String _confirmationsPhrase(int confirmations) =>
      confirmations == 1 ? '1 confirmation' : '$confirmations confirmations';

  String _lowerFirst(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return trimmed;
    final lowered = trimmed[0].toLowerCase() + trimmed.substring(1);
    return lowered.endsWith('.') ? lowered.substring(0, lowered.length - 1) : lowered;
  }
}
