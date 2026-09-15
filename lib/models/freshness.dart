enum EchoFreshness {
  fresh,
  aging,
  outdated;

  String get label {
    switch (this) {
      case EchoFreshness.fresh:
        return 'Fresh';
      case EchoFreshness.aging:
        return 'Aging';
      case EchoFreshness.outdated:
        return 'Possibly outdated';
    }
  }

  String get indicator {
    switch (this) {
      case EchoFreshness.fresh:
        return 'Fresh';
      case EchoFreshness.aging:
        return 'Aging';
      case EchoFreshness.outdated:
        return 'Possibly outdated';
    }
  }

  String get semanticLabel {
    switch (this) {
      case EchoFreshness.fresh:
        return 'Fresh observation, recently reported';
      case EchoFreshness.aging:
        return 'Aging observation, may need confirmation';
      case EchoFreshness.outdated:
        return 'Possibly outdated observation';
    }
  }
}

// === Information decay model ===
//
// ECHO treats every observation as temporary knowledge that fades unless
// someone re-confirms it. The "clock" for an Echo is the time since it was
// LAST CONFIRMED (lastConfirmedAt), not just when it was first posted, so
// tapping "STILL TRUE" genuinely resets its trust — exactly like someone
// re-observing it right now.
//
// Freshness tier (drives the badge + card styling):
//   hoursSinceConfirmed <  freshHours (4)      -> Fresh
//   hoursSinceConfirmed <  outdatedHours (24)  -> Aging
//   hoursSinceConfirmed >= outdatedHours (24)  -> Outdated
//
// Reliability formula (see Echo.reliability):
//   reliability = baseConfidence - decayPerHour * hoursPastGrace
//   hoursPastGrace = max(0, hoursSinceConfirmed - graceHours)
//   result clamped to [minReliability, 100]
//
// In plain words: an Echo keeps its full reported confidence for the first
// 4 hours after it was last confirmed (the "grace period"). After that, it
// loses 2 reliability points for every additional hour nobody confirms it,
// down to a floor of 5% — never zero, so students can still see it and
// decide for themselves whether it's still true.
const int freshHours = 4;
const int outdatedHours = 24;
const int decayGraceHours = freshHours;
const int decayPerHour = 2;
const int minReliability = 5;

EchoFreshness freshnessFor(DateTime lastConfirmedAt, {DateTime? now}) {
  final age = (now ?? DateTime.now()).difference(lastConfirmedAt);
  if (age.inHours < freshHours) return EchoFreshness.fresh;
  if (age.inHours < outdatedHours) return EchoFreshness.aging;
  return EchoFreshness.outdated;
}

/// Computes an Echo's current reliability from its last-confirmed
/// [baseConfidence] and how long ago that confirmation happened. See the
/// module doc above for the formula and reasoning.
int reliabilityFor(int baseConfidence, DateTime lastConfirmedAt, {DateTime? now}) {
  final hoursSinceConfirmed =
      (now ?? DateTime.now()).difference(lastConfirmedAt).inHours;
  final hoursPastGrace = hoursSinceConfirmed - decayGraceHours;
  final decay = hoursPastGrace > 0 ? hoursPastGrace * decayPerHour : 0;
  return (baseConfidence - decay).clamp(minReliability, 100);
}
