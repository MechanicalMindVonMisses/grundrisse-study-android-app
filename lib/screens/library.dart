import 'package:material_ui/material_ui.dart';

import '../data.dart';
import '../store.dart';
import '../theme.dart';

/// The notebook reading room: every section of the manuscript, indexed by
/// Penguin page number, with an on-device "read" tracker.
class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  static const _filters = ['All passages', 'Unread', 'Read'];

  final _search = TextEditingController();
  String _partId = course.sourceParts.first.id;
  String _query = '';
  String _filter = _filters.first;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _clear() {
    _search.clear();
    setState(() {
      _query = '';
      _filter = _filters.first;
    });
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: store,
        builder: (context, _) {
          final part = course.sourceParts.firstWhere((p) => p.id == _partId);
          final q = _query.trim().toLowerCase();
          final passages = part.passages.where((p) {
            final read = store.isRead(p);
            final matchesFilter = _filter == 'All passages' || (_filter == 'Read' ? read : !read);
            return matchesFilter && ('${p.title} ${p.page}').toLowerCase().contains(q);
          }).toList();
          final totalRead = store.readCount(course.allPassages);
          final partRead = store.readCount(part.passages);

          return ListView(
            padding: const EdgeInsets.only(bottom: 32),
            children: [
              PageIntro(
                eyebrow: 'Notebook reading room',
                plain: 'Eight notebooks.\n',
                emphasis: 'Page by page.',
                body: 'Every section of the Grundrisse on the Marx/Engels Internet Archive, indexed by the page numbers of the Penguin edition. Open a passage in your browser, then mark it read to track your way through the manuscript.',
                trailing: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(child: ProgressLine(totalRead / course.passageCount, height: 6)),
                        const SizedBox(width: 12),
                        Text('$totalRead/${course.passageCount}', style: display(16, weight: 600, height: 1)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text('PASSAGES MARKED READ ON THIS DEVICE', style: mono(10, color: C.muted, spacing: 0.6)),
                    const SizedBox(height: 12),
                    Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const Icon(Icons.wifi, size: 16, color: C.muted),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'The index is stored on your device. The texts themselves open in your browser and need a connection.',
                          style: display(12.5, weight: 450, color: C.muted, height: 1.4),
                        ),
                      ),
                    ]),
                  ],
                ),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: pagePadding,
                child: Row(
                  children: [
                    for (var i = 0; i < course.sourceParts.length; i++)
                      _partTab(course.sourceParts[i], i),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Eyebrow('${part.notebooks} · ${part.pages}'),
                    Text(part.title, style: display(29, height: 1.08)),
                    const SizedBox(height: 8),
                    Text(part.subtitle, style: reading(16.5, color: C.muted, height: 1.5)),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(child: ProgressLine(partRead / part.passages.length, height: 4, color: C.forest)),
                        const SizedBox(width: 12),
                        Text('$partRead / ${part.passages.length} read', style: mono(11, color: C.muted)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SecondaryButton(
                      'Open this part',
                      icon: Icons.open_in_new,
                      onPressed: () => openUrl(context, part.contentsUrl),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      color: C.paperDeep,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('EDITION NOTE', style: mono(10, medium: true, spacing: 0.9)),
                          const SizedBox(height: 8),
                          Text(part.editorialNote, style: reading(15.5, height: 1.5)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    SearchField(
                      controller: _search,
                      hint: 'Search ${part.passages.length} passages or a page…',
                      onChanged: (value) => setState(() => _query = value),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              FilterChips(
                items: _filters,
                selected: _filter,
                onSelected: (value) => setState(() => _filter = value),
              ),
              const SizedBox(height: 12),
              const Divider(color: C.ink),
              for (final passage in passages) _PassageRow(passage: passage),
              if (passages.isEmpty)
                EmptyState(
                  title: 'No passages match.',
                  body: 'Try a broader phrase, another page number, or a different filter.',
                  action: SecondaryButton('Clear search', onPressed: _clear),
                ),
              _downloads(context),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 44, 20, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Eyebrow('Before, beside, and after the notebooks'),
                    Text('Companion texts.', style: display(32, height: 1.05)),
                  ],
                ),
              ),
              const Divider(color: C.ink),
              for (final text in course.companionTexts)
                InkWell(
                  onTap: () => openUrl(context, text.url),
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(20, 16, 16, 16),
                    decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: C.lineSoft))),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(width: 52, child: Text(text.year, style: mono(12, medium: true, color: C.coral))),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(text.title, style: display(18, height: 1.2, spacing: -0.3)),
                              const SizedBox(height: 5),
                              Text(text.description, style: reading(15, color: C.muted, height: 1.45)),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Icon(Icons.open_in_new, size: 17, color: C.muted),
                      ],
                    ),
                  ),
                ),
              Container(
                margin: const EdgeInsets.fromLTRB(20, 28, 20, 0),
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(border: Border.all(color: C.lineSoft)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Source & method', style: display(15, weight: 650, height: 1.3)),
                    const SizedBox(height: 6),
                    Text(
                      'Texts open on the Marxists Internet Archive: Grundrisse, translated by Martin Nicolaus (Penguin Books in association with New Left Review, 1973), with notes by Ben Fowkes. Passage labels in this index are short study titles, and page numbers follow the Penguin edition as marked online. Lesson explanations are original study aids; always check interpretive claims against the text and alternative scholarship.',
                      style: reading(15, color: C.muted, height: 1.5),
                    ),
                    const SizedBox(height: 4),
                    UnderlinedLink(
                      'Visit the Marx/Engels Library',
                      icon: Icons.open_in_new,
                      onTap: () => openUrl(context, 'https://www.marxists.org/archive/marx/works/'),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      );

  Widget _partTab(SourcePart p, int i) {
    final selected = p.id == _partId;
    final read = store.readCount(p.passages);
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Semantics(
        button: true,
        selected: selected,
        child: Material(
          color: selected ? C.ink : Colors.transparent,
          shape: RoundedRectangleBorder(side: BorderSide(color: selected ? C.ink : C.lineSoft)),
          child: InkWell(
            onTap: () {
              _search.clear();
              setState(() {
                _partId = p.id;
                _query = '';
              });
            },
            child: Container(
              width: 132,
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('PART ${i + 1}', style: mono(9.5, spacing: 0.8, color: selected ? C.accentSoft : C.coral)),
                  const SizedBox(height: 6),
                  Text(p.short, style: reading(22, italic: true, height: 1.05, color: selected ? C.paper : C.ink)),
                  const SizedBox(height: 6),
                  Text('$read/${p.passages.length} read', style: mono(10, color: selected ? C.paperDeep : C.muted)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _downloads(BuildContext context) => Container(
        margin: const EdgeInsets.fromLTRB(20, 32, 20, 0),
        padding: const EdgeInsets.all(18),
        color: C.plum,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Eyebrow('Read it whole', color: C.accentSoft, bottom: 8),
            Text('The complete text, offline.', style: display(23, color: C.paper, height: 1.12)),
            const SizedBox(height: 8),
            Text(
              'The archive offers the full translation as an e-book. Download it in your browser to read the notebooks without a connection.',
              style: reading(15.5, color: C.paperDeep, height: 1.5),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 18,
              children: [
                UnderlinedLink('PDF', icon: Icons.north_east, color: C.paper, onTap: () => openUrl(context, course.downloads['pdf']!)),
                UnderlinedLink('EPUB', icon: Icons.north_east, color: C.paper, onTap: () => openUrl(context, course.downloads['epub']!)),
                UnderlinedLink('Study guide', icon: Icons.north_east, color: C.paper, onTap: () => openUrl(context, course.downloads['guide']!)),
              ],
            ),
          ],
        ),
      );
}

class _PassageRow extends StatelessWidget {
  const _PassageRow({required this.passage});
  final Passage passage;

  @override
  Widget build(BuildContext context) {
    final read = store.isRead(passage);
    return Container(
      decoration: BoxDecoration(
        color: read ? C.raised : null,
        border: const Border(bottom: BorderSide(color: C.lineSoft)),
      ),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: () => openUrl(context, passage.url),
              child: Container(
                constraints: const BoxConstraints(minHeight: 56),
                padding: const EdgeInsets.fromLTRB(20, 12, 8, 12),
                child: Row(
                  children: [
                    SizedBox(
                      width: 50,
                      child: Text('p.${passage.page}', style: mono(12, color: C.coral, medium: true)),
                    ),
                    Expanded(
                      child: Text(
                        passage.title,
                        style: display(15.5, weight: 520, height: 1.28, color: read ? C.muted : C.ink),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.open_in_new, size: 16, color: C.muted),
                  ],
                ),
              ),
            ),
          ),
          Semantics(
            label: read ? 'Mark page ${passage.page} unread' : 'Mark page ${passage.page} read',
            button: true,
            child: InkWell(
              onTap: () => store.setRead(passage, !read),
              child: Container(
                width: 56,
                height: 56,
                alignment: Alignment.center,
                child: ExcludeSemantics(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: read ? C.forest : Colors.transparent,
                      border: Border.all(color: read ? C.forest : C.lineStrong, width: 1.5),
                    ),
                    child: read ? const Icon(Icons.check, size: 16, color: C.paper) : null,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
