import '../models/echo_category.dart';

/// Keyword-based classification that runs entirely on-device.
class SmartClassifier {
  const SmartClassifier();

  EchoCategory classify(String text) {
    final haystack = text.toLowerCase();
    if (haystack.isEmpty) return EchoCategory.other;

    if (_matches(haystack, const [
      'wifi',
      'wi-fi',
      'wi fi',
      'network',
      'internet',
      'router',
      'signal',
    ])) {
      return EchoCategory.wifi;
    }

    if (_matches(haystack, const [
      'projector',
      'hdmi',
      'laptop',
      'equipment',
      'monitor',
      'screen',
      'mic',
      'microphone',
      'speaker',
    ])) {
      return EchoCategory.equipment;
    }

    if (_matches(haystack, const [
      'socket',
      'power',
      'electricity',
      'plug',
      'outlet',
      'charger',
      'switchboard',
    ])) {
      return EchoCategory.electricity;
    }

    if (_matches(haystack, const [
      'canteen',
      'food',
      'counter',
      'queue',
      'lunch',
      'snack',
      'mess',
    ])) {
      return EchoCategory.food;
    }

    if (_matches(haystack, const [
      'broken',
      'damage',
      'maintenance',
      'repair',
      'leak',
      'blocked',
      'out of order',
    ])) {
      return EchoCategory.maintenance;
    }

    return EchoCategory.other;
  }

  bool _matches(String haystack, List<String> keywords) {
    return keywords.any(haystack.contains);
  }
}
