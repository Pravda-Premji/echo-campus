import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:echo_campus/data/echo_repository.dart';
import 'package:echo_campus/main.dart';
import 'package:echo_campus/models/campus_location.dart';
import 'package:echo_campus/models/echo.dart';
import 'package:echo_campus/models/echo_category.dart';
import 'package:echo_campus/services/smart_classifier.dart';

Future<void> _phoneSurface(WidgetTester tester) async {
  tester.view.physicalSize = const Size(1080, 2400);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
}

void main() {
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
}
