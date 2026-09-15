import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:echo_campus/data/built_in_locations.dart';
import 'package:echo_campus/data/echo_repository.dart';
import 'package:echo_campus/main.dart';
import 'package:echo_campus/models/echo.dart';
import 'package:echo_campus/models/echo_category.dart';
import 'package:echo_campus/models/echo_severity.dart';
import 'package:echo_campus/models/freshness.dart';
import 'package:echo_campus/models/location_category.dart';
import 'package:echo_campus/services/alerts_service.dart';
import 'package:echo_campus/services/duplicate_detector.dart';
import 'package:echo_campus/services/smart_classifier.dart';
import 'package:echo_campus/services/summary_service.dart';

Future<void> _phoneSurface(WidgetTester tester) async {
  tester.view.physicalSize = const Size(1080, 2400);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Each test gets a clean, empty local-storage backing so persisted state
  // from one test never leaks into the next (EchoRepository always hydrates
  // from shared_preferences on construction).
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Home shows campus locations and add echo', (tester) async {
    await _phoneSurface(tester);
    await tester.pumpWidget(EchoApp(repository: EchoRepository()));

    expect(find.text('ECHO'), findsOneWidget);
    expect(find.text('THE INVISIBLE CAMPUS'), findsOneWidget);
    expect(find.text('What should you know?'), findsOneWidget);
    expect(find.text('LAB 204'), findsOneWidget);
    expect(find.text('LIBRARY'), findsOneWidget);
    expect(find.text('+ Add an Echo'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('CANTEEN'), 200);
    expect(find.text('CANTEEN'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('SEMINAR HALL'), 200);
    expect(find.text('SEMINAR HALL'), findsOneWidget);
  });

  test('Health scores match the demo campus snapshot', () {
    final repo = EchoRepository();
    expect(repo.healthFor(BuiltInLocations.lab204).score, 43);
    expect(repo.healthFor(BuiltInLocations.library).score, 91);
    expect(repo.healthFor(BuiltInLocations.canteen).score, 68);
    expect(repo.healthFor(BuiltInLocations.seminarHall).score, 95);
  });

  test('Still True and Fixed update repository state', () {
    final repo = EchoRepository();
    final before = repo.activeFor(BuiltInLocations.lab204).first;
    repo.confirmStillTrue(before.id);
    final confirmed = repo.echoes.firstWhere((echo) => echo.id == before.id);
    expect(confirmed.confirmations, before.confirmations + 1);
    expect(confirmed.confidence, (before.confidence + 5).clamp(0, 100));

    repo.markResolved(before.id);
    expect(
      repo.activeFor(BuiltInLocations.lab204).any((echo) => echo.id == before.id),
      isFalse,
    );
    expect(
      repo.resolvedFor(BuiltInLocations.lab204).any((echo) => echo.id == before.id),
      isTrue,
    );
    expect(repo.healthFor(BuiltInLocations.lab204).score, greaterThan(43));
  });

  test('Smart classifier maps keywords locally', () {
    const classifier = SmartClassifier();
    expect(classifier.classify('Projector HDMI 1 is not working'), EchoCategory.equipment);
    expect(classifier.classify('Weak wifi near the back'), EchoCategory.wifi);
    expect(classifier.classify('Power socket is dead'), EchoCategory.electricity);
    expect(classifier.classify('Canteen counter is slow'), EchoCategory.food);
    expect(classifier.classify('Broken door needs maintenance'), EchoCategory.maintenance);
    expect(classifier.classify('Nice sunset from the terrace'), EchoCategory.other);
  });

  testWidgets('Location details, briefing, resolve flow, and history', (tester) async {
    await _phoneSurface(tester);
    await tester.pumpWidget(EchoApp(repository: EchoRepository()));
    await tester.tap(find.text('LAB 204'));
    await tester.pumpAndSettle();

    expect(find.text('Things you should know'), findsOneWidget);
    expect(find.text('PROJECTOR CONNECTIVITY ISSUE'), findsOneWidget);

    await tester.tap(find.text('✨ What should I know?'));
    await tester.pumpAndSettle();
    // The briefing is generated locally from Echo data, not an LLM — it
    // leads with whichever active issue is most important right now.
    expect(find.textContaining('Most important right now'), findsOneWidget);
    expect(find.textContaining('not AI'), findsOneWidget);

    await tester.scrollUntilVisible(find.text('STILL TRUE').first, 300);
    await tester.tap(find.text('STILL TRUE').first);
    await tester.pumpAndSettle();
    expect(find.text('✓ Echo confirmed'), findsOneWidget);

    await tester.tap(find.text('FIXED').first);
    await tester.pumpAndSettle();
    expect(find.text('✓ Marked as resolved'), findsOneWidget);
    expect(find.text('Recently resolved'), findsOneWidget);

    await tester.scrollUntilVisible(find.textContaining('View full history'), 300);
    await tester.tap(find.textContaining('View full history'));
    await tester.pumpAndSettle();
    expect(find.text('Hide history'), findsOneWidget);
  });

  testWidgets('Add Echo posts and returns', (tester) async {
    await _phoneSurface(tester);
    await tester.pumpWidget(EchoApp(repository: EchoRepository()));
    await tester.tap(find.text('+ Add an Echo'));
    await tester.pumpAndSettle();

    expect(find.text('What did you notice?'), findsOneWidget);
    await tester.enterText(
      find.byType(TextField).first,
      'Projector HDMI 1 is not working in Lab 204',
    );
    await tester.pump();
    expect(find.textContaining('Smart classification: Equipment'), findsOneWidget);

    await tester.scrollUntilVisible(find.text('POST ECHO'), 300);
    await tester.tap(find.text('POST ECHO'));
    await tester.pumpAndSettle();
    expect(find.text('✓ Echo added successfully'), findsOneWidget);
  });

  testWidgets('Add Echo validates short descriptions', (tester) async {
    await _phoneSurface(tester);
    await tester.pumpWidget(EchoApp(repository: EchoRepository()));
    await tester.tap(find.text('+ Add an Echo'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, 'ok');
    await tester.pump();
    await tester.scrollUntilVisible(find.text('POST ECHO'), 300);
    await tester.tap(find.text('POST ECHO'));
    await tester.pumpAndSettle();

    expect(find.textContaining('at least 8 characters'), findsOneWidget);
  });

  testWidgets('Duplicate detection offers to confirm the existing Echo', (tester) async {
    await _phoneSurface(tester);
    final repo = EchoRepository();
    await tester.pumpWidget(EchoApp(repository: repo));
    await tester.tap(find.text('+ Add an Echo'));
    await tester.pumpAndSettle();

    // Close to the seeded "Projector connectivity issue" at Lab 204.
    await tester.enterText(
      find.byType(TextField).first,
      'HDMI 1 is still not detecting laptops, projector issue persists',
    );
    await tester.pump();

    await tester.scrollUntilVisible(find.text('POST ECHO'), 300);
    await tester.tap(find.text('POST ECHO'));
    await tester.pumpAndSettle();

    expect(find.text('This looks similar to an existing report'), findsOneWidget);

    final activeBefore = repo.activeFor(BuiltInLocations.lab204).length;
    await tester.tap(find.text('CONFIRM EXISTING'));
    await tester.pumpAndSettle();

    // Confirming instead of posting must not create a new Echo.
    expect(repo.activeFor(BuiltInLocations.lab204).length, activeBefore);
    expect(find.text('✓ Echo added successfully'), findsOneWidget);
  });

  testWidgets('A new location can be added and is selectable for an Echo', (tester) async {
    await _phoneSurface(tester);
    final repo = EchoRepository();
    await tester.pumpWidget(EchoApp(repository: repo));
    await repo.pendingHydrate;

    await tester.tap(find.widgetWithText(OutlinedButton, 'Location'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).at(0), 'CSE Lab 305');
    await tester.enterText(find.byType(TextField).at(1), 'Block C');
    await tester.tap(find.text('SAVE LOCATION'));
    await tester.pumpAndSettle();

    expect(repo.locations.any((location) => location.name == 'CSE Lab 305'), isTrue);
    expect(find.text('CSE LAB 305'), findsOneWidget);
  });

  testWidgets('Admin can mark an issue resolved everywhere', (tester) async {
    final repo = EchoRepository();
    await _phoneSurface(tester);
    await tester.pumpWidget(EchoApp(repository: repo));
    await tester.tap(find.byTooltip('Admin mode'));
    await tester.pumpAndSettle();

    expect(find.text('ECHO ADMIN'), findsOneWidget);
    expect(find.text('ACTIVE CAMPUS ISSUES'), findsOneWidget);
    expect(find.textContaining('Equipment-related observations'), findsOneWidget);
    expect(find.text('CATEGORY DISTRIBUTION'), findsOneWidget);

    await tester.scrollUntilVisible(find.text('MARK RESOLVED').first, 300);
    await tester.tap(find.text('MARK RESOLVED').first);
    await tester.pumpAndSettle();
    expect(find.text('✓ Issue marked as resolved'), findsOneWidget);
    expect(repo.resolvedEchoes, isNotEmpty);
  });

  testWidgets('Search screen opens and filters by category', (tester) async {
    await _phoneSurface(tester);
    await tester.pumpWidget(EchoApp(repository: EchoRepository()));
    await tester.tap(find.byTooltip('Search'));
    await tester.pumpAndSettle();

    expect(find.text('SEARCH ECHO'), findsOneWidget);
    expect(find.text('Search ECHO'), findsOneWidget); // empty-state prompt

    await tester.tap(find.text('Wi-Fi'));
    await tester.pumpAndSettle();
    // EchoCard renders titles upper-cased.
    expect(find.textContaining('WEAK WI-FI'), findsOneWidget);
  });

  test('Sample Lab 204 echoes match the brief', () {
    final repo = EchoRepository();
    final lab = repo.activeFor(BuiltInLocations.lab204);
    expect(lab.map((Echo e) => e.title), containsAll([
      'Projector connectivity issue',
      'Weak Wi-Fi near back seats',
      'Faulty power socket',
    ]));
  });

  test('Reliability decays deterministically and resets on confirmation', () {
    final lastConfirmedAt = DateTime(2024, 1, 1, 8, 0);
    final echo = Echo(
      id: 'echo-decay-test',
      title: 'Test observation',
      description: 'Used only to exercise the decay formula.',
      category: EchoCategory.other,
      location: BuiltInLocations.library,
      confidence: 90,
      confirmations: 1,
      createdAt: lastConfirmedAt,
    );

    // Inside the 4-hour grace period: full reliability, no decay yet.
    expect(
      echo.reliability(now: lastConfirmedAt.add(const Duration(hours: 2))),
      90,
    );

    // 14h since confirmation = 10h past the 4h grace period -> -2/hour = -20.
    expect(
      echo.reliability(now: lastConfirmedAt.add(const Duration(hours: 14))),
      70,
    );

    // Long unconfirmed: decay clamps at the 5% floor, never reaches zero.
    expect(
      echo.reliability(now: lastConfirmedAt.add(const Duration(hours: 200))),
      minReliability,
    );

    // "STILL TRUE" resets the clock: reliability returns to the (new) base
    // as of the moment it was confirmed.
    final reconfirmed = echo.copyWith(
      confidence: 95,
      lastConfirmedAt: lastConfirmedAt.add(const Duration(hours: 14)),
    );
    expect(
      reconfirmed.reliability(now: lastConfirmedAt.add(const Duration(hours: 14))),
      95,
    );
  });

  test('Freshness tier follows time since last confirmation', () {
    final lastConfirmedAt = DateTime(2024, 1, 1, 8, 0);
    final echo = Echo(
      id: 'echo-freshness-test',
      title: 'Test observation',
      description: 'Used only to exercise the freshness tiers.',
      category: EchoCategory.other,
      location: BuiltInLocations.library,
      confidence: 80,
      confirmations: 1,
      createdAt: lastConfirmedAt,
    );

    expect(
      echo.freshness(now: lastConfirmedAt.add(const Duration(hours: 1))),
      EchoFreshness.fresh,
    );
    expect(
      echo.freshness(now: lastConfirmedAt.add(const Duration(hours: 10))),
      EchoFreshness.aging,
    );
    expect(
      echo.freshness(now: lastConfirmedAt.add(const Duration(hours: 30))),
      EchoFreshness.outdated,
    );
  });

  test('EchoRepository persists new, confirmed, and resolved Echoes locally',
      () async {
    final repo1 = EchoRepository();
    await repo1.pendingHydrate;

    final added = repo1.addEcho(
      title: 'Elevator in block C is stuck',
      description: 'Elevator in block C is stuck between floors.',
      category: EchoCategory.maintenance,
      location: BuiltInLocations.seminarHall,
    );
    await repo1.pendingWrite;

    repo1.confirmStillTrue(added.id);
    await repo1.pendingWrite;

    final labEcho = repo1.activeFor(BuiltInLocations.lab204).first;
    repo1.markResolved(labEcho.id);
    await repo1.pendingWrite;

    // A brand new repository instance (standing in for an app restart)
    // should hydrate from the same local storage rather than reseeding.
    final repo2 = EchoRepository();
    await repo2.pendingHydrate;

    final persistedAdded =
        repo2.echoes.firstWhere((echo) => echo.id == added.id);
    expect(persistedAdded.title, 'Elevator in block C is stuck');
    expect(persistedAdded.confirmations, 2);

    expect(
      repo2.resolvedEchoes.any((echo) => echo.id == labEcho.id),
      isTrue,
    );
  });

  test('New locations persist across restarts and their health/counts work', () async {
    final repo1 = EchoRepository();
    await repo1.pendingHydrate;

    final location = repo1.addLocation(
      name: 'CSE Lab 305',
      building: 'Block C',
      floor: '3',
      category: LocationCategory.lab,
    );
    await repo1.pendingWrite;

    expect(repo1.healthFor(location).score, 95); // empty location: calm/healthy
    expect(repo1.activeFor(location), isEmpty);

    final echo = repo1.addEcho(
      title: 'Loud AC unit',
      description: 'The air conditioner is making a loud rattling noise.',
      category: EchoCategory.maintenance,
      location: location,
    );
    await repo1.pendingWrite;

    expect(repo1.activeFor(location), contains(echo));
    expect(repo1.healthFor(location).score, lessThan(95));

    final repo2 = EchoRepository();
    await repo2.pendingHydrate;
    final persistedLocation = repo2.locations.firstWhere((l) => l.id == location.id);
    expect(persistedLocation.name, 'CSE Lab 305');
    expect(repo2.activeFor(persistedLocation).length, 1);
  });

  test('Favourite locations toggle and persist across restarts', () async {
    final repo1 = EchoRepository();
    await repo1.pendingHydrate;
    final location = repo1.locations.first;
    expect(repo1.isFavorite(location), isFalse);

    repo1.toggleFavorite(location);
    await repo1.pendingWrite;
    expect(repo1.isFavorite(location), isTrue);
    expect(repo1.favoriteLocations, contains(location));

    final repo2 = EchoRepository();
    await repo2.pendingHydrate;
    expect(repo2.isFavorite(repo2.locations.first), isTrue);
  });

  test('historyFor returns every Echo for a location, newest first', () {
    final repo = EchoRepository();
    final history = repo.historyFor(BuiltInLocations.lab204);
    expect(history.length, 3);
    for (var i = 0; i < history.length - 1; i++) {
      expect(
        !history[i].createdAt.isBefore(history[i + 1].createdAt),
        isTrue,
        reason: 'history should be sorted newest first',
      );
    }
  });

  test('DuplicateDetector flags near-duplicate reports and ignores unrelated ones', () {
    const detector = DuplicateDetector();
    final existing = Echo(
      id: 'echo-x',
      title: 'Projector not working',
      description: 'HDMI 1 is not detecting laptops in the lab.',
      category: EchoCategory.equipment,
      location: BuiltInLocations.lab204,
      confidence: 80,
      confirmations: 1,
      createdAt: DateTime.now(),
    );

    final duplicate = detector.findLikelyDuplicate(
      'HDMI 1 is still not detecting any laptops in the lab',
      [existing],
    );
    expect(duplicate?.id, 'echo-x');

    final unrelated = detector.findLikelyDuplicate(
      'The canteen queue is really long today',
      [existing],
    );
    expect(unrelated, isNull);
  });

  test('AlertsService surfaces highly confirmed and low-reliability issues', () {
    const alertsService = AlertsService();
    final now = DateTime.now();
    final highlyConfirmed = Echo(
      id: 'echo-hc',
      title: 'Busy issue',
      description: 'Many people noticed this.',
      category: EchoCategory.other,
      location: BuiltInLocations.library,
      confidence: 80,
      confirmations: 10,
      createdAt: now.subtract(const Duration(hours: 5)),
    );
    final lowReliability = Echo(
      id: 'echo-lr',
      title: 'Old issue',
      description: 'This has decayed a lot by now.',
      category: EchoCategory.other,
      location: BuiltInLocations.library,
      confidence: 30,
      confirmations: 1,
      createdAt: now.subtract(const Duration(hours: 60)),
      lastConfirmedAt: now.subtract(const Duration(hours: 60)),
    );

    final alerts = alertsService.alertsFor(
      activeEchoes: [highlyConfirmed, lowReliability],
      resolvedEchoes: const [],
    );

    expect(alerts.any((a) => a.kind == AlertKind.highlyConfirmed && a.echo.id == 'echo-hc'), isTrue);
    expect(alerts.any((a) => a.kind == AlertKind.lowReliability && a.echo.id == 'echo-lr'), isTrue);
  });

  test('SummaryService briefing leads with the most important active issue', () {
    const summaryService = SummaryService();
    final now = DateTime.now();
    final minor = Echo(
      id: 'a',
      title: 'Minor thing',
      description: 'Small.',
      category: EchoCategory.other,
      location: BuiltInLocations.library,
      confidence: 70,
      confirmations: 2,
      createdAt: now,
    );
    final major = Echo(
      id: 'b',
      title: 'Big thing',
      description: 'Important.',
      category: EchoCategory.other,
      location: BuiltInLocations.library,
      confidence: 90,
      confirmations: 5,
      createdAt: now,
      severity: EchoSeverity.high,
    );

    final summary = summaryService.summarize(
      location: BuiltInLocations.library,
      activeEchoes: [minor, major],
    );

    expect(summary, contains('Big thing'));
    expect(summary, contains('Minor thing'));
    expect(summary, contains('% reliable'));
    expect(summary, contains('confirmation'));
  });
}
