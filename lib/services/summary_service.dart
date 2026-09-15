import '../models/campus_location.dart';
import '../models/echo.dart';

/// Builds a short local briefing from active Echoes. No network.
class SummaryService {
  const SummaryService();

  String summarize({
    required CampusLocation location,
    required List<Echo> activeEchoes,
  }) {
    if (activeEchoes.isEmpty) {
      return '${location.label} currently has no active observations. '
          'Campus conditions here look calm — check back if something changes.';
    }

    final count = activeEchoes.length;
    final countPhrase = count == 1
        ? 'one active observation'
        : '$count active observations';

    final clauses = activeEchoes.map(_clauseFor).toList();
    final details = _joinClauses(clauses);

    return '${location.label} currently has $countPhrase. $details';
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

  String _clauseFor(Echo echo) {
    final text = echo.description.trim();
    final lowered = text[0].toLowerCase() + text.substring(1);
    final cleaned = lowered.endsWith('.')
        ? lowered.substring(0, lowered.length - 1)
        : lowered;
    return cleaned;
  }

  String _joinClauses(List<String> clauses) {
    if (clauses.length == 1) {
      return 'Students noticed that ${clauses.first}.';
    }
    if (clauses.length == 2) {
      return '${_capitalize(clauses[0])}, and ${clauses[1]}.';
    }
    final head = clauses.sublist(0, clauses.length - 1).join(', ');
    return '${_capitalize(head)}, and ${clauses.last}.';
  }

  String _capitalize(String value) {
    if (value.isEmpty) return value;
    return value[0].toUpperCase() + value.substring(1);
  }
}
