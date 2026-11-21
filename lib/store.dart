import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'data.dart';

class ProgressEntry {
  const ProgressEntry({
    this.completed = false,
    this.bestScore = 0,
    this.bookmarked = false,
  });

  ProgressEntry.fromJson(Map<String, dynamic> j)
      : completed = j['completed'] == true,
        bestScore = (j['bestScore'] as num?)?.toInt() ?? 0,
        bookmarked = j['bookmarked'] == true;

  final bool completed;
  final int bestScore;
  final bool bookmarked;

  ProgressEntry copyWith({bool? completed, int? bestScore, bool? bookmarked}) =>
      ProgressEntry(
        completed: completed ?? this.completed,
        bestScore: bestScore ?? this.bestScore,
        bookmarked: bookmarked ?? this.bookmarked,
      );

  Map<String, dynamic> toJson() => {
        'completed': completed,
        'bestScore': bestScore,
        'bookmarked': bookmarked,
      };
}

/// Progress, bookmarks and notes, kept entirely on the device.
class LearningStore extends ChangeNotifier {
  static const _progressKey = 'grundrisse-study-progress-v1';
  static const _notesKey = 'grundrisse-study-notes-v1';
  static const _readKey = 'grundrisse-study-read-v1';

  late final SharedPreferences _prefs;
  final Map<String, ProgressEntry> _progress = {};
  final Map<String, String> _notes = {};
  final Set<String> _read = {};

  Future<void> load() async {
    _prefs = await SharedPreferences.getInstance();
    try {
      final raw = _prefs.getString(_progressKey);
      if (raw != null) {
        (jsonDecode(raw) as Map<String, dynamic>).forEach((k, v) {
          _progress[k] = ProgressEntry.fromJson(v as Map<String, dynamic>);
        });
      }
    } catch (_) {
      _progress.clear();
    }
    try {
      final raw = _prefs.getString(_notesKey);
      if (raw != null) {
        (jsonDecode(raw) as Map<String, dynamic>)
            .forEach((k, v) => _notes[k] = '$v');
      }
    } catch (_) {
      _notes.clear();
    }
    _read.addAll(_prefs.getStringList(_readKey) ?? const []);
  }

  /// Reading tracker for the source passages in the library.
  bool isRead(Passage p) => _read.contains(p.key);
  int readCount(Iterable<Passage> passages) =>
      passages.where((p) => _read.contains(p.key)).length;

  void setRead(Passage p, bool read) {
    if (read) {
      _read.add(p.key);
    } else {
      _read.remove(p.key);
    }
    _prefs.setStringList(_readKey, _read.toList());
    notifyListeners();
  }

  ProgressEntry entry(String lessonId) =>
      _progress[lessonId] ?? const ProgressEntry();
  String note(String lessonId) => _notes[lessonId] ?? '';
  Map<String, String> get notes => Map.unmodifiable(_notes);

  int get completedCount => course.lessons
      .where((l) => entry(l.id).completed)
      .length;
  int get percent =>
      (completedCount / course.lessons.length * 100).round();
  Lesson get nextLesson => course.lessons.firstWhere(
        (l) => !entry(l.id).completed,
        orElse: () => course.lessons.first,
      );

  void setCompleted(String lessonId, bool completed, [int score = 0]) {
    final current = entry(lessonId);
    _progress[lessonId] = current.copyWith(
      completed: completed,
      bestScore: score > current.bestScore ? score : current.bestScore,
    );
    _saveProgress();
  }

  void setBookmarked(String lessonId, bool bookmarked) {
    _progress[lessonId] = entry(lessonId).copyWith(bookmarked: bookmarked);
    _saveProgress();
  }

  void saveNote(String lessonId, String content) {
    _notes[lessonId] = content;
    _prefs.setString(_notesKey, jsonEncode(_notes));
    notifyListeners();
  }

  void _saveProgress() {
    _prefs.setString(
      _progressKey,
      jsonEncode(_progress.map((k, v) => MapEntry(k, v.toJson()))),
    );
    notifyListeners();
  }
}

final store = LearningStore();
