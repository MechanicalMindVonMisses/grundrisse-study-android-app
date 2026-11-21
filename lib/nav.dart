import 'package:material_ui/material_ui.dart';

import 'screens/lesson.dart';
import 'screens/notebook.dart';

/// Cross-screen navigation state: which tab is showing and what it should
/// focus on (the web edition carried these in URL query parameters).
abstract final class AppNav {
  static const home = 0, curriculum = 1, library = 2, labs = 3, glossary = 4;

  static final tab = ValueNotifier<int>(home);
  static final lab = ValueNotifier<String>('chits');
  static final module = ValueNotifier<String?>(null);
  static final glossaryTerm = ValueNotifier<String?>(null);

  static void goTab(BuildContext context, int index) {
    Navigator.of(context).popUntil((route) => route.isFirst);
    tab.value = index;
  }

  static void openModule(BuildContext context, String? moduleId) {
    module.value = moduleId;
    goTab(context, curriculum);
  }

  static void openLab(BuildContext context, String labId) {
    lab.value = labId;
    goTab(context, labs);
  }

  static void openTerm(BuildContext context, String term) {
    glossaryTerm.value = term;
    goTab(context, glossary);
  }

  static void openLesson(
    BuildContext context,
    String lessonId, {
    bool replace = false,
    bool showNotes = false,
  }) {
    final route = MaterialPageRoute<void>(
      builder: (_) => LessonScreen(lessonId: lessonId, showNotes: showNotes),
    );
    if (replace) {
      Navigator.of(context).pushReplacement(route);
    } else {
      Navigator.of(context).push(route);
    }
  }

  static void openNotebook(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const NotebookScreen()),
    );
  }
}
