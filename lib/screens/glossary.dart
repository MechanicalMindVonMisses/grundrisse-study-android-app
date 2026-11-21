import 'package:material_ui/material_ui.dart';

import '../data.dart';
import '../nav.dart';
import '../theme.dart';

class GlossaryScreen extends StatefulWidget {
  const GlossaryScreen({super.key});

  @override
  State<GlossaryScreen> createState() => _GlossaryScreenState();
}

class _GlossaryScreenState extends State<GlossaryScreen> {
  final _search = TextEditingController();
  final _keys = {for (final t in course.glossaryTerms) t.term: GlobalKey()};
  String _query = '';
  String _category = 'All';
  bool _review = false;
  int _reviewIndex = 0;
  bool _revealed = false;

  @override
  void initState() {
    super.initState();
    AppNav.glossaryTerm.addListener(_onTerm);
    if (AppNav.glossaryTerm.value != null) _onTerm();
  }

  @override
  void dispose() {
    AppNav.glossaryTerm.removeListener(_onTerm);
    _search.dispose();
    super.dispose();
  }

  /// A lesson asked for a specific term: show the full list and scroll to it.
  void _onTerm() {
    final term = AppNav.glossaryTerm.value;
    if (term == null) {
      if (mounted) setState(() {});
      return;
    }
    _search.clear();
    setState(() {
      _query = '';
      _category = 'All';
      _review = false;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final target = _keys[term]?.currentContext;
      if (target != null) {
        Scrollable.ensureVisible(target, alignment: 0.2, duration: const Duration(milliseconds: 350), curve: Curves.easeOutCubic);
      }
    });
  }

  void _resetReview() {
    _reviewIndex = 0;
    _revealed = false;
  }

  @override
  Widget build(BuildContext context) {
    final q = _query.trim().toLowerCase();
    final filtered = course.glossaryTerms.where((item) {
      final text = '${item.term} ${item.definition} ${item.watchFor}'.toLowerCase();
      return (_category == 'All' || item.category == _category) && text.contains(q);
    }).toList()
      ..sort((a, b) => a.term.toLowerCase().compareTo(b.term.toLowerCase()));
    final highlighted = AppNav.glossaryTerm.value;
    final reviewTerm = filtered.isEmpty ? null : filtered[_reviewIndex.clamp(0, filtered.length - 1)];

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PageIntro(
            eyebrow: 'Glossary & active recall',
            plain: 'Keep the concepts\n',
            emphasis: 'precise.',
            body: 'Definitions tell you what a category means; “watch for” records the confusion that most often weakens it. Use review mode to reconstruct a definition before revealing it.',
            trailing: PrimaryButton(
              _review ? 'Exit review' : 'Review flashcards',
              leading: _review ? Icons.close : Icons.visibility_outlined,
              onPressed: () {
                AppNav.glossaryTerm.value = null;
                setState(() {
                  _review = !_review;
                  _resetReview();
                });
              },
            ),
          ),
          Padding(
            padding: pagePadding,
            child: SearchField(
              controller: _search,
              hint: 'Search ${course.glossaryTerms.length} definitions…',
              onChanged: (value) => setState(() {
                _query = value;
                _resetReview();
              }),
            ),
          ),
          const SizedBox(height: 12),
          FilterChips(
            items: course.glossaryCategories,
            selected: _category,
            onSelected: (value) => setState(() {
              _category = value;
              _resetReview();
            }),
          ),
          const SizedBox(height: 16),
          if (filtered.isEmpty)
            EmptyState(
              icon: Icons.refresh,
              title: 'No concepts match.',
              body: 'Try another word or reset the category.',
              action: SecondaryButton('Reset glossary', onPressed: () {
                _search.clear();
                setState(() {
                  _query = '';
                  _category = 'All';
                  _resetReview();
                });
              }),
            )
          else if (_review && reviewTerm != null)
            _flashcard(reviewTerm, filtered.length)
          else ...[
            const Divider(color: C.ink),
            for (var i = 0; i < filtered.length; i++)
              _entry(filtered[i], i, filtered[i].term == highlighted),
          ],
        ],
      ),
    );
  }

  Widget _watchFor(String text, {Color background = C.paperDeep}) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        color: background,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('WATCH FOR', style: mono(10, medium: true, color: C.coral, spacing: 0.9)),
            const SizedBox(height: 6),
            Text(text, style: reading(15.5, height: 1.48)),
          ],
        ),
      );

  Widget _entry(GlossaryTerm item, int index, bool highlight) => Container(
        key: _keys[item.term],
        padding: const EdgeInsets.fromLTRB(20, 22, 20, 14),
        decoration: BoxDecoration(
          color: highlight ? C.accentSoft.withValues(alpha: 0.45) : null,
          border: Border(
            bottom: const BorderSide(color: C.lineSoft),
            left: highlight ? const BorderSide(color: C.coral, width: 4) : BorderSide.none,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(pad2(index + 1), style: mono(11, color: C.muted)),
                const SizedBox(width: 12),
                Text(item.category.toUpperCase(), style: mono(10, color: C.coral, medium: true, spacing: 0.8)),
              ],
            ),
            const SizedBox(height: 6),
            Text(item.term, style: display(25, height: 1.1)),
            const SizedBox(height: 10),
            Text(item.definition, style: reading(17, height: 1.55)),
            const SizedBox(height: 12),
            _watchFor(item.watchFor, background: highlight ? C.raised : C.paperDeep),
            const SizedBox(height: 4),
            UnderlinedLink(
              'Open related lesson',
              icon: Icons.arrow_forward,
              onTap: () => AppNav.openLesson(context, item.lessonId),
            ),
          ],
        ),
      );

  Widget _flashcard(GlossaryTerm term, int total) => Container(
        margin: pagePadding,
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(color: C.raised, border: Border.all(color: C.ink)),
        child: Semantics(
          liveRegion: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(child: Text(term.category.toUpperCase(), style: mono(10, color: C.coral, medium: true, spacing: 0.8))),
                  Text('${_reviewIndex.clamp(0, total - 1) + 1} / $total', style: mono(12, medium: true)),
                ],
              ),
              const SizedBox(height: 28),
              const Eyebrow('Define before you reveal'),
              Text(term.term, style: display(38, height: 1.02)),
              const SizedBox(height: 18),
              if (_revealed) ...[
                Text(term.definition, style: reading(18, height: 1.55)),
                const SizedBox(height: 14),
                _watchFor(term.watchFor),
                const SizedBox(height: 4),
                UnderlinedLink(
                  'Review the related lesson',
                  icon: Icons.arrow_forward,
                  onTap: () => AppNav.openLesson(context, term.lessonId),
                ),
              ] else
                Text(
                  'Say the definition aloud, then check its scope and limits.',
                  style: reading(18, italic: true, color: C.muted, height: 1.5),
                ),
              const SizedBox(height: 24),
              SecondaryButton(
                _revealed ? 'Hide definition' : 'Reveal definition',
                leading: _revealed ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                expand: true,
                onPressed: () => setState(() => _revealed = !_revealed),
              ),
              const SizedBox(height: 10),
              PrimaryButton(
                'Next concept',
                icon: Icons.arrow_forward,
                expand: true,
                onPressed: () => setState(() {
                  _reviewIndex = (_reviewIndex + 1) % total;
                  _revealed = false;
                }),
              ),
            ],
          ),
        ),
      );
}
