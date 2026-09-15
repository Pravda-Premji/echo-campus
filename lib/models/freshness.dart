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

EchoFreshness freshnessFor(DateTime createdAt, {DateTime? now}) {
  final age = (now ?? DateTime.now()).difference(createdAt);
  if (age.inHours < 4) return EchoFreshness.fresh;
  if (age.inHours < 24) return EchoFreshness.aging;
  return EchoFreshness.outdated;
}
