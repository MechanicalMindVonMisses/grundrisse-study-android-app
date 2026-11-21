import 'package:material_ui/material_ui.dart';

import '../data.dart';
import '../nav.dart';
import '../store.dart';
import '../theme.dart';

class CurriculumScreen extends StatefulWidget {
  const CurriculumScreen({super.key});

  @override
  State<CurriculumScreen> createState() => _CurriculumScreenState();
}

class _CurriculumScreenState extends State<CurriculumScreen> {
  static const _filters = ['All lessons', 'To do', 'Completed'];

  final _search = TextEditingController();
  String _query = '';
  String _filter = _filters.first;
  late Set<String> _open = {AppNav.module.value ?? course.modules.first.id};

  @override
  void initState() {
    super.initState();
    AppNav.module.addListener(_onModule);
  }

  @override
  void dispose() {
    AppNav.module.removeListener(_onModule);
    _search.dispose();
    super.dispose();
  }

  void _onModule() {
    final selected = AppNav.module.value;
    setState(() {
      if (selected != null) _open = {selected};
    });
  }

  void _reset() {
    _search.clear();
    setState(() {
      _query = '';
      _filter = _filters.first;
    });
    AppNav.module.value = null;
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: store,
        builder: (context, _) {
          final selected = AppNav.module.value;
          final q = _query.trim().toLowerCase();
          final visible = course.lessons.where((lesson) {
            final done = store.entry(lesson.id).completed;
            final matchesFilter = _filter == 'All lessons' || (_filter == 'Completed' ? done : !done);
            final text = '${lesson.title} ${lesson.description} ${lesson.eyebrow}'.toLowerCase();
            return matchesFilter && text.contains(q);
          }).toList();
          final filtering = q.isNotEmpty || _filter != 'All lessons';
          final modules = selected == null
              ? course.modules
              : course.modules.where((m) => m.id == selected).toList();
          final anyShown = modules.any((m) => visible.any((l) => l.moduleId == m.id));

          return ListView(
            padding: const EdgeInsets.only(bottom: 32),
            children: [
              PageIntro(
                eyebrow: 'The complete course',
                plain: 'Your reading\n',
                emphasis: 'curriculum.',
                body: 'Six levels follow the manuscript from the 1857 Introduction and the chapter on money to surplus value, pre-capitalist forms, circulation time, and the Fragment on Machines. Each lesson pairs a guided explanation with the notebook pages and two knowledge checks.',
                trailing: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(child: ProgressLine(store.percent / 100, height: 6)),
                        const SizedBox(width: 12),
                        Text('${store.percent}%', style: display(18, weight: 600, height: 1)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${store.completedCount} of ${course.lessons.length} lessons completed'.toUpperCase(),
                      style: mono(10, color: C.muted, spacing: 0.6),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: pagePadding,
                child: SearchField(
                  controller: _search,
                  hint: 'Search lessons or concepts…',
                  onChanged: (value) => setState(() => _query = value),
                ),
              ),
              const SizedBox(height: 12),
              FilterChips(
                items: _filters,
                selected: _filter,
                onSelected: (value) => setState(() => _filter = value),
              ),
              if (selected != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                  child: Row(
                    children: [
                      Expanded(child: Text('SHOWING ONE LEVEL', style: mono(10, color: C.muted, spacing: 0.8))),
                      UnderlinedLink('Show all six levels', onTap: () => AppNav.module.value = null),
                    ],
                  ),
                ),
              const SizedBox(height: 16),
              const Divider(color: C.ink),
              for (final module in modules)
                if (!filtering || visible.any((l) => l.moduleId == module.id))
                  _ModuleBlock(
                    module: module,
                    lessons: visible.where((l) => l.moduleId == module.id).toList(),
                    open: _open.contains(module.id),
                    onToggle: () => setState(() {
                      if (!_open.remove(module.id)) _open.add(module.id);
                    }),
                  ),
              if (!anyShown)
                EmptyState(
                  title: 'No lessons match.',
                  body: 'Clear the search or choose another progress filter.',
                  action: SecondaryButton('Reset curriculum', onPressed: _reset),
                ),
            ],
          );
        },
      );
}

class _ModuleBlock extends StatelessWidget {
  const _ModuleBlock({required this.module, required this.lessons, required this.open, required this.onToggle});
  final CourseModule module;
  final List<Lesson> lessons;
  final bool open;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final all = course.moduleLessons(module.id);
    final complete = all.where((l) => store.entry(l.id).completed).length;
    return Container(
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: C.ink))),
      child: Column(
        children: [
          Semantics(
            button: true,
            expanded: open,
            child: InkWell(
              onTap: onToggle,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 16, 18),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 44,
                      child: Text(module.index, style: reading(26, italic: true, color: C.coral, height: 1.1)),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(module.subtitle.toUpperCase(), style: mono(10, color: C.muted, spacing: 0.7)),
                          const SizedBox(height: 4),
                          Text(module.title, style: display(22, height: 1.12)),
                          if (open) ...[
                            const SizedBox(height: 8),
                            Text(module.description, style: reading(15, color: C.muted, height: 1.45)),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('$complete/${all.length}', style: mono(12, medium: true)),
                        const SizedBox(height: 6),
                        AnimatedRotation(
                          turns: open ? 0.125 : 0,
                          duration: const Duration(milliseconds: 200),
                          child: const Icon(Icons.add, size: 22),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (open)
            for (final lesson in lessons) _LessonRow(lesson: lesson),
        ],
      ),
    );
  }
}

class _LessonRow extends StatelessWidget {
  const _LessonRow({required this.lesson});
  final Lesson lesson;

  @override
  Widget build(BuildContext context) {
    final entry = store.entry(lesson.id);
    return InkWell(
      onTap: () => AppNav.openLesson(context, lesson.id),
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 16, 16),
        decoration: const BoxDecoration(
          color: C.raised,
          border: Border(top: BorderSide(color: C.lineSoft)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 34,
              height: 34,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: entry.completed ? C.forest : Colors.transparent,
                border: Border.all(color: entry.completed ? C.forest : C.lineStrong),
              ),
              child: entry.completed
                  ? const Icon(Icons.check, size: 18, color: C.paper, semanticLabel: 'Completed')
                  : Text(pad2(lesson.number), style: mono(12, medium: true, height: 1)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(lesson.eyebrow.toUpperCase(), style: mono(9.5, color: C.muted, spacing: 0.6)),
                  const SizedBox(height: 4),
                  Text(lesson.title, style: display(17.5, height: 1.18, spacing: -0.3)),
                  const SizedBox(height: 5),
                  Text(lesson.description, style: reading(14.5, color: C.muted, height: 1.42)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.schedule, size: 14, color: C.muted),
                      const SizedBox(width: 5),
                      Text('${lesson.duration} min', style: mono(11, color: C.muted)),
                      if (entry.bookmarked) ...[
                        const SizedBox(width: 12),
                        const Icon(Icons.bookmark, size: 15, color: C.coral, semanticLabel: 'Bookmarked'),
                      ],
                      if (entry.completed) ...[
                        const SizedBox(width: 12),
                        Flexible(child: Text('best ${entry.bestScore}/100', style: mono(11, color: C.forest))),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(left: 8, top: 6),
              child: Icon(Icons.arrow_forward, size: 19),
            ),
          ],
        ),
      ),
    );
  }
}
