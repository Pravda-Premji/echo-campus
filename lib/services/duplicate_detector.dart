import '../models/echo.dart';

/// Flags a likely-duplicate Echo before posting, using simple local
/// keyword overlap — no network, no AI. Two observations are compared as
/// bags of words and scored by Jaccard similarity (the fraction of their
/// combined vocabulary that's shared). A score at or above [threshold]
/// means "probably the same report."
class DuplicateDetector {
  const DuplicateDetector({this.threshold = 0.45});

  final double threshold;

  /// Returns the most similar active Echo at the same location, if its
  /// similarity to [text] meets [threshold] — otherwise null.
  Echo? findLikelyDuplicate(String text, List<Echo> activeEchoesAtLocation) {
    final words = _wordsOf(text);
    if (words.isEmpty) return null;

    Echo? best;
    var bestScore = 0.0;
    for (final echo in activeEchoesAtLocation) {
      final score = _similarity(words, _wordsOf('${echo.title} ${echo.description}'));
      if (score > bestScore) {
        bestScore = score;
        best = echo;
      }
    }
    return bestScore >= threshold ? best : null;
  }

  Set<String> _wordsOf(String text) => text
      .toLowerCase()
      .split(RegExp(r'[^a-z0-9]+'))
      .where((word) => word.length > 2)
      .toSet();

  double _similarity(Set<String> a, Set<String> b) {
    if (a.isEmpty || b.isEmpty) return 0;
    final union = a.union(b).length;
    if (union == 0) return 0;
    final intersection = a.intersection(b).length;
    return intersection / union;
  }
}
