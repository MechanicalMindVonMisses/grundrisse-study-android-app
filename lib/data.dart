import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

class LessonSection {
  LessonSection.fromJson(Map<String, dynamic> j)
      : heading = j['heading'] as String,
        paragraphs = (j['paragraphs'] as List).cast<String>(),
        callout = j['callout'] as String?;
  final String heading;
  final List<String> paragraphs;
  final String? callout;
}

class QuizQuestion {
  QuizQuestion.fromJson(Map<String, dynamic> j)
      : question = j['question'] as String,
        options = (j['options'] as List).cast<String>(),
        answer = j['answer'] as int,
        explanation = j['explanation'] as String;
  final String question;
  final List<String> options;
  final int answer;
  final String explanation;
}

class LinkRef {
  LinkRef.fromJson(Map<String, dynamic> j)
      : label = j['label'] as String,
        url = j['url'] as String;
  final String label;
  final String url;
}

class Lesson {
  Lesson.fromJson(Map<String, dynamic> j)
      : id = j['id'] as String,
        number = j['number'] as int,
        moduleId = j['moduleId'] as String,
        title = j['title'] as String,
        eyebrow = j['eyebrow'] as String,
        duration = j['duration'] as int,
        description = j['description'] as String,
        objectives = (j['objectives'] as List).cast<String>(),
        sections = (j['sections'] as List)
            .map((e) => LessonSection.fromJson(e as Map<String, dynamic>))
            .toList(),
        exampleTitle = (j['example'] as Map)['title'] as String,
        exampleBody = (j['example'] as Map)['body'] as String,
        distinction = j['distinction'] as String,
        source = LinkRef.fromJson(j['source'] as Map<String, dynamic>),
        furtherReading = j['furtherReading'] == null
            ? null
            : LinkRef.fromJson(j['furtherReading'] as Map<String, dynamic>),
        lab = j['lab'] as String?,
        quiz = (j['quiz'] as List)
            .map((e) => QuizQuestion.fromJson(e as Map<String, dynamic>))
            .toList();
  final String id;
  final int number;
  final String moduleId;
  final String title;
  final String eyebrow;
  final int duration;
  final String description;
  final List<String> objectives;
  final List<LessonSection> sections;
  final String exampleTitle;
  final String exampleBody;
  final String distinction;
  final LinkRef source;
  final LinkRef? furtherReading;
  final String? lab;
  final List<QuizQuestion> quiz;
}

class CourseModule {
  CourseModule.fromJson(Map<String, dynamic> j)
      : id = j['id'] as String,
        index = j['index'] as String,
        title = j['title'] as String,
        subtitle = j['subtitle'] as String,
        description = j['description'] as String;
  final String id;
  final String index;
  final String title;
  final String subtitle;
  final String description;
}

class GlossaryTerm {
  GlossaryTerm.fromJson(Map<String, dynamic> j)
      : term = j['term'] as String,
        category = j['category'] as String,
        definition = j['definition'] as String,
        watchFor = j['watchFor'] as String,
        lessonId = j['lessonId'] as String;
  final String term;
  final String category;
  final String definition;
  final String watchFor;
  final String lessonId;
}

class Passage {
  Passage.fromJson(Map<String, dynamic> j)
      : page = j['page'] as int,
        title = j['title'] as String,
        url = j['url'] as String;
  final int page;
  final String title;
  final String url;

  /// Stable key for the reading tracker.
  String get key => 'p$page:$title';
}

class SourcePart {
  SourcePart.fromJson(Map<String, dynamic> j)
      : id = j['id'] as String,
        short = j['short'] as String,
        title = j['title'] as String,
        subtitle = j['subtitle'] as String,
        notebooks = j['notebooks'] as String,
        pages = j['pages'] as String,
        editorialNote = j['editorialNote'] as String,
        contentsUrl = j['contentsUrl'] as String,
        passages = (j['passages'] as List)
            .map((e) => Passage.fromJson(e as Map<String, dynamic>))
            .toList();
  final String id;
  final String short;
  final String title;
  final String subtitle;
  final String notebooks;
  final String pages;
  final String editorialNote;
  final String contentsUrl;
  final List<Passage> passages;
}

class CompanionText {
  CompanionText.fromJson(Map<String, dynamic> j)
      : title = j['title'] as String,
        year = '${j['year']}',
        description = j['description'] as String,
        url = j['url'] as String;
  final String title;
  final String year;
  final String description;
  final String url;
}

/// All course content, bundled with the app so it works without a network.
class Course {
  Course._(Map<String, dynamic> j)
      : modules = _list(j['modules'], CourseModule.fromJson),
        lessons = _list(j['lessons'], Lesson.fromJson),
        glossaryTerms = _list(j['glossaryTerms'], GlossaryTerm.fromJson),
        glossaryCategories = (j['glossaryCategories'] as List).cast<String>(),
        sourceParts = _list(j['sourceParts'], SourcePart.fromJson),
        companionTexts = _list(j['companionTexts'], CompanionText.fromJson),
        downloads = (j['downloads'] as Map).cast<String, String>();

  static List<T> _list<T>(dynamic raw, T Function(Map<String, dynamic>) f) =>
      (raw as List).map((e) => f(e as Map<String, dynamic>)).toList();

  static late final Course instance;

  static Future<void> load() async {
    final raw = await rootBundle.loadString('assets/data/course.json');
    instance = Course._(jsonDecode(raw) as Map<String, dynamic>);
  }

  final List<CourseModule> modules;
  final List<Lesson> lessons;
  final List<GlossaryTerm> glossaryTerms;
  final List<String> glossaryCategories;
  final List<SourcePart> sourceParts;
  final List<CompanionText> companionTexts;
  final Map<String, String> downloads;

  int get passageCount =>
      sourceParts.fold(0, (sum, p) => sum + p.passages.length);
  Iterable<Passage> get allPassages => sourceParts.expand((p) => p.passages);
  int get quizCount => lessons.fold(0, (sum, l) => sum + l.quiz.length);

  Lesson? lesson(String? id) {
    for (final l in lessons) {
      if (l.id == id) return l;
    }
    return null;
  }

  CourseModule? module(String id) {
    for (final m in modules) {
      if (m.id == id) return m;
    }
    return null;
  }

  List<Lesson> moduleLessons(String id) =>
      lessons.where((l) => l.moduleId == id).toList();
}

Course get course => Course.instance;

String pad2(int n) => n.toString().padLeft(2, '0');

/// 12000 -> "12,000"
String grouped(num n) {
  final s = n.round().abs().toString();
  final b = StringBuffer(n < 0 ? '-' : '');
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) b.write(',');
    b.write(s[i]);
  }
  return b.toString();
}
