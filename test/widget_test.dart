import 'dart:io';

import 'package:grundrisse_study/data.dart';
import 'package:grundrisse_study/main.dart';
import 'package:grundrisse_study/nav.dart';
import 'package:grundrisse_study/store.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    // Lay out with the real bundled fonts rather than the square test font.
    for (final (family, files) in [
      ('Archivo', ['Archivo.ttf']),
      ('Newsreader', ['Newsreader.ttf', 'Newsreader-Italic.ttf']),
      ('IBMPlexMono', ['IBMPlexMono-Regular.ttf', 'IBMPlexMono-Medium.ttf']),
    ]) {
      final loader = FontLoader(family);
      for (final file in files) {
        final bytes = File('assets/fonts/$file').readAsBytesSync();
        loader.addFont(Future.value(ByteData.view(bytes.buffer)));
      }
      await loader.load();
    }
    await Course.load();
    await store.load();
  });

  test('bundled course data is complete', () {
    expect(course.lessons.length, 18);
    expect(course.modules.length, 6);
    expect(course.sourceParts.length, 5);
    expect(course.passageCount, 271);
    expect(course.quizCount, 36);
    expect(course.glossaryTerms.length, 42);
    for (final term in course.glossaryTerms) {
      expect(course.lesson(term.lessonId), isNotNull, reason: term.term);
    }
  });

  testWidgets('every tab and a full lesson flow render on a phone', (tester) async {
    tester.view.physicalSize = const Size(360 * 3, 760 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const GrundrisseStudyApp());
    expect(find.text('Begin with lesson 01'), findsOneWidget);

    for (final tab in [1, 2, 3, 4]) {
      AppNav.tab.value = tab;
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: 'tab $tab');
    }
    for (final lab in ['doubling', 'circulation', 'machines']) {
      AppNav.lab.value = lab;
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: 'lab $lab');
    }

    // Open lesson 1, answer both questions correctly, save a note.
    AppNav.tab.value = AppNav.curriculum;
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('What is the Grundrisse?'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('What is the Grundrisse?'));
    await tester.pumpAndSettle();
    final lesson = course.lessons.first;
    for (final q in lesson.quiz) {
      final option = find.text(q.options[q.answer]);
      await tester.ensureVisible(option);
      await tester.pumpAndSettle();
      await tester.tap(option);
      await tester.pump();
      final check = find.text('Check answer');
      await tester.ensureVisible(check);
      await tester.tap(check);
      await tester.pumpAndSettle();
      expect(find.text('Correct.'), findsOneWidget);
      final next = find.textContaining(RegExp('Next question|Finish check'));
      await tester.ensureVisible(next);
      await tester.tap(next);
      await tester.pumpAndSettle();
    }
    expect(store.entry(lesson.id).completed, isTrue);
    expect(store.entry(lesson.id).bestScore, 100);

    await tester.ensureVisible(find.byType(TextField));
    await tester.enterText(find.byType(TextField), 'What does a wage pay for?');
    await tester.pump();
    await tester.ensureVisible(find.text('Save note'));
    await tester.tap(find.text('Save note'));
    await tester.pumpAndSettle(const Duration(seconds: 2));
    expect(store.note(lesson.id), 'What does a wage pay for?');

    // The reading tracker marks passages and persists them.
    final passage = course.sourceParts.first.passages.first;
    store.setRead(passage, true);

    // Progress survives a restart.
    final reloaded = LearningStore();
    await reloaded.load();
    expect(reloaded.entry(lesson.id).completed, isTrue);
    expect(reloaded.note(lesson.id), 'What does a wage pay for?');
    expect(reloaded.isRead(passage), isTrue);

    // The library renders with a passage ticked.
    Navigator.of(tester.element(find.byType(TextField))).pop();
    await tester.pumpAndSettle();
    AppNav.tab.value = AppNav.library;
    await tester.pumpAndSettle();
    expect(find.text('1/${course.passageCount}'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('every lesson and lab renders on a small phone', (tester) async {
    tester.view.physicalSize = const Size(320 * 3, 640 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const GrundrisseStudyApp());
    for (final lab in ['chits', 'doubling', 'circulation', 'machines']) {
      AppNav.tab.value = AppNav.labs;
      AppNav.lab.value = lab;
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: 'lab $lab');
    }
    for (final lesson in course.lessons) {
      AppNav.openLesson(tester.element(find.byType(NavigationBar)), lesson.id);
      await tester.pumpAndSettle();
      await tester.drag(find.byType(SingleChildScrollView).last, const Offset(0, -20000));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: lesson.id);
      tester.state<NavigatorState>(find.byType(Navigator).first).pop();
      await tester.pumpAndSettle();
    }
  });
}
