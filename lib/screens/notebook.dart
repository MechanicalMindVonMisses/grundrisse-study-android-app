import 'package:material_ui/material_ui.dart';

import '../data.dart';
import '../nav.dart';
import '../store.dart';
import '../theme.dart';

class NotebookScreen extends StatelessWidget {
  const NotebookScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('My notebook')),
        body: ListenableBuilder(
          listenable: store,
          builder: (context, _) {
            final written = store.notes.entries
                .where((e) => e.value.trim().isNotEmpty && course.lesson(e.key) != null)
                .map((e) => (course.lesson(e.key)!, e.value))
                .toList()
              ..sort((a, b) => a.$1.number.compareTo(b.$1.number));
            final bookmarks = course.lessons.where((l) => store.entry(l.id).bookmarked).toList();
            final next = store.nextLesson;
            final levels = written.map((e) => e.$1.moduleId).toSet().length;

            return ListView(
              padding: EdgeInsets.only(bottom: 32 + MediaQuery.paddingOf(context).bottom),
              children: [
                PageIntro(
                  eyebrow: 'Your study record',
                  plain: 'Notes for the\n',
                  emphasis: 'next reading.',
                  body: 'Marx thought in notebooks; so can you. Use yours to preserve objections, changes in your understanding, and questions worth taking back to the text.',
                  trailing: Row(children: [
                    const Icon(Icons.smartphone, size: 17),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Stored on this device — no account, no connection needed',
                        style: display(13, weight: 550, height: 1.3),
                      ),
                    ),
                  ]),
                ),
                const Divider(color: C.ink),
                IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _stat('Course complete', '${store.percent}%', '${store.completedCount} / ${course.lessons.length} lessons', true),
                      _stat('Written notes', pad2(written.length), 'Across $levels ${levels == 1 ? 'level' : 'levels'}', true),
                      _stat('Pages read', pad2(store.readCount(course.allPassages)), 'of ${course.passageCount} passages', false),
                    ],
                  ),
                ),
                Material(
                  color: C.ink,
                  child: InkWell(
                    onTap: () => AppNav.openLesson(context, next.id),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 18, 16, 18),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('UP NEXT · LESSON ${next.number}', style: mono(10, color: C.accentSoft, spacing: 0.8)),
                                const SizedBox(height: 5),
                                Text(next.title, style: display(21, color: C.paper, height: 1.12)),
                              ],
                            ),
                          ),
                          const Icon(Icons.arrow_forward, size: 22, color: C.paper),
                        ],
                      ),
                    ),
                  ),
                ),
                _heading('Lesson notes', written.length),
                if (written.isEmpty)
                  EmptyState(
                    icon: Icons.edit_note,
                    title: 'Your margins are empty.',
                    body: 'Open a lesson and write the first question you want to carry forward.',
                    action: SecondaryButton(
                      'Open lesson ${next.number}',
                      onPressed: () => AppNav.openLesson(context, next.id, showNotes: true),
                    ),
                  )
                else
                  for (final (lesson, content) in written)
                    InkWell(
                      onTap: () => AppNav.openLesson(context, lesson.id, showNotes: true),
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(20, 16, 16, 16),
                        decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: C.lineSoft))),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(width: 38, child: Text(pad2(lesson.number), style: mono(12, medium: true, color: C.coral))),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(lesson.eyebrow.toUpperCase(), style: mono(9.5, color: C.muted, spacing: 0.6)),
                                  const SizedBox(height: 4),
                                  Text(lesson.title, style: display(18, height: 1.18, spacing: -0.3)),
                                  const SizedBox(height: 8),
                                  Text(
                                    content.trim(),
                                    maxLines: 6,
                                    overflow: TextOverflow.ellipsis,
                                    style: reading(16, italic: true, height: 1.5),
                                  ),
                                ],
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.only(left: 10),
                              child: Icon(Icons.edit_outlined, size: 19, color: C.muted),
                            ),
                          ],
                        ),
                      ),
                    ),
                _heading('Bookmarks', bookmarks.length),
                if (bookmarks.isEmpty)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.bookmark_border, size: 24, color: C.muted),
                        const SizedBox(height: 8),
                        Text('Bookmark any lesson to keep it close.', style: reading(16, color: C.muted)),
                        UnderlinedLink('Browse curriculum', onTap: () => AppNav.openModule(context, null)),
                      ],
                    ),
                  )
                else
                  for (final lesson in bookmarks)
                    InkWell(
                      onTap: () => AppNav.openLesson(context, lesson.id),
                      child: Container(
                        constraints: const BoxConstraints(minHeight: 56),
                        padding: const EdgeInsets.fromLTRB(20, 12, 16, 12),
                        decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: C.lineSoft))),
                        child: Row(
                          children: [
                            const Icon(Icons.bookmark, size: 18, color: C.coral),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('LESSON ${lesson.number}', style: mono(9.5, color: C.muted, spacing: 0.6)),
                                  const SizedBox(height: 3),
                                  Text(lesson.title, style: display(16.5, height: 1.2, spacing: -0.3)),
                                ],
                              ),
                            ),
                            if (store.entry(lesson.id).completed)
                              const Icon(Icons.check, size: 18, color: C.forest, semanticLabel: 'Completed'),
                          ],
                        ),
                      ),
                    ),
              ],
            );
          },
        ),
      );

  Widget _stat(String label, String value, String small, bool divider) => Expanded(
        child: Container(
          padding: const EdgeInsets.fromLTRB(14, 16, 8, 16),
          decoration: BoxDecoration(
            border: Border(right: divider ? const BorderSide(color: C.lineSoft) : BorderSide.none),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label.toUpperCase(), style: mono(9, color: C.muted, spacing: 0.4)),
              const SizedBox(height: 10),
              Text(value, style: display(30, weight: 600, height: 1)),
              const SizedBox(height: 6),
              Text(small, style: display(11.5, weight: 450, color: C.muted, height: 1.3)),
            ],
          ),
        ),
      );

  Widget _heading(String title, int count) => Container(
        margin: const EdgeInsets.only(top: 36),
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
        decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: C.ink))),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(child: Text(title, style: display(27, height: 1.1))),
            Text(pad2(count), style: mono(13, medium: true)),
          ],
        ),
      );
}
