import 'built_in_locations.dart';
import '../models/echo.dart';
import '../models/echo_category.dart';
import '../models/echo_severity.dart';

List<Echo> createSampleEchoes({DateTime? now}) {
  final clock = now ?? DateTime.now();
  return [
    Echo(
      id: 'echo-lab-projector',
      title: 'Projector connectivity issue',
      description: 'HDMI 1 is not detecting laptops. HDMI 2 works.',
      category: EchoCategory.equipment,
      location: BuiltInLocations.lab204,
      confidence: 92,
      confirmations: 8,
      createdAt: clock.subtract(const Duration(hours: 2)),
      severity: EchoSeverity.high,
    ),
    Echo(
      id: 'echo-lab-wifi',
      title: 'Weak Wi-Fi near back seats',
      description: 'Network connection is weak near the rear benches.',
      category: EchoCategory.wifi,
      location: BuiltInLocations.lab204,
      confidence: 71,
      confirmations: 7,
      createdAt: clock.subtract(const Duration(hours: 6)),
      severity: EchoSeverity.medium,
    ),
    Echo(
      id: 'echo-lab-socket',
      title: 'Faulty power socket',
      description: 'Socket near workstation 6 is not working.',
      category: EchoCategory.electricity,
      location: BuiltInLocations.lab204,
      confidence: 84,
      confirmations: 5,
      createdAt: clock.subtract(const Duration(hours: 11)),
      severity: EchoSeverity.medium,
    ),
    Echo(
      id: 'echo-library-quiet',
      title: 'Quiet study area',
      description: 'Reference section is usually quiet after 4 PM.',
      category: EchoCategory.other,
      location: BuiltInLocations.library,
      confidence: 89,
      confirmations: 12,
      createdAt: clock.subtract(const Duration(hours: 3)),
    ),
    Echo(
      id: 'echo-canteen-north',
      title: 'North counter is faster',
      description: 'North canteen counter is usually faster after 1:30 PM.',
      category: EchoCategory.food,
      location: BuiltInLocations.canteen,
      confidence: 78,
      confirmations: 9,
      createdAt: clock.subtract(const Duration(hours: 5)),
    ),
  ];
}
