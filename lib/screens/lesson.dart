import 'package:material_ui/material_ui.dart';

import '../data.dart';
import '../nav.dart';
import '../store.dart';
import '../theme.dart';

const _labNames = {
  'chits': 'The time-chit bank',
  'doubling': 'Productivity arithmetic',
  'circulation': 'Circulation time & turnover',
  'machines': 'Machines & disposable time',
};

class LessonScreen extends StatefulWidget {
  const LessonScreen({super.key, required this.lessonId, this.showNotes = false});
  final String lessonId;
  final bool showNotes;

  @override
  State<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen> {
  late final Lesson? lesson = course.lesson(widget.lessonId);
  late final _sectionKeys = [for (final _ in lesson?.sections ?? const <LessonSection>[]) GlobalKey()];
  final _sourceKey = GlobalKey();
  final _quizKey = GlobalKey();
  final _notesKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    if (widget.showNotes) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _jump(_notesKey, animate: false));
    }
  }

  void _jump(GlobalKey key, {bool animate = true}) {
    final target = key.currentContext;
    if (target == null) return;
    Scrollable.ensureVisible(
      target,
      duration: animate ? const Duration(milliseconds: 350) : Duration.zero,
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final lesson = this.lesson;
    if (lesson == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Lesson')),
        body: EmptyState(
          title: 'Lesson not found.',
          body: 'Return to the curriculum and choose another lesson.',
          action: SecondaryButton('Open curriculum', onPressed: () => AppNav.openModule(context, null)),
        ),
      );
    }
    final module = course.module(lesson.moduleId)!;
    final index = course.lessons.indexOf(lesson);
    final previous = index > 0 ? course.lessons[index - 1] : null;
    final next = index < course.lessons.length - 1 ? course.lessons[index + 1] : null;
    final terms = course.glossaryTerms.where((t) => t.lessonId == lesson.id).take(4).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Level ${module.index} · Lesson ${lesson.number}'),
        actions: [
          ListenableBuilder(
            listenable: store,
            builder: (context, _) {
              final bookmarked = store.entry(lesson.id).bookmarked;
              return IconButton(
                tooltip: bookmarked ? 'Remove bookmark' : 'Bookmark lesson',
                icon: Icon(bookmarked ? Icons.bookmark : Icons.bookmark_border, color: bookmarked ? C.coral : C.ink),
                onPressed: () => store.setBookmarked(lesson.id, !bookmarked),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(bottom: 24 + MediaQuery.paddingOf(context).bottom),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _header(lesson),
            _objectives(lesson),
            _contents(lesson),
            for (var i = 0; i < lesson.sections.length; i++)
              _section(lesson.sections[i], i, _sectionKeys[i]),
            _example(lesson),
            _distinction(lesson),
            _source(lesson),
            if (lesson.lab != null) _labLink(lesson.lab!),
            if (terms.isNotEmpty) _terms(terms),
            KnowledgeCheck(
              key: _quizKey,
              lesson: lesson,
              onFinish: (score) => store.setCompleted(lesson.id, true, score),
            ),
            NoteEditor(key: _notesKey, lessonId: lesson.id),
            _pagination(previous, next),
          ],
        ),
      ),
    );
  }

  Widget _header(Lesson lesson) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: Eyebrow(lesson.eyebrow)),
                Text(pad2(lesson.number), style: display(44, weight: 600, color: C.lineSoft, height: 0.9)),
              ],
            ),
            Text(lesson.title, style: display(38, height: 1.02)),
            const SizedBox(height: 14),
            Text(lesson.description, style: reading(18, color: C.muted, height: 1.5)),
            const SizedBox(height: 18),
            Wrap(
              spacing: 16,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                _meta(Icons.schedule, '${lesson.duration} min read'),
                _meta(Icons.menu_book_outlined, 'Source pages linked'),
                ListenableBuilder(
                  listenable: store,
                  builder: (context, _) {
                    final entry = store.entry(lesson.id);
                    return entry.completed
                        ? _meta(Icons.check, 'Completed · best ${entry.bestScore}/100', color: C.forest)
                        : const SizedBox.shrink();
                  },
                ),
              ],
            ),
          ],
        ),
      );

  Widget _meta(IconData icon, String text, {Color color = C.muted}) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Flexible(child: Text(text, style: display(12.5, weight: 520, color: color, height: 1.3))),
        ],
      );

  Widget _objectives(Lesson lesson) => Container(
        color: C.paperDeep,
        padding: const EdgeInsets.fromLTRB(20, 22, 20, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Eyebrow('By the end'),
            for (final objective in lesson.objectives)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 3),
                      child: Icon(Icons.checklist, size: 17, color: C.coral),
                    ),
                    const SizedBox(width: 10),
                    Expanded(child: Text(objective, style: display(14.5, weight: 480, height: 1.35))),
                  ],
                ),
              ),
          ],
        ),
      );

  Widget _contents(Lesson lesson) {
    Widget row(String label, GlobalKey key) => InkWell(
          onTap: () => _jump(key),
          child: Container(
            constraints: const BoxConstraints(minHeight: 44),
            alignment: Alignment.centerLeft,
            decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: C.lineSoft))),
            child: Text(label, style: display(14, weight: 500, height: 1.3)),
          ),
        );
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Eyebrow('In this lesson', bottom: 4),
          for (var i = 0; i < lesson.sections.length; i++)
            row('${pad2(i + 1)}  ${lesson.sections[i].heading}', _sectionKeys[i]),
          row('Original source', _sourceKey),
          row('Knowledge check', _quizKey),
          row('Your notes', _notesKey),
        ],
      ),
    );
  }

  Widget _section(LessonSection section, int i, GlobalKey key) => Padding(
        key: key,
        padding: const EdgeInsets.fromLTRB(20, 32, 20, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(pad2(i + 1), style: mono(12, medium: true, color: C.coral)),
            const SizedBox(height: 6),
            Text(section.heading, style: display(27, height: 1.1)),
            const SizedBox(height: 14),
            for (final paragraph in section.paragraphs)
              Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Text(paragraph, style: reading(18, height: 1.62)),
              ),
            if (section.callout != null)
              Container(
                margin: const EdgeInsets.only(top: 4, bottom: 8),
                padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
                decoration: const BoxDecoration(
                  color: C.raised,
                  border: Border(left: BorderSide(color: C.coral, width: 3)),
                ),
                child: Text(section.callout!, style: reading(17, italic: true, height: 1.5)),
              ),
          ],
        ),
      );

  Widget _example(Lesson lesson) => Container(
        margin: const EdgeInsets.fromLTRB(20, 28, 20, 0),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: C.raised, border: Border.all(color: C.lineSoft)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.lightbulb_outline, size: 25, color: C.coral),
            const SizedBox(height: 12),
            const Eyebrow('Work it through', bottom: 8),
            Text(lesson.exampleTitle, style: display(22, height: 1.12)),
            const SizedBox(height: 10),
            Text(lesson.exampleBody, style: reading(17, height: 1.58)),
          ],
        ),
      );

  Widget _distinction(Lesson lesson) => Container(
        margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
        padding: const EdgeInsets.all(20),
        color: C.plum,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Eyebrow('Read carefully', color: C.accentSoft, bottom: 8),
            Text(lesson.distinction, style: reading(18.5, color: C.paper, height: 1.5)),
          ],
        ),
      );

  Widget _source(Lesson lesson) => Padding(
        key: _sourceKey,
        padding: const EdgeInsets.fromLTRB(20, 36, 20, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Eyebrow('Return to Marx'),
            Text('Read the original argument.', style: display(27, height: 1.1)),
            const SizedBox(height: 10),
            Text(
              'The lesson is a guide, not a substitute. Open the notebook pages and compare the explanation with Marx’s own sequence, digressions, and qualifications.',
              style: reading(16.5, color: C.muted, height: 1.55),
            ),
            const SizedBox(height: 16),
            PrimaryButton(
              lesson.source.label,
              icon: Icons.open_in_new,
              expand: true,
              onPressed: () => openUrl(context, lesson.source.url),
            ),
            if (lesson.furtherReading != null) ...[
              const SizedBox(height: 6),
              UnderlinedLink(
                lesson.furtherReading!.label,
                icon: Icons.open_in_new,
                onTap: () => openUrl(context, lesson.furtherReading!.url),
              ),
            ],
            const SizedBox(height: 6),
            Text('SOURCE TEXTS OPEN IN YOUR BROWSER AND NEED A CONNECTION', style: mono(9.5, color: C.muted, spacing: 0.6)),
            ..._readTracker(lesson),
          ],
        ),
      );

  /// Lets the reader tick off the notebook passages this lesson links to,
  /// feeding the same tracker as the library.
  List<Widget> _readTracker(Lesson lesson) {
    final urls = {lesson.source.url, if (lesson.furtherReading != null) lesson.furtherReading!.url};
    final passages = course.allPassages.where((p) => urls.contains(p.url)).take(3).toList();
    if (passages.isEmpty) return const [];
    return [
      const SizedBox(height: 18),
      ListenableBuilder(
        listenable: store,
        builder: (context, _) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Eyebrow('Reading tracker', bottom: 4),
            for (final p in passages)
              CheckboxListTile(
                value: store.isRead(p),
                onChanged: (v) => store.setRead(p, v ?? false),
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
                activeColor: C.forest,
                checkboxShape: const RoundedRectangleBorder(),
                title: Text('I have read p. ${p.page} · ${p.title}', style: display(14, weight: 500, height: 1.3)),
              ),
          ],
        ),
      ),
    ];
  }

  Widget _labLink(String lab) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
        child: Material(
          color: C.forest,
          child: InkWell(
            onTap: () => AppNav.openLab(context, lab),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                children: [
                  const Icon(Icons.science_outlined, size: 28, color: C.paper),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('PUT THE MODEL IN MOTION', style: mono(10, color: C.accentSoft, spacing: 0.8)),
                        const SizedBox(height: 4),
                        Text(_labNames[lab] ?? 'Interactive lab', style: display(19, color: C.paper, height: 1.15)),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward, size: 22, color: C.paper),
                ],
              ),
            ),
          ),
        ),
      );

  Widget _terms(List<GlossaryTerm> terms) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Eyebrow('Terms to retain'),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final term in terms)
                  Material(
                    color: Colors.transparent,
                    shape: const RoundedRectangleBorder(side: BorderSide(color: C.lineStrong)),
                    child: InkWell(
                      onTap: () => AppNav.openTerm(context, term.term),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Flexible(child: Text(term.term, style: display(13.5, weight: 550, height: 1.2))),
                            const SizedBox(width: 6),
                            const Icon(Icons.arrow_forward, size: 15),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      );

  Widget _pagination(Lesson? previous, Lesson? next) {
    Widget cell(String small, String title, IconData icon, bool forward, VoidCallback onTap) => InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: const BoxDecoration(border: Border(top: BorderSide(color: C.lineSoft))),
            child: Row(
              children: [
                if (!forward) ...[Icon(icon, size: 20), const SizedBox(width: 14)],
                Expanded(
                  child: Column(
                    crossAxisAlignment: forward ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                    children: [
                      Text(small.toUpperCase(), style: mono(10, color: C.muted, spacing: 0.7)),
                      const SizedBox(height: 4),
                      Text(
                        title,
                        textAlign: forward ? TextAlign.end : TextAlign.start,
                        style: display(17, height: 1.2, spacing: -0.3),
                      ),
                    ],
                  ),
                ),
                if (forward) ...[const SizedBox(width: 14), Icon(icon, size: 20)],
              ],
            ),
          ),
        );
    return Padding(
      padding: const EdgeInsets.only(top: 36),
      child: Column(
        children: [
          if (next != null)
            cell('Next · ${next.number}', next.title, Icons.arrow_forward, true,
                () => AppNav.openLesson(context, next.id, replace: true))
          else
            cell('Course complete', 'Review your curriculum', Icons.arrow_forward, true,
                () => AppNav.openModule(context, null)),
          if (previous != null)
            cell('Previous · ${previous.number}', previous.title, Icons.arrow_back, false,
                () => AppNav.openLesson(context, previous.id, replace: true)),
          const Divider(),
        ],
      ),
    );
  }
}

class KnowledgeCheck extends StatefulWidget {
  const KnowledgeCheck({super.key, required this.lesson, required this.onFinish});
  final Lesson lesson;
  final ValueChanged<int> onFinish;

  @override
  State<KnowledgeCheck> createState() => _KnowledgeCheckState();
}

class _KnowledgeCheckState extends State<KnowledgeCheck> {
  int index = 0;
  int? selected;
  bool checked = false;
  int correctCount = 0;
  bool finished = false;
  int score = 0;

  List<QuizQuestion> get quiz => widget.lesson.quiz;

  void _check() {
    if (selected == null) return;
    setState(() {
      checked = true;
      if (selected == quiz[index].answer) correctCount++;
    });
  }

  void _next() {
    if (index == quiz.length - 1) {
      final finalScore = (correctCount / quiz.length * 100).round();
      setState(() {
        score = finalScore;
        finished = true;
      });
      widget.onFinish(finalScore);
      return;
    }
    setState(() {
      index++;
      selected = null;
      checked = false;
    });
  }

  void _reset() => setState(() {
        index = 0;
        selected = null;
        checked = false;
        correctCount = 0;
        finished = false;
        score = 0;
      });

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(top: 40),
        padding: const EdgeInsets.fromLTRB(20, 32, 20, 32),
        color: C.paperDeep,
        child: finished ? _result() : _question(),
      );

  Widget _result() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Eyebrow('Knowledge check complete'),
          Semantics(
            label: 'Score $score out of 100',
            child: ExcludeSemantics(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('$score', style: display(84, weight: 620, color: score == 100 ? C.forest : C.ink, height: 0.9)),
                  Padding(
                    padding: const EdgeInsets.only(left: 8, bottom: 8),
                    child: Text('/ 100', style: mono(15, color: C.muted)),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            score == 100 ? 'Every distinction held.' : 'Good reading. Now revisit the gaps.',
            style: display(25, height: 1.1),
          ),
          const SizedBox(height: 10),
          Text(
            'Your best score is saved with this lesson. Completion does not require a perfect score—returning to an argument is part of studying it.',
            style: reading(16.5, color: C.muted, height: 1.55),
          ),
          const SizedBox(height: 18),
          SecondaryButton('Retake the check', leading: Icons.refresh, onPressed: _reset),
        ],
      );

  Widget _question() {
    final question = quiz[index];
    final isCorrect = selected == question.answer;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Expanded(child: Eyebrow('Knowledge check')),
            Text('${index + 1} / ${quiz.length}', style: mono(12, medium: true)),
          ],
        ),
        Text('Make the argument your own.', style: display(27, height: 1.1)),
        const SizedBox(height: 20),
        Text(question.question, style: reading(20, weight: 500, height: 1.38)),
        const SizedBox(height: 16),
        for (var i = 0; i < question.options.length; i++)
          _option(question, i, isCorrect),
        if (checked)
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(top: 6),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: C.raised,
              border: Border(left: BorderSide(color: isCorrect ? C.forest : C.error, width: 3)),
            ),
            child: Semantics(
              liveRegion: true,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isCorrect ? 'Correct.' : 'Not quite.',
                    style: display(15, weight: 650, color: isCorrect ? C.forest : C.error, height: 1.3),
                  ),
                  const SizedBox(height: 4),
                  Text(question.explanation, style: reading(16.5, height: 1.5)),
                ],
              ),
            ),
          ),
        const SizedBox(height: 18),
        if (!checked)
          PrimaryButton('Check answer', expand: true, onPressed: selected == null ? null : _check)
        else
          PrimaryButton(
            index == quiz.length - 1 ? 'Finish check' : 'Next question',
            icon: Icons.chevron_right,
            expand: true,
            onPressed: _next,
          ),
      ],
    );
  }

  Widget _option(QuizQuestion question, int i, bool isCorrect) {
    final isSelected = selected == i;
    final showCorrect = checked && i == question.answer;
    final showWrong = checked && isSelected && !isCorrect;
    final border = showCorrect ? C.forest : showWrong ? C.error : isSelected ? C.ink : C.lineSoft;
    final letterFill = showCorrect ? C.forest : showWrong ? C.error : isSelected ? C.ink : Colors.transparent;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Semantics(
        inMutuallyExclusiveGroup: true,
        checked: isSelected,
        enabled: !checked,
        child: Material(
          color: isSelected || showCorrect ? C.raised : Colors.transparent,
          shape: RoundedRectangleBorder(
            side: BorderSide(color: border, width: isSelected || showCorrect ? 1.5 : 1),
          ),
          child: InkWell(
            onTap: checked ? null : () => setState(() => selected = i),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 26,
                    height: 26,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(color: letterFill, border: Border.all(color: border)),
                    child: Text(
                      String.fromCharCode(65 + i),
                      style: mono(12, medium: true, height: 1, color: letterFill == Colors.transparent ? C.ink : C.paper),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: Text(question.options[i], style: reading(17, height: 1.42))),
                  if (showCorrect)
                    const Icon(Icons.check, size: 20, color: C.forest, semanticLabel: 'Correct answer'),
                  if (showWrong)
                    const Icon(Icons.close, size: 20, color: C.error, semanticLabel: 'Your answer, incorrect'),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class NoteEditor extends StatefulWidget {
  const NoteEditor({super.key, required this.lessonId});
  final String lessonId;

  @override
  State<NoteEditor> createState() => _NoteEditorState();
}

class _NoteEditorState extends State<NoteEditor> {
  static const _max = 12000;
  late final _controller = TextEditingController(text: store.note(widget.lessonId));
  bool _justSaved = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _save() {
    store.saveNote(widget.lessonId, _controller.text);
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() => _justSaved = true);
    Future<void>.delayed(const Duration(milliseconds: 1800), () {
      if (mounted) setState(() => _justSaved = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final dirty = _controller.text != store.note(widget.lessonId);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 36, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Expanded(child: Eyebrow('Your margin')),
              const Icon(Icons.smartphone, size: 14, color: C.muted),
              const SizedBox(width: 5),
              Text('SAVED ON THIS DEVICE', style: mono(9.5, color: C.muted, spacing: 0.6)),
            ],
          ),
          Text('Lesson notes', style: display(27, height: 1.1)),
          const SizedBox(height: 14),
          TextField(
            controller: _controller,
            onChanged: (_) => setState(() => _justSaved = false),
            minLines: 6,
            maxLines: 14,
            maxLength: _max,
            textCapitalization: TextCapitalization.sentences,
            style: reading(17, height: 1.55),
            cursorColor: C.coral,
            decoration: InputDecoration(
              hintText: 'Write a question, reconstruct an argument, or record a passage to revisit…',
              hintStyle: reading(17, color: C.muted, height: 1.55),
              hintMaxLines: 3,
              counterText: '',
              filled: true,
              fillColor: C.raised,
              contentPadding: const EdgeInsets.all(16),
              enabledBorder: const OutlineInputBorder(
                borderRadius: BorderRadius.zero,
                borderSide: BorderSide(color: C.lineSoft),
              ),
              focusedBorder: const OutlineInputBorder(
                borderRadius: BorderRadius.zero,
                borderSide: BorderSide(color: C.ink, width: 1.5),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text('${grouped(_controller.text.characters.length)} / ${grouped(_max)}', style: mono(11, color: C.muted)),
              const Spacer(),
              SecondaryButton(
                _justSaved ? 'Saved' : 'Save note',
                leading: _justSaved ? Icons.check : Icons.save_outlined,
                onPressed: dirty ? _save : null,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
