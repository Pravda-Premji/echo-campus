import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:echo_campus/data/echo_repository.dart';
import 'package:echo_campus/main.dart';
import 'package:echo_campus/models/campus_location.dart';
import 'package:echo_campus/models/echo.dart';
import 'package:echo_campus/models/echo_category.dart';
import 'package:echo_campus/models/freshness.dart';
import 'package:echo_campus/services/smart_classifier.dart';

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
    expect(repo.healthFor(CampusLocation.lab204).score, 43);
    expect(repo.healthFor(CampusLocation.library).score, 91);
    expect(repo.healthFor(CampusLocation.canteen).score, 68);
    expect(repo.healthFor(CampusLocation.seminarHall).score, 95);
  });

  test('Still True and Fixed update repository state', () {
    final repo = EchoRepository();
    final before = repo.activeFor(CampusLocation.lab204).first;
    repo.confirmStillTrue(before.id);
    final confirmed = repo.echoes.firstWhere((echo) => echo.id == before.id);
    expect(confirmed.confirmations, before.confirmations + 1);
    expect(confirmed.confidence, (before.confidence + 5).clamp(0, 100));

    repo.markResolved(before.id);
    expect(
      repo.activeFor(CampusLocation.lab204).any((echo) => echo.id == before.id),
      isFalse,
    );
    expect(
      repo.resolvedFor(CampusLocation.lab204).any((echo) => echo.id == before.id),
      isTrue,
    );
    expect(repo.healthFor(CampusLocation.lab204).score, greaterThan(43));
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

  testWidgets('Location details, briefing, and resolve flow', (tester) async {
    await _phoneSurface(tester);
    await tester.pumpWidget(EchoApp(repository: EchoRepository()));
    await tester.tap(find.text('LAB 204'));
    await tester.pumpAndSettle();

    expect(find.text('Things you should know'), findsOneWidget);
    expect(find.text('PROJECTOR CONNECTIVITY ISSUE'), findsOneWidget);

    await tester.tap(find.text('✨ What should I know?'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Lab 204 currently has'), findsOneWidget);

    await tester.scrollUntilVisible(find.text('STILL TRUE').first, 300);
    await tester.tap(find.text('STILL TRUE').first);
    await tester.pumpAndSettle();
    expect(find.text('✓ Echo confirmed'), findsOneWidget);

    await tester.tap(find.text('FIXED').first);
    await tester.pumpAndSettle();
    expect(find.text('✓ Marked as resolved'), findsOneWidget);
    expect(find.text('Recently resolved'), findsOneWidget);
  });

  testWidgets('Add Echo posts and returns', (tester) async {
    await _phoneSurface(tester);
    await tester.pumpWidget(EchoApp(repository: EchoRepository()));
    await tester.tap(find.text('+ Add an Echo'));
    await tester.pumpAndSettle();

    expect(find.text('What did you notice?'), findsOneWidget);
    await tester.enterText(
      find.byType(TextField),
      'Projector HDMI 1 is not working in Lab 204',
    );
    await tester.pump();
    expect(find.textContaining('Smart classification: Equipment'), findsOneWidget);

    await tester.scrollUntilVisible(find.text('POST ECHO'), 300);
    await tester.tap(find.text('POST ECHO'));
    await tester.pumpAndSettle();
    expect(find.text('✓ Echo added successfully'), findsOneWidget);
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

    await tester.scrollUntilVisible(find.text('MARK RESOLVED').first, 300);
    await tester.tap(find.text('MARK RESOLVED').first);
    await tester.pumpAndSettle();
    expect(find.text('✓ Issue marked as resolved'), findsOneWidget);
    expect(repo.resolvedEchoes, isNotEmpty);
  });

  test('Sample Lab 204 echoes match the brief', () {
    final repo = EchoRepository();
    final lab = repo.activeFor(CampusLocation.lab204);
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
      location: CampusLocation.library,
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
      location: CampusLocation.library,
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
      location: CampusLocation.seminarHall,
    );
    await repo1.pendingWrite;

    repo1.confirmStillTrue(added.id);
    await repo1.pendingWrite;

    final labEcho = repo1.activeFor(CampusLocation.lab204).first;
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
}
